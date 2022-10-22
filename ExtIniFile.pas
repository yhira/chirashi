unit ExtIniFile;

// ExtIniFile Version 1.5.1           copyright(c) みず, 2002-2008

interface

uses
  SysUtils, Classes, IniFiles, Forms, ShlObj, ActiveX, Windows, Graphics,
  Controls, System.UITypes;

type
  TDefaultFolder = (dfAppData, dfApplication, dfUser, dfWindows);

  TExtIniFile = class(TComponent)
  private
    { Private 宣言 }
    // ******************************************************* フィールド **
    FAppName: string;
    FAutoUpdate: Boolean;
    FCaseSensitive: Boolean;
    FDefaultFolder: TDefaultFolder;
    FFileName: TFileName;
    FFolderPath: string;
    FIniFileName: TFileName;
    FModified: Boolean;
    FOnLoad: TNotifyEvent;
    FOnUpdate: TNotifyEvent;
    FSections: THashedStringList;
    FUpdateAtOnce: Boolean;
    // ************************************************ メソッド(private) **
    function FindItem(SectionName, ItemName: string; out Value: string): Integer;
    function FindSectionIndex(SectionName: string): Integer;
    function GetPathString(const Folder: TDefaultFolder): string;
    procedure SaveIniFile(const ARename: Boolean);
    procedure WriteValue(const Section, Item, Value: string);
    // =============================================== プロパティアクセス ==
    function GetAbsoluteFileName: TFileName;
    function GetFullIniFileName: string;
    function GetItems(Section: string): TStrings;
    function GetSectionCount: Integer;
    function GetSections(Index: Integer): string;
    procedure SetCaseSensitive(const Value: Boolean);
    procedure SetDefaultFolder(const Value: TDefaultFolder);
    procedure SetFileName(const Value: TFileName);
    procedure SetUpdateAtOnce(const Value: Boolean);
  protected
    // -------------Protected--
    // ............method..
    // ..........property..
    property FullIniFileName: string read GetFullIniFileName;
    // .............event..
  public
    { Public 宣言 }
    // ************************************************* メソッド(public) **
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure Copy(const Dest: string);
    procedure DeleteItem(const Section, Item: string);
    procedure Erase;
    procedure EraseSection(const Section: string);
    function ItemExists(const Section, Item: string): Boolean;
    function ReadBool(const Section, Item: string;
        const Default: Boolean): Boolean;
    procedure ReadBounds(const Section, Item: string; AControl: TControl);
    function ReadCardinal(const Section, Item: string;
        const Default: Cardinal): Cardinal;
    function ReadColor(const Section, Item: string;
        const Default: TColor): TColor;
    function ReadCurr(const Section, Item: string;
        const Default: Currency): Currency;
    function ReadDate(const Section, Item: string; const Default: TDate): TDate;
    function ReadDateTime(const Section, Item: string;
        const Default: TDateTime): TDateTime;
    function ReadDirectory(const Section, Item, Default: string): string;
    function ReadFloat(const Section, Item: string;
        const Default: Extended): Extended;
    procedure ReadFont(const Section, Item: string; Font: TFont);
    procedure ReadForm(const Section, Item: string; Form: TCustomForm);
    procedure ReadForm2(const Section: string; Form: TCustomForm);
    procedure ReadFormEx(const Section, Item: string; Form: TCustomForm);
    procedure ReadFormEx2(const Section: string; Form: TCustomForm);
    function ReadInt(const Section, Item: string;
        const Default: Integer): Integer;
    function ReadInt64(const Section, Item: string; const Default: Int64): Int64;
    procedure ReadList(const Section, Item: string; List: TStrings);
    procedure ReadPos(const Section, Item: string; AControl: TControl);
    procedure ReadSection(const Section: string; List: TStrings);
    procedure ReadSectionName(List: TStrings);
    procedure ReadSize(const Section, Item: string; AControl: TControl);
    function ReadStr(const Section, Item, Default: string): string;
    function ReadStrEx(const Section, Item, Default, Password: string): string;
    function ReadTime(const Section, Item: string; const Default: TTime): TTime;
    procedure ReadWinPos(const Section, Item: string; Form: TForm);
    procedure ReadWinSize(const Section, Item: string; Form: TForm);
    procedure ReadWinSizeEx(const Section, Item: string; Form: TForm);
    procedure Reload;
    function Rename(const NewFolder: TDefaultFolder;
        const NewName: string): Boolean;
    function RenameSection(const Section, NewSection: string): Boolean;
    function SectionExists(const Section: string): Boolean;
    procedure Update;
    procedure WriteBool(const Section, Item: string; const Value: Boolean);
    procedure WriteBounds(const Section, Item: string; AControl: TControl);
    procedure WriteCardinal(const Section, Item: string; const Value: Cardinal);
    procedure WriteColor(const Section, Item: string; const Value: TColor);
    procedure WriteCurr(const Section, Item: string; const Value: Currency);
    procedure WriteDate(const Section, Item: string; const Value: TDate);
    procedure WriteDateTime(const Section, Item: string; const Value: TDateTime);
    procedure WriteDirectory(const Section, Item, Path: string);
    procedure WriteFloat(const Section, Item: string; const Value: Extended);
    procedure WriteFont(const Section, Item: string; Font: TFont);
    procedure WriteForm(const Section, Item: string; Form: TCustomForm);
    procedure WriteForm2(const Section: string; Form: TCustomForm);
    procedure WriteInt(const Section, Item: string; const Value: Integer);
    procedure WriteInt64(const Section, Item: string; const Value: Int64);
    procedure WriteList(const Section, Item: string; List: TStrings);
    procedure WriteStr(const Section, Item, Value: string);
    procedure WriteStrEx(const Section, Item, Value, Password: string);
    procedure WriteTime(const Section, Item: string; const Value: TTime);
    // *********************************************** プロパティ(public) **
    property AbsoluteFileName: TFileName read GetAbsoluteFileName;
    property Items[Section: string]: TStrings read GetItems;
    property Modified: Boolean read FModified write FModified;
    property SectionCount: Integer read GetSectionCount;
    property Sections[Index: Integer]: string read GetSections;
  published
    { Published 宣言 }
    // ******************************************** プロパティ(published) **
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate default True;
    property CaseSensitive: Boolean read FCaseSensitive
        write SetCaseSensitive default False;
    property DefaultFolder: TDefaultFolder read FDefaultFolder
        write SetDefaultFolder default dfApplication;
    property FileName: TFileName read FFileName write SetFileName;
    property UpdateAtOnce: Boolean read FUpdateAtOnce write SetUpdateAtOnce
        default False;
    // ********************************************************* イベント **
    property OnLoad: TNotifyEvent read FOnLoad write FOnLoad;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TExtIniFile]);
end;

const
  LeftSecMark = '[';
  RightSecMark = ']';
  Key1 = './#%$';
  Key2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

{ TExtIniFile }

// ######################################## バッファをクリア<Clearメソッド> ####
procedure TExtIniFile.Clear;
var
  Lp: Integer;
  Sec: TStringList;
begin
  for Lp := 0 to FSections.Count - 1 do
  begin
    Sec := TStringList(FSections.Objects[Lp]);
    if Assigned(Sec) then Sec.Free;
  end;
  FSections.Clear;
  FModified := True;
end;

// ######################################### ファイルのコピー<Copyメソッド> ####
procedure TExtIniFile.Copy(const Dest: string);
var
  Fs, Fd: TFileStream;
begin
  if FileExists(FullIniFileName) then
  begin
    Fs := TFileStream.Create(FullIniFileName, fmOpenRead or fmShareDenyNone);
    try
      Fd := TFileStream.Create(Dest, fmCreate or fmShareDenyWrite);
      try
        Fd.CopyFrom(Fs, 0);
      finally
        Fd.Free;
      end;
    finally
      Fs.Free;
    end;
  end;
end;

// ######################################### コンストラクタ<Createメソッド> ####
constructor TExtIniFile.Create(AOwner: TComponent);
begin
  inherited;
  // *************************************************** オブジェクト生成 **
  FSections := THashedStringList.Create;
  // *********************************************************** 初期設定 **
  FAppName := ChangeFileExt(ExtractFileName(Application.ExeName), '');
  FDefaultFolder := dfApplication;
  FFileName := '';
  FFolderPath := GetPathString(dfApplication);
  FIniFileName := FAppName + '.ini';
  FAutoUpdate := True;
  // *********************************************************** 読み取り **
  if not (csDesigning in ComponentState) then Reload;
end;

// ##################################### アイテムの削除<DeleteItemメソッド> ####
procedure TExtIniFile.DeleteItem(const Section, Item: string);
var
  Count: Integer;
  Sec: TStringList;
  SecIndex, ItemIndex: Integer;
  S: string;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++ アイテムの削除 ++++
  procedure DelName(const ItemName: string);
  var
    DelIndex: Integer;
  begin
    DelIndex := Sec.IndexOfName(ItemName);
    if DelIndex >= 0 then Sec.Delete(DelIndex);
  end;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
begin
  ItemIndex := FindItem(Section, Item, S);
  if ItemIndex >= 0 then
  begin
    SecIndex := FindSectionIndex(Section);
    Sec := TStringList(FSections.Objects[SecIndex]);
    if Assigned(Sec) then
    begin
      Sec.Delete(ItemIndex);
      Sec.CaseSensitive := FCaseSensitive;
      if AnsiSameText(S, 'FONT') then
      begin
        DelName(Item + '.charset');
        DelName(Item + '.color');
        DelName(Item + '.height');
        DelName(Item + '.name');
        DelName(Item + '.pitch');
        DelName(Item + '.b');
        DelName(Item + '.i');
        DelName(Item + '.u');
        DelName(Item + '.s');
      end;
      if AnsiSameText(S, 'FORM') then
      begin
        DelName(Item + '.flags');
        DelName(Item + '.show');
        DelName(Item + '.state');
        DelName(Item + '.mx');
        DelName(Item + '.my');
        DelName(Item + '.left');
        DelName(Item + '.top');
        DelName(Item + '.right');
        DelName(Item + '.bottom');
        DelName(Item + '.cwidth');
        DelName(Item + '.cheight');
      end;
      if AnsiSameText(S, 'BOUNDS') then
      begin
        DelName(Item + '.left');
        DelName(Item + '.top');
        DelName(Item + '.width');
        DelName(Item + '.height');
      end;
      if AnsiSameText(S, 'LIST') then
      begin
        S := Sec.Values[Item + '.count'];
        Count := StrToIntDef(S, 0);
        DelName(Item + '.count');
        for ItemIndex := 0 to Count - 1 do
          DelName(Item + '.' + IntToStr(ItemIndex));
      end;
      FModified := True;
      if FUpdateAtOnce then Update;
    end;
  end;
end;

// ########################################## デストラクタ<Destroyメソッド> ####
destructor TExtIniFile.Destroy;
begin
  if not (csDesigning in ComponentState) and FAutoUpdate and
     not FUpdateAtOnce then Update;
  // *************************************************** オブジェクト破棄 **
  Clear;
  FSections.Free;
  inherited;
end;

// ###################################### ファイル内容の消去<Eraseメソッド> ####
procedure TExtIniFile.Erase;
begin
  Clear;
  if FUpdateAtOnce then Update;
end;

// ################################# セクションの消去<EraseSectionメソッド> ####
procedure TExtIniFile.EraseSection(const Section: string);
var
  Sec: TStringList;
  SecIndex: Integer;
begin
  SecIndex := FindSectionIndex(Section);
  if SecIndex >= 0 then
  begin
    Sec := TStringList(FSections.Objects[SecIndex]);
    if Assigned(Sec) then Sec.Free;
    FSections.Delete(SecIndex);
    FModified := True;
    if FUpdateAtOnce then Update;
  end;
end;

// ####################################### アイテムの取得<FindItemメソッド> ####
function TExtIniFile.FindItem(SectionName, ItemName: string;
  out Value: string): Integer;
var
  Sec: TStringList;    // セクション内のアイテムリスト
  SecIndex: Integer;   // セクションのインデックス
begin
  Result := -1;
  Value := '';
  SecIndex := FindSectionIndex(SectionName);
  if SecIndex >= 0 then
  begin
    Sec := TStringList(FSections.Objects[SecIndex]);
    if Assigned(Sec) then
    begin
      Sec.CaseSensitive := FCaseSensitive;
      Value := Sec.Values[ItemName];
      Result := Sec.IndexOfName(ItemName);
    end;
  end;
end;

// ############# セクションのインデックスを求める<FindSectionIndexメソッド> ####
function TExtIniFile.FindSectionIndex(SectionName: string): Integer;
begin
  if Length(SectionName) >= 1 then
  begin
    if SectionName[1] <> LeftSecMark then
      SectionName := LeftSecMark + SectionName;
    if SectionName[Length(SectionName)] <> RightSecMark then
      SectionName := SectionName + RightSecMark;
  end;
  Result := FSections.IndexOf(SectionName);
end;

// #### AbsoluteFileNameプロパティ取得<GetAbsoluteFileNameアクセスメソッド> ####
function TExtIniFile.GetAbsoluteFileName: TFileName;
begin
  Result := FullIniFileName;
end;

// =========================================================================
// get: FullIniFileName
function TExtIniFile.GetFullIniFileName: string;
begin
  Result := FFolderPath + FIniFileName;
end;

// #############################################################################
// ##### Itemsプロパティ取得 : GetItemsアクセスメソッド
function TExtIniFile.GetItems(Section: string): TStrings;
var
  SecIndex: Integer;
begin
  SecIndex := FindSectionIndex(Section);
  if SecIndex >= 0 then
    Result := TStringList(FSections.Objects[SecIndex])
  else
    Result := nil;
end;

// ############################ 指定フォルダのパスを取得(GetPathString関数) ####
function TExtIniFile.GetPathString(const Folder: TDefaultFolder): string;
var
  IMem: IMalloc;
  PathStr: array[0..1023] of Char;
  PBuf: PChar;
  PItem: PItemIDList;
begin
  case Folder of
    dfAppData:
      begin
        SHGetMalloc(IMem);
        PBuf := IMem.Alloc(MAX_PATH);
        SHGetSpecialFolderLocation(Application.Handle, CSIDL_APPDATA, PItem);
        SHGetPathFromIDList(PItem, PBuf);
        Result := PBuf;
        IMem.Free(PBuf);
        IMem.Free(PItem);
        Result := IncludeTrailingPathDelimiter(Result) + FAppName;
      end;
    dfApplication: Result := ExtractFilePath(Application.ExeName);
    dfUser       : Result := '';
    else
      begin
        GetWindowsDirectory(PathStr, SizeOf(PathStr));
        Result := PathStr;
      end;
  end;
  if Result <> '' then
  begin
    Result := IncludeTrailingPathDelimiter(Result);
    if not DirectoryExists(Result) then ForceDirectories(Result);
  end;
end;

// ############ SectionCountプロパティ取得<GetSectionCountアクセスメソッド> ####
function TExtIniFile.GetSectionCount: Integer;
begin
  Result := FSections.Count;
end;

// #################### Sectionsプロパティ取得<GetSectionsアクセスメソッド> ####
function TExtIniFile.GetSections(Index: Integer): string;
begin
  if (Index >= 0) and (Index < FSections.Count) then
  begin
    Result := FSections.Strings[Index];
    Result := System.Copy(Result, 2, Length(Result) - 2);
  end
  else
    Result := '';
end;

// ################################# アイテムの存在確認<ItemExistsメソッド> ####
function TExtIniFile.ItemExists(const Section, Item: string): Boolean;
var
  ItemValue: string;
begin
  Result := (FindItem(Section, Item, ItemValue) >= 0);
end;

// ################################## Boolean型の読み取り<ReadBoolメソッド> ####
function TExtIniFile.ReadBool(const Section, Item: string;
  const Default: Boolean): Boolean;
var
  S: string;
begin
  if FindItem(Section, Item, S) = -1 then
    Result := Default
  else
    Result := (S = '1') or SameText(S, 'true');
end;

// ################### コントロールの位置とサイズを取得<ReadBoundsメソッド> ####
procedure TExtIniFile.ReadBounds(const Section, Item: string;
  AControl: TControl);
var
  ALeft, ATop, AWidth, AHeight: Integer;
begin
  ALeft := ReadInt(Section, Item + '.left', AControl.Left);
  ATop := ReadInt(Section, Item + '.top', AControl.Top);
  AWidth := ReadInt(Section, Item + '.width', AControl.Width);
  AHeight := ReadInt(Section, Item + '.height', AControl.Height);
  AControl.SetBounds(ALeft, ATop, AWidth, AHeight);
end;

// ############################# Cardinal型の読み取り<ReadCardinalメソッド> ####
function TExtIniFile.ReadCardinal(const Section, Item: string;
  const Default: Cardinal): Cardinal;
var
  S: string;
begin
  if FindItem(Section, Item, S) = -1 then
    Result := Default
  else
    Result := Cardinal(StrToInt64Def(S, Default));
end;

// #################################### カラーの読み取り<ReadColorメソッド> ####
function TExtIniFile.ReadColor(const Section, Item: string;
  const Default: TColor): TColor;
var
  ColInt: LongInt;
begin
  ColInt := Default;
  ColInt := ReadInt(Section, Item, ColInt);
  Result := ColInt;
end;

// ################################# Currency型の読み取り<ReadCurrメソッド> ####
function TExtIniFile.ReadCurr(const Section, Item: string;
  const Default: Currency): Currency;
var
  CurrFormat: TFormatSettings;
  S: string;
begin
  if FindItem(Section, Item, S) = -1 then
    Result := Default
  else
  begin
    GetLocaleFormatSettings(GetUserDefaultLCID, CurrFormat);
    if not TryStrToCurr(S, Result, CurrFormat) then Result := Default;
  end;
end;

// #################################### TDate型の読み取り<ReadDateメソッド> ####
function TExtIniFile.ReadDate(const Section, Item: string;
  const Default: TDate): TDate;
var
  ADate: TDateTime;
  DateValue: Double;
  Y, M, D: Word;
begin
  DateValue := Default;
  DateValue := ReadFloat(Section, Item, DateValue);
  if not TryFloatToDateTime(DateValue, ADate) then
    Result := Default
  else
  begin
    DecodeDate(ADate, Y, M, D);
    Result := EncodeDate(Y, M, D);
  end;
end;

// ############################ TDateTime型の読み取り<ReadDateTimeメソッド> ####
function TExtIniFile.ReadDateTime(const Section, Item: string;
  const Default: TDateTime): TDateTime;
var
  DateValue: Double;
begin
  DateValue := Default;
  DateValue := ReadFloat(Section, Item, DateValue);
  if not TryFloatToDateTime(DateValue, Result) then Result := Default;
end;

// ==========================================================================
// == method: フォルダパスの読み取り                                     ====
// ==========================================================================
function TExtIniFile.ReadDirectory(const Section, Item,
  Default: string): string;
begin
  if FindItem(Section, Item, Result) = -1 then Result := Default;
  if Result <> '' then Result := IncludeTrailingPathDelimiter(Result);
end;

// #################################### 実数型の読み取り<ReadFloatメソッド> ####
function TExtIniFile.ReadFloat(const Section, Item: string;
  const Default: Extended): Extended;
var
  Ft: TFormatSettings;
  S: string;
begin
  if FindItem(Section, Item, S) = -1 then
    Result := Default
  else
  begin
    GetLocaleFormatSettings(GetUserDefaultLCID, Ft);
    if not TryStrToFloat(S, Result, Ft) then Result := Default;
  end;
end;

// ################################### フォントの読み取り<ReadFontメソッド> ####
procedure TExtIniFile.ReadFont(const Section, Item: string; Font: TFont);
var
  Pitch: Integer;
  S: string;
begin
  // ************************************************************ CharSet **
  if FindItem(Section, Item + '.charset', S) >= 0 then
    Font.Charset := Byte(StrToIntDef(S, Font.Charset));
  // ******************************************************* Color/Height **
  Font.Color := ReadColor(Section, Item + '.color', Font.Color);
  Font.Height := ReadInt(Section, Item + '.height', Font.Height);
  // *************************************************************** Name **
  if FindItem(Section, Item + '.name', S) >= 0 then Font.Name := S;
  // ************************************************************** Pitch **
  Pitch := ReadInt(Section, Item + '.pitch', Ord(Font.Pitch));
  case Pitch of
    Ord(fpDefault): Font.Pitch := fpDefault;
    Ord(fpFixed)  : Font.Pitch := fpFixed;
    else
      Font.Pitch := fpVariable;
  end;
  // ************************************************************** Style **
  if ReadBool(Section, Item + '.b', fsBold in Font.Style) then
    Font.Style := Font.Style + [fsBold]
  else
    Font.Style := Font.Style - [fsBold];
  if ReadBool(Section, Item + '.i', fsItalic in Font.Style) then
    Font.Style := Font.Style + [fsItalic]
  else
    Font.Style := Font.Style - [fsItalic];
  if ReadBool(Section, Item + '.u', fsUnderline in Font.Style) then
    Font.Style := Font.Style + [fsUnderline]
  else
    Font.Style := Font.Style - [fsUnderline];
  if ReadBool(Section, Item + '.s', fsStrikeOut in Font.Style) then
    Font.Style := Font.Style + [fsStrikeOut]
  else
    Font.Style := Font.Style - [fsStrikeOut];
end;

// ####################### フォーム位置とサイズの読み取り<ReadFormメソッド> ####
procedure TExtIniFile.ReadForm(const Section, Item: string; Form: TCustomForm);
var
  State: Integer;
  Wp: TWindowPlacement;
begin
  // ************************************************************* 初期化 **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // *********************************************************** 読み取り **
  with Wp do
  begin
    flags := ReadCardinal(Section, Item + '.flags', flags);
    // ===================================================== 最大化の位置 ==
    ptMaxPosition.X := ReadInt(Section, Item + '.mx', ptMaxPosition.X);
    ptMaxPosition.Y := ReadInt(Section, Item + '.my', ptMaxPosition.Y);
    // =================================================== フォームの座標 ==
    with rcNormalPosition do
    begin
      Left := ReadInt(Section, Item + '.left', Left);
      Top := ReadInt(Section, Item + '.top', Top);
      Right := ReadInt(Section, Item + '.right', Right);
      Bottom := ReadInt(Section, Item + '.bottom', Bottom);
    end;
    // ========================================================= 表示状態 ==
    showCmd := ReadCardinal(Section, Item + '.show', showCmd);
    if not Form.Showing then
    begin
      showCmd := SW_HIDE;
      SetWindowPlacement(Form.Handle, @Wp);
      State := ReadInt(Section, Item + '.state', Ord(wsNormal));
      case State of
        Ord(wsNormal)   : Form.WindowState := wsNormal;
        Ord(wsMaximized): Form.WindowState := wsMaximized;
        else
          Form.WindowState := wsNormal;
      end;
    end
    else
      SetWindowPlacement(Form.Handle, @Wp);
  end;
end;

// #############################################################################
// ## Method: フォームの読み取り
procedure TExtIniFile.ReadForm2(const Section: string; Form: TCustomForm);
begin
  ReadForm(Section, Form.Name, Form);
end;

// ##################### フォーム位置とサイズの読み取り<ReadFormExメソッド> ####
procedure TExtIniFile.ReadFormEx(const Section, Item: string; Form: TCustomForm);
begin
  ReadForm(Section, Item, Form);
  Form.ClientWidth := ReadInt(Section, Item + '.cwidth', Form.ClientWidth);
  Form.ClientHeight := ReadInt(Section, Item + '.cheight', Form.ClientHeight);
end;

// #############################################################################
// ## Method: フォームの読み取り
procedure TExtIniFile.ReadFormEx2(const Section: string; Form: TCustomForm);
begin
  ReadFormEx(Section, Form.Name, Form);
end;

// ################################### Integer型の読み取り<ReadIntメソッド> ####
function TExtIniFile.ReadInt(const Section, Item: string;
  const Default: Integer): Integer;
var
  S: string;
begin
  if FindItem(Section, Item, S) = -1 then
    Result := Default
  else
  begin
    if Length(S) >= 2 then
      if (S[1] = '0') and SameText(S[2], 'x') then
        S := '$' + System.Copy(S, 3, Length(S) - 2);
    Result := StrToIntDef(S, Default);
  end;
end;

// ################################### Int64型の読み取り<ReadInt64メソッド> ####
function TExtIniFile.ReadInt64(const Section, Item: string;
  const Default: Int64): Int64;
var
  S: string;
begin
  if FindItem(Section, Item, S) = -1 then
    Result := Default
  else
    Result := StrToInt64Def(S, Default);
end;

// ############################### 文字列リストの読み取り<ReadListメソッド> ####
procedure TExtIniFile.ReadList(const Section, Item: string;
  List: TStrings);
var
  Count: Integer;
  Lp: Integer;
  S: string;
begin
  List.Clear;
  Count := ReadInt(Section, Item + '.count', 0);
  for Lp := 0 to Count - 1 do
    if FindItem(Section, Item + '.' + IntToStr(Lp), S) >= 0 then
      List.Append(S);
end;

// ############################## コントロールの位置を取得<ReadPosメソッド> ####
procedure TExtIniFile.ReadPos(const Section, Item: string;
  AControl: TControl);
var
  ALeft, ATop: Integer;
begin
  ALeft := ReadInt(Section, Item + '.left', AControl.Left);
  ATop := ReadInt(Section, Item + '.top', AControl.Top);
  AControl.SetBounds(ALeft, ATop, AControl.Width, AControl.Height);
end;

// ################## セクションのアイテムリストを取得<ReadSectionメソッド> ####
procedure TExtIniFile.ReadSection(const Section: string; List: TStrings);
var
  Sec: TStringList;
  SecIndex: Integer;
begin
  SecIndex := FindSectionIndex(Section);
  List.Clear;
  if SecIndex >= 0 then
  begin
    Sec := TStringList(FSections.Objects[SecIndex]);
    if Assigned(Sec) then List.AddStrings(Sec);
  end;
end;

// ###################### セクションのリストを取得<ReadSectionNameメソッド> ####
procedure TExtIniFile.ReadSectionName(List: TStrings);
var
  Lp: Integer;
  S: string;
begin
  List.Clear;
  if FSections.Count >= 1 then
  for Lp := 0 to FSections.Count - 1 do
  begin
    S := FSections.Strings[Lp];
    if Length(S) >= 2 then
      if (S[1] = LeftSecMark) and (S[Length(S)] = RightSecMark) then
        S := System.Copy(S, 2, Length(S) - 2);
    List.Append(S);
  end;
end;

// ########################### コントロールのサイズを取得<ReadSizeメソッド> ####
procedure TExtIniFile.ReadSize(const Section, Item: string;
  AControl: TControl);
var
  AWidth, AHeight: Integer;
begin
  AWidth := ReadInt(Section, Item + '.width', AControl.Width);
  AHeight := ReadInt(Section, Item + '.height', AControl.Height);
  AControl.SetBounds(AControl.Left, AControl.Top, AWidth, AHeight);
end;

// ###################################### 文字列の読み取り<ReadStrメソッド> ####
function TExtIniFile.ReadStr(const Section, Item, Default: string): string;
begin
  if FindItem(Section, Item, Result) = -1 then Result := Default;
end;

// #################################### デコード読み取り<ReadStrExメソッド> ####
function TExtIniFile.ReadStrEx(const Section, Item, Default,
  Password: string): string;
var
  APos, BPos: Integer;
  Len, LenPass: Integer;
  Lp, LPass: Integer;
  Pass: string;
  St, S1, S2: string;
begin
  if FindItem(Section, Item, St) = -1 then
    Result := Default
  else
  begin
    // ********************************************************* デコード **
    Pass := '';
    for Lp := 1 to Length(Password) do
    begin
      APos := Ord(Password[Lp]);
      Pass := Pass + IntToHex(APos, 2);
    end;
    Len := Length(Key2);
    LenPass := Length(Pass);
    LPass := 1;
    Result := '';
    for Lp := 1 to Length(St) div 2 do
    begin
      S1 := St[(Lp - 1) * 2 + 1];
      S2 := St[Lp * 2];
      APos := Pos(S1, Key1) - 1;
      BPos := Pos(S2, Key2) - 1;
      if LPass <= LenPass then
      begin
        BPos := BPos - StrToInt('$' + Pass[LPass]);
        if BPos < 0 then Inc(BPos, Len);
      end;
      APos := Len * APos + BPos;
      Result := Result + Chr(Byte(APos));
      Inc(LPass);
      if LPass > LenPass then LPass := 1;
    end;
  end;
end;

// #################################### TTime型の読み取り<ReadTimeメソッド> ####
function TExtIniFile.ReadTime(const Section, Item: string;
  const Default: TTime): TTime;
var
  ATime: TDateTime;
  DateValue: Double;
  H, M, S, Ms: Word;
begin
  DateValue := Default;
  DateValue := ReadFloat(Section, Item, DateValue);
  if TryFloatToDateTime(DateValue, ATime) then
  begin
    DecodeTime(ATime, H, M, S, Ms);
    Result := EncodeTime(H, M, S, Ms);
  end
  else
    Result := Default;
end;

// ############################# フォーム位置の読み取り<ReadWinPosメソッド> ####
procedure TExtIniFile.ReadWinPos(const Section, Item: string; Form: TForm);
begin
  Form.Left := ReadInt(Section, Item + '.left', Form.Left);
  Form.Top := ReadInt(Section, Item + '.top', Form.Top);
end;

// ########################## フォームサイズの読み取り<ReadWinSizeメソッド> ####
procedure TExtIniFile.ReadWinSize(const Section, Item: string;
  Form: TForm);
var
  ARect: TRect;
  State: Integer;
  Wp: TWindowPlacement;
begin
  // *************************************************************** 準備 **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // *********************************************************** 読み取り **
  with Wp do
  begin
    flags := ReadCardinal(Section, Item + '.flags', flags);
    ptMaxPosition.X := ReadInt(Section, Item + '.mx', ptMaxPosition.X);
    ptMaxPosition.Y := ReadInt(Section, Item + '.mx', ptMaxPosition.Y);
    with ARect do
    begin
      Left := ReadInt(Section, Item + '.left', rcNormalPosition.Left);
      Top := ReadInt(Section, Item + '.top', rcNormalPosition.Top);
      Right := ReadInt(Section, Item + '.right', rcNormalPosition.Right);
      Bottom := ReadInt(Section, Item + '.bottom', rcNormalPosition.Bottom);
    end;
    with rcNormalPosition do
    begin
      Right := Left + (ARect.Right - ARect.Left);
      Bottom := Top + (ARect.Bottom - ARect.Top);
    end;
    showCmd := ReadCardinal(Section, Item + '.show', showCmd);
    if not Form.Showing then
    begin
      showCmd := SW_HIDE;
      SetWindowPlacement(Form.Handle, @Wp);
      State := ReadInt(Section, Item + '.state', Ord(wsNormal));
      case State of
        Ord(wsNormal)   : Form.WindowState := wsNormal;
        Ord(wsMaximized): Form.WindowState := wsMaximized;
        else
          Form.WindowState := wsNormal;
      end;
    end
    else
      SetWindowPlacement(Form.Handle, @Wp);
  end;
end;

// ############ フォームクライアントサイズの読み取り<ReadWinSizeExメソッド> ####
procedure TExtIniFile.ReadWinSizeEx(const Section, Item: string;
  Form: TForm);
begin
  ReadWinSize(Section, Item, Form);
  Form.ClientWidth := ReadInt(Section, Item + '.cwidth', Form.ClientWidth);
  Form.ClientHeight := ReadInt(Section, Item + '.cheight', Form.ClientHeight);
end;

// ############################### ファイルの内容を読み込む<Reloadメソッド> ####
procedure TExtIniFile.Reload;
var
  Flag: Boolean;
  Fs: TFileStream;
  Index: Integer;         // 追加位置
  Ini, Sec: TStringList;
  Lp: Integer;
  S: string;
begin
  // *************************************************** 現在の内容を破棄 **
  Clear;
  FModified := False;
  // *********************************************************** 読み込み **
  if FileExists(FullIniFileName) then
  try
    Ini := TStringList.Create;
    try
      Fs := TFileStream.Create(FullIniFileName, fmOpenRead or fmShareDenyNone);
      try
        Ini.LoadFromStream(Fs);
      finally
        Fs.Free;
      end;
      // ************************************************* バッファの構築 **
      Sec := nil;
      Flag := False;
      for Lp := 0 to Ini.Count - 1 do
      begin
        S := Ini.Strings[Lp];
        if Length(S) >= 2 then
        begin
          if (S[1] = LeftSecMark) and (S[Length(S)] = RightSecMark) then
          begin
            Index := FSections.Add(S);
            FSections.Objects[Index] := TStringList.Create;
            Sec := TStringList(FSections.Objects[Index]);
            Flag := True;
          end
          else if Flag and Assigned(Sec) then
            Sec.Append(S);
        end;
      end;
    finally
      Ini.Free;
    end;
    if Assigned(FOnLoad) then FOnLoad(Self);
  except
    //
  end;
end;

// ####################################### ファイル名の変更<Renameメソッド> ####
function TExtIniFile.Rename(const NewFolder: TDefaultFolder;
  const NewName: string): Boolean;
var
  NewFileName: string;
begin
  // *********************************************** 新しいフォルダを取得 **
  NewFileName := GetPathString(NewFolder);
  if NewFolder = dfUser then NewFileName := ExtractFilePath(NewName);
  // ******************************************* フォルダの存在確認と作成 **
  if not DirectoryExists(NewFileName) then ForceDirectories(NewFileName);
  Result := DirectoryExists(NewFileName);
  // *********************************************** ファイル名の変更処理 **
  if Result then
  begin
    if NewFolder = dfUser then
      NewFileName := NewName
    else
      NewFileName := NewFileName + NewName;
    // ================================================= ファイルのコピー ==
    Copy(NewFileName);
    // =============================================== 元のファイルを削除 ==
    SysUtils.DeleteFile(FullIniFileName);
    // ================================================= プロパティの変更 ==
    FDefaultFolder := NewFolder;
    FFileName := NewName;
    FIniFileName := ExtractFileName(NewFileName);
    FFolderPath := ExtractFilePath(NewFileName);
  end;
end;

// #############################################################################
// ##### RenameSectionメソッド
function TExtIniFile.RenameSection(const Section,
  NewSection: string): Boolean;
var
  SecIndex: Integer;
begin
  if SectionExists(Section) and not SectionExists(NewSection) then
  begin
    SecIndex := FindSectionIndex(Section);
    FSections.Strings[SecIndex] := NewSection;
    FModified := True;
    Result := True;
  end
  else
    Result := False;
end;

// ################################# INIファイルの保存<SaveIniFileメソッド> ####
procedure TExtIniFile.SaveIniFile(const ARename: Boolean);
var
  Fs: TFileStream;
  Ini, Sec: TStringList;
  Lp: Integer;
begin
  // ***************************************** 保存用のオブジェクトを作成 **
  Ini := TStringList.Create;
  try
    try
      for Lp := 0 to FSections.Count - 1 do
      begin
        Ini.Append(FSections.Strings[Lp]);
        Sec := TStringList(FSections.Objects[Lp]);
        if Assigned(Sec) then Ini.AddStrings(Sec);
        Ini.Append('');
      end;
      // *********************************************************** 保存 **
      if not ARename or (Ini.Count >= 1) then
      begin
        Fs := TFileStream.Create(FullIniFileName, fmCreate or fmShareDenyWrite);
        try
          Ini.SaveToStream(Fs);
        finally
          Fs.Free;
        end;
      end;
    finally
      Ini.Free;
    end;
    FModified := False;
  except
    //
  end;
end;

// ############################ セクションの存在確認<SectionExistsメソッド> ####
function TExtIniFile.SectionExists(const Section: string): Boolean;
begin
  Result := (FindSectionIndex(Section) >= 0);
end;

// ########## CaseSensitiveプロパティ設定<SetCaseSensitiveアクセスメソッド> ####
procedure TExtIniFile.SetCaseSensitive(const Value: Boolean);
begin
  FCaseSensitive := Value;
  FSections.CaseSensitive := Value;
end;

// ########## DefaultFolderプロパティ設定<SetDefaultFolderアクセスメソッド> ####
procedure TExtIniFile.SetDefaultFolder(const Value: TDefaultFolder);
begin
  if not (csDesigning in ComponentState) then
  begin
    // ***************************************************** ファイル保存 **
    if FAutoUpdate then SaveIniFile(True);
    // ************************************************* 新しい名前の取得 **
    FFolderPath := GetPathString(Value);
    // ********************************************************* 読み込み **
    Reload;
  end
  else
    FFolderPath := GetPathString(Value);
  FDefaultFolder := Value;
end;

// #################### FileNameプロパティ設定<SetFileNameアクセスメソッド> ####
procedure TExtIniFile.SetFileName(const Value: TFileName);
begin
  FFileName := Value;
  if not (csDesigning in ComponentState) then
  begin
    // ********************************************* 現在の内容を書き込み **
    if FAutoUpdate then SaveIniFile(True);
    // ******************************************* 新しいファイル名を取得 **
    FIniFileName := FFileName;
    if FIniFileName = '' then FIniFileName := FAppName + '.ini';
    // *************************************** 新しいファイルの内容を取得 **
    Reload;
  end
  else
  begin
    FIniFileName := FFileName;
    if FIniFileName = '' then FIniFileName := FAppName + '.ini';
  end;
end;

// ############ UpdateAtOnceプロパティ設定<SetUpdateAtOnceアクセスメソッド> ####
procedure TExtIniFile.SetUpdateAtOnce(const Value: Boolean);
begin
  FUpdateAtOnce := Value;
  if Value and (not (csDesigning in ComponentState)) then Update;
end;

// ############################### バッファをファイルに保存<Updateメソッド> ####
procedure TExtIniFile.Update;
begin
  SaveIniFile(False);
  if Assigned(FOnUpdate) then FOnUpdate(Self);
end;

// #################################### 論理型の書き込み<WriteBoolメソッド> ####
procedure TExtIniFile.WriteBool(const Section, Item: string;
  const Value: Boolean);
var
  S: string;
begin
  if Value then S := '1' else S := '0';
  WriteValue(Section, Item, S);
  if FUpdateAtOnce then Update;
end;

// ############## コントロールの位置とサイズの書き込み<WriteBoundsメソッド> ####
procedure TExtIniFile.WriteBounds(const Section, Item: string;
  AControl: TControl);
begin
  WriteValue(Section, Item, 'BOUNDS');
  WriteValue(Section, Item + '.left', IntToStr(AControl.Left));
  WriteValue(Section, Item + '.top', IntToStr(AControl.Top));
  WriteValue(Section, Item + '.width', IntToStr(AControl.Width));
  WriteValue(Section, Item + '.height', IntToStr(AControl.Height));
  if FUpdateAtOnce then Update;
end;

// ############################ Cardinal型の書き込み<WriteCardinalメソッド> ####
procedure TExtIniFile.WriteCardinal(const Section, Item: string;
  const Value: Cardinal);
begin
  WriteValue(Section, Item, IntToStr(Value));
  if FUpdateAtOnce then Update;
end;

// ################################### カラーの書き込み<WriteColorメソッド> ####
procedure TExtIniFile.WriteColor(const Section, Item: string;
  const Value: TColor);
var
  S: string;
begin
  S := '$' + IntToHex(LongInt(Value), 8);
  WriteValue(Section, Item, S);
  if FUpdateAtOnce then Update;
end;

// ################################ Currency型の書き込み<WriteCurrメソッド> ####
procedure TExtIniFile.WriteCurr(const Section, Item: string;
  const Value: Currency);
var
  S: string;
  FormatSettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID, FormatSettings);
  S := CurrToStr(Value, FormatSettings);
  WriteValue(Section, Item, S);
  if FUpdateAtOnce then Update;
end;

// ###################################### 日付の書き込み<WriteDateメソッド> ####
procedure TExtIniFile.WriteDate(const Section, Item: string;
  const Value: TDate);
begin
  WriteFloat(Section, Item, Double(Value));
end;

// ########################### TDateTime型の書き込み<WriteDateTimeメソッド> ####
procedure TExtIniFile.WriteDateTime(const Section, Item: string;
  const Value: TDateTime);
begin
  WriteFloat(Section, Item, Double(Value));
end;

// ==========================================================================
// == method: フォルダパスの書き込み                                     ====
// ==========================================================================
procedure TExtIniFile.WriteDirectory(const Section, Item, Path: string);
begin
  if Path = '' then
    WriteValue(Section, Item, Path)
  else
    WriteValue(Section, Item, IncludeTrailingPathDelimiter(Path));
end;

// ##################################### 実数の書き込み<WriteFloatメソッド> ####
procedure TExtIniFile.WriteFloat(const Section, Item: string;
  const Value: Extended);
var
  FormatSettings: TFormatSettings;
  S: string;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID, FormatSettings);
  S := FloatToStr(Value, FormatSettings);
  WriteValue(Section, Item, S);
  if FUpdateAtOnce then Update;
end;

// ################################## フォントの書き込み<WriteFontメソッド> ####
procedure TExtIniFile.WriteFont(const Section, Item: string; Font: TFont);
var
  S: string;
begin
  // ************************************************************* 識別子 **
  WriteValue(Section, Item, 'FONT');
  // *************************************************** キャラクタセット **
  S := IntToStr(Font.Charset);
  WriteValue(Section, Item + '.charset', S);
  // ************************************************************* カラー **
  S := '$' + IntToHex(Font.Color, 8);
  WriteValue(Section, Item + '.color', S);
  // *************************************************************** 高さ **
  S := IntToStr(Font.Height);
  WriteValue(Section, Item + '.height', S);
  // *************************************************************** 名前 **
  WriteValue(Section, Item + '.name', Font.Name);
  // ************************************************************* ピッチ **
  S := IntToStr(Ord(Font.Pitch));
  WriteValue(Section, Item + '.pitch', S);
  // *********************************************************** スタイル **
  // =========================================================== ボールド ==
  if fsBold in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.b', S);
  // ========================================================= イタリック ==
  if fsItalic in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.i', S);
  // ===================================================== アンダーライン ==
  if fsUnderline in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.u', S);
  // ========================================================= 打ち消し線 ==
  if fsStrikeOut in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.s', S);
  if FUpdateAtOnce then Update;
end;

// ############################## フォーム情報の書き込み<WriteFormメソッド> ####
procedure TExtIniFile.WriteForm(const Section, Item: string; Form: TCustomForm);
var
  Wp: TWindowPlacement;
begin
  // ************************************************* フォーム情報の取得 **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // ***************************************************** 情報の書き込み **
  WriteValue(Section, Item, 'FORM');
  with Wp do
  begin
    WriteValue(Section, Item + '.flags', IntToStr(flags));
    WriteValue(Section, Item + '.show', IntToStr(showCmd));
    WriteValue(Section, Item + '.mx', IntToStr(ptMaxPosition.X));
    WriteValue(Section, Item + '.my', IntToStr(ptMaxPosition.Y));
    with rcNormalPosition do
    begin
      WriteValue(Section, Item + '.left', IntToStr(Left));
      WriteValue(Section, Item + '.top', IntToStr(Top));
      WriteValue(Section, Item + '.right', IntToStr(Right));
      WriteValue(Section, Item + '.bottom', IntToStr(Bottom));
    end;
  end;
  WriteValue(Section, Item + '.state', IntToStr(Ord(Form.WindowState)));
  WriteValue(Section, Item + '.cwidth', IntToStr(Form.ClientWidth));
  WriteValue(Section, Item + '.cheight', IntToStr(Form.ClientHeight));
  if FUpdateAtOnce then Update;
end;

// #############################################################################
// ## Method: フォームの書き込み
procedure TExtIniFile.WriteForm2(const Section: string; Form: TCustomForm);
begin
  WriteForm(Section, Form.Name, Form);
end;

// ################################## Integer型の書き込み<WriteIntメソッド> ####
procedure TExtIniFile.WriteInt(const Section, Item: string;
  const Value: Integer);
begin
  WriteValue(Section, Item, IntToStr(Value));
  if FUpdateAtOnce then Update;
end;

// ################################## Int64型の書き込み<WriteInt64メソッド> ####
procedure TExtIniFile.WriteInt64(const Section, Item: string;
  const Value: Int64);
begin
  WriteValue(Section, Item, IntToStr(Value));
  if FUpdateAtOnce then Update;
end;

// ############################## 文字列リストの書き込み<WriteListメソッド> ####
procedure TExtIniFile.WriteList(const Section, Item: string;
  List: TStrings);
var
  Lp: Integer;
  OldCount: Integer;  // 既存リストの項目数
  S: string;
begin
  // *************************************************** 既存リストの検索 **
  FindItem(Section, Item + '.count', S);
  OldCount := StrToIntDef(S, 0);
  // *********************************************************** 書き込み **
  WriteValue(Section, Item, 'LIST');
  WriteValue(Section, Item + '.count', IntToStr(List.Count));
  for Lp := 0 to List.Count - 1 do
    WriteValue(Section, Item + '.' + IntToStr(Lp), List.Strings[Lp]);
  // ************************************************* 不要なリストを削除 **
  for Lp := OldCount downto List.Count + 1 do
    DeleteItem(Section, Item + '.' + IntToStr(Lp - 1));
  if FUpdateAtOnce then Update;
end;

// ##################################### 文字列の書き込み<WriteStrメソッド> ####
procedure TExtIniFile.WriteStr(const Section, Item, Value: string);
begin
  WriteValue(Section, Item, Value);
  if FUpdateAtOnce then Update;
end;

// ##################### エンコードした文字列の書き込み<WriteStrExメソッド> ####
procedure TExtIniFile.WriteStrEx(const Section, Item, Value,
  Password: string);
var
  APos, BPos: Integer;
  LenPass, Len: Integer;
  Lp, LPass: Integer;
  Pass, S: string;
begin
  // ********************************************************* エンコード **
  Pass := '';
  for Lp := 1 to Length(Password) do
  begin
    Pass := Pass + IntToHex(Ord(Password[Lp]), 2);
  end;
  LenPass := Length(Pass);
  Len := Length(Key2);
  S := '';
  LPass := 1;
  for Lp := 1 to Length(Value) do
  begin
    APos := Ord(Value[Lp]) div Len + 1;
    BPos := Ord(Value[Lp]) mod Len;
    if LPass <= LenPass then
    begin
      BPos := BPos + StrToInt('$' + Pass[LPass]);
      if BPos >= Len then Dec(BPos, Len);
    end;
    Inc(BPos);
    S := S + Key1[APos] + Key2[BPos];
    if LPass >= LenPass then LPass := 1 else Inc(LPass);
  end;
  WriteStr(Section, Item, S);
end;

// ###################################### 時刻の書き込み<WriteTimeメソッド> ####
procedure TExtIniFile.WriteTime(const Section, Item: string;
  const Value: TTime);
begin
  WriteFloat(Section, Item, Double(Value));
end;

// ########################### 文字列をリストに書き込む<WriteValueメソッド> ####
procedure TExtIniFile.WriteValue(const Section, Item, Value: string);
var
  SecIndex: Integer;
  ItemIndex: Integer;
  ItemValue: string;
  Sec: TStringList;
  S: string;
begin
  // ***************************************************** アイテムの検索 **
  SecIndex := FindSectionIndex(Section);
  // ******************************* セクションもなければセクションを追加 **
  if SecIndex = -1 then
  begin
    ItemValue := Section;
    if Length(ItemValue) >= 1 then
    begin
      if ItemValue[1] <> LeftSecMark then ItemValue := LeftSecMark + ItemValue;
      if ItemValue[Length(ItemValue)] <> RightSecMark then
        ItemValue := ItemValue + RightSecMark;
    end;
    SecIndex := FSections.Add(ItemValue);
    FSections.Objects[SecIndex] := TStringList.Create;
  end;
  // *********************************** セクションのアイテムリストを取得 **
  Sec := TStringList(FSections.Objects[SecIndex]);
  if Sec = nil then
  begin
    FSections.Objects[SecIndex] := TStringList.Create;
    Sec := TStringList(FSections.Objects[SecIndex]);
  end;
  if Value = '' then
  begin
    S := Item + '=';
    ItemIndex := Sec.IndexOfName(Item);
    if ItemIndex >= 0 then Sec.Delete(ItemIndex);
    Sec.Append(S);
  end
  else
    Sec.Values[Item] := Value;
  FModified := True;
end;

end.
 