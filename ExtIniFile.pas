unit ExtIniFile;

// ExtIniFile Version 1.5.1           copyright(c) �݂�, 2002-2008

interface

uses
  SysUtils, Classes, IniFiles, Forms, ShlObj, ActiveX, Windows, Graphics,
  Controls, System.UITypes;

type
  TDefaultFolder = (dfAppData, dfApplication, dfUser, dfWindows);

  TExtIniFile = class(TComponent)
  private
    { Private �錾 }
    // ******************************************************* �t�B�[���h **
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
    // ************************************************ ���\�b�h(private) **
    function FindItem(SectionName, ItemName: string; out Value: string): Integer;
    function FindSectionIndex(SectionName: string): Integer;
    function GetPathString(const Folder: TDefaultFolder): string;
    procedure SaveIniFile(const ARename: Boolean);
    procedure WriteValue(const Section, Item, Value: string);
    // =============================================== �v���p�e�B�A�N�Z�X ==
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
    { Public �錾 }
    // ************************************************* ���\�b�h(public) **
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
    // *********************************************** �v���p�e�B(public) **
    property AbsoluteFileName: TFileName read GetAbsoluteFileName;
    property Items[Section: string]: TStrings read GetItems;
    property Modified: Boolean read FModified write FModified;
    property SectionCount: Integer read GetSectionCount;
    property Sections[Index: Integer]: string read GetSections;
  published
    { Published �錾 }
    // ******************************************** �v���p�e�B(published) **
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate default True;
    property CaseSensitive: Boolean read FCaseSensitive
        write SetCaseSensitive default False;
    property DefaultFolder: TDefaultFolder read FDefaultFolder
        write SetDefaultFolder default dfApplication;
    property FileName: TFileName read FFileName write SetFileName;
    property UpdateAtOnce: Boolean read FUpdateAtOnce write SetUpdateAtOnce
        default False;
    // ********************************************************* �C�x���g **
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

// ######################################## �o�b�t�@���N���A<Clear���\�b�h> ####
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

// ######################################### �t�@�C���̃R�s�[<Copy���\�b�h> ####
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

// ######################################### �R���X�g���N�^<Create���\�b�h> ####
constructor TExtIniFile.Create(AOwner: TComponent);
begin
  inherited;
  // *************************************************** �I�u�W�F�N�g���� **
  FSections := THashedStringList.Create;
  // *********************************************************** �����ݒ� **
  FAppName := ChangeFileExt(ExtractFileName(Application.ExeName), '');
  FDefaultFolder := dfApplication;
  FFileName := '';
  FFolderPath := GetPathString(dfApplication);
  FIniFileName := FAppName + '.ini';
  FAutoUpdate := True;
  // *********************************************************** �ǂݎ�� **
  if not (csDesigning in ComponentState) then Reload;
end;

// ##################################### �A�C�e���̍폜<DeleteItem���\�b�h> ####
procedure TExtIniFile.DeleteItem(const Section, Item: string);
var
  Count: Integer;
  Sec: TStringList;
  SecIndex, ItemIndex: Integer;
  S: string;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++ �A�C�e���̍폜 ++++
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

// ########################################## �f�X�g���N�^<Destroy���\�b�h> ####
destructor TExtIniFile.Destroy;
begin
  if not (csDesigning in ComponentState) and FAutoUpdate and
     not FUpdateAtOnce then Update;
  // *************************************************** �I�u�W�F�N�g�j�� **
  Clear;
  FSections.Free;
  inherited;
end;

// ###################################### �t�@�C�����e�̏���<Erase���\�b�h> ####
procedure TExtIniFile.Erase;
begin
  Clear;
  if FUpdateAtOnce then Update;
end;

// ################################# �Z�N�V�����̏���<EraseSection���\�b�h> ####
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

// ####################################### �A�C�e���̎擾<FindItem���\�b�h> ####
function TExtIniFile.FindItem(SectionName, ItemName: string;
  out Value: string): Integer;
var
  Sec: TStringList;    // �Z�N�V�������̃A�C�e�����X�g
  SecIndex: Integer;   // �Z�N�V�����̃C���f�b�N�X
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

// ############# �Z�N�V�����̃C���f�b�N�X�����߂�<FindSectionIndex���\�b�h> ####
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

// #### AbsoluteFileName�v���p�e�B�擾<GetAbsoluteFileName�A�N�Z�X���\�b�h> ####
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
// ##### Items�v���p�e�B�擾 : GetItems�A�N�Z�X���\�b�h
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

// ############################ �w��t�H���_�̃p�X���擾(GetPathString�֐�) ####
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

// ############ SectionCount�v���p�e�B�擾<GetSectionCount�A�N�Z�X���\�b�h> ####
function TExtIniFile.GetSectionCount: Integer;
begin
  Result := FSections.Count;
end;

// #################### Sections�v���p�e�B�擾<GetSections�A�N�Z�X���\�b�h> ####
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

// ################################# �A�C�e���̑��݊m�F<ItemExists���\�b�h> ####
function TExtIniFile.ItemExists(const Section, Item: string): Boolean;
var
  ItemValue: string;
begin
  Result := (FindItem(Section, Item, ItemValue) >= 0);
end;

// ################################## Boolean�^�̓ǂݎ��<ReadBool���\�b�h> ####
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

// ################### �R���g���[���̈ʒu�ƃT�C�Y���擾<ReadBounds���\�b�h> ####
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

// ############################# Cardinal�^�̓ǂݎ��<ReadCardinal���\�b�h> ####
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

// #################################### �J���[�̓ǂݎ��<ReadColor���\�b�h> ####
function TExtIniFile.ReadColor(const Section, Item: string;
  const Default: TColor): TColor;
var
  ColInt: LongInt;
begin
  ColInt := Default;
  ColInt := ReadInt(Section, Item, ColInt);
  Result := ColInt;
end;

// ################################# Currency�^�̓ǂݎ��<ReadCurr���\�b�h> ####
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

// #################################### TDate�^�̓ǂݎ��<ReadDate���\�b�h> ####
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

// ############################ TDateTime�^�̓ǂݎ��<ReadDateTime���\�b�h> ####
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
// == method: �t�H���_�p�X�̓ǂݎ��                                     ====
// ==========================================================================
function TExtIniFile.ReadDirectory(const Section, Item,
  Default: string): string;
begin
  if FindItem(Section, Item, Result) = -1 then Result := Default;
  if Result <> '' then Result := IncludeTrailingPathDelimiter(Result);
end;

// #################################### �����^�̓ǂݎ��<ReadFloat���\�b�h> ####
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

// ################################### �t�H���g�̓ǂݎ��<ReadFont���\�b�h> ####
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

// ####################### �t�H�[���ʒu�ƃT�C�Y�̓ǂݎ��<ReadForm���\�b�h> ####
procedure TExtIniFile.ReadForm(const Section, Item: string; Form: TCustomForm);
var
  State: Integer;
  Wp: TWindowPlacement;
begin
  // ************************************************************* ������ **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // *********************************************************** �ǂݎ�� **
  with Wp do
  begin
    flags := ReadCardinal(Section, Item + '.flags', flags);
    // ===================================================== �ő剻�̈ʒu ==
    ptMaxPosition.X := ReadInt(Section, Item + '.mx', ptMaxPosition.X);
    ptMaxPosition.Y := ReadInt(Section, Item + '.my', ptMaxPosition.Y);
    // =================================================== �t�H�[���̍��W ==
    with rcNormalPosition do
    begin
      Left := ReadInt(Section, Item + '.left', Left);
      Top := ReadInt(Section, Item + '.top', Top);
      Right := ReadInt(Section, Item + '.right', Right);
      Bottom := ReadInt(Section, Item + '.bottom', Bottom);
    end;
    // ========================================================= �\����� ==
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
// ## Method: �t�H�[���̓ǂݎ��
procedure TExtIniFile.ReadForm2(const Section: string; Form: TCustomForm);
begin
  ReadForm(Section, Form.Name, Form);
end;

// ##################### �t�H�[���ʒu�ƃT�C�Y�̓ǂݎ��<ReadFormEx���\�b�h> ####
procedure TExtIniFile.ReadFormEx(const Section, Item: string; Form: TCustomForm);
begin
  ReadForm(Section, Item, Form);
  Form.ClientWidth := ReadInt(Section, Item + '.cwidth', Form.ClientWidth);
  Form.ClientHeight := ReadInt(Section, Item + '.cheight', Form.ClientHeight);
end;

// #############################################################################
// ## Method: �t�H�[���̓ǂݎ��
procedure TExtIniFile.ReadFormEx2(const Section: string; Form: TCustomForm);
begin
  ReadFormEx(Section, Form.Name, Form);
end;

// ################################### Integer�^�̓ǂݎ��<ReadInt���\�b�h> ####
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

// ################################### Int64�^�̓ǂݎ��<ReadInt64���\�b�h> ####
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

// ############################### �����񃊃X�g�̓ǂݎ��<ReadList���\�b�h> ####
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

// ############################## �R���g���[���̈ʒu���擾<ReadPos���\�b�h> ####
procedure TExtIniFile.ReadPos(const Section, Item: string;
  AControl: TControl);
var
  ALeft, ATop: Integer;
begin
  ALeft := ReadInt(Section, Item + '.left', AControl.Left);
  ATop := ReadInt(Section, Item + '.top', AControl.Top);
  AControl.SetBounds(ALeft, ATop, AControl.Width, AControl.Height);
end;

// ################## �Z�N�V�����̃A�C�e�����X�g���擾<ReadSection���\�b�h> ####
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

// ###################### �Z�N�V�����̃��X�g���擾<ReadSectionName���\�b�h> ####
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

// ########################### �R���g���[���̃T�C�Y���擾<ReadSize���\�b�h> ####
procedure TExtIniFile.ReadSize(const Section, Item: string;
  AControl: TControl);
var
  AWidth, AHeight: Integer;
begin
  AWidth := ReadInt(Section, Item + '.width', AControl.Width);
  AHeight := ReadInt(Section, Item + '.height', AControl.Height);
  AControl.SetBounds(AControl.Left, AControl.Top, AWidth, AHeight);
end;

// ###################################### ������̓ǂݎ��<ReadStr���\�b�h> ####
function TExtIniFile.ReadStr(const Section, Item, Default: string): string;
begin
  if FindItem(Section, Item, Result) = -1 then Result := Default;
end;

// #################################### �f�R�[�h�ǂݎ��<ReadStrEx���\�b�h> ####
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
    // ********************************************************* �f�R�[�h **
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

// #################################### TTime�^�̓ǂݎ��<ReadTime���\�b�h> ####
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

// ############################# �t�H�[���ʒu�̓ǂݎ��<ReadWinPos���\�b�h> ####
procedure TExtIniFile.ReadWinPos(const Section, Item: string; Form: TForm);
begin
  Form.Left := ReadInt(Section, Item + '.left', Form.Left);
  Form.Top := ReadInt(Section, Item + '.top', Form.Top);
end;

// ########################## �t�H�[���T�C�Y�̓ǂݎ��<ReadWinSize���\�b�h> ####
procedure TExtIniFile.ReadWinSize(const Section, Item: string;
  Form: TForm);
var
  ARect: TRect;
  State: Integer;
  Wp: TWindowPlacement;
begin
  // *************************************************************** ���� **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // *********************************************************** �ǂݎ�� **
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

// ############ �t�H�[���N���C�A���g�T�C�Y�̓ǂݎ��<ReadWinSizeEx���\�b�h> ####
procedure TExtIniFile.ReadWinSizeEx(const Section, Item: string;
  Form: TForm);
begin
  ReadWinSize(Section, Item, Form);
  Form.ClientWidth := ReadInt(Section, Item + '.cwidth', Form.ClientWidth);
  Form.ClientHeight := ReadInt(Section, Item + '.cheight', Form.ClientHeight);
end;

// ############################### �t�@�C���̓��e��ǂݍ���<Reload���\�b�h> ####
procedure TExtIniFile.Reload;
var
  Flag: Boolean;
  Fs: TFileStream;
  Index: Integer;         // �ǉ��ʒu
  Ini, Sec: TStringList;
  Lp: Integer;
  S: string;
begin
  // *************************************************** ���݂̓��e��j�� **
  Clear;
  FModified := False;
  // *********************************************************** �ǂݍ��� **
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
      // ************************************************* �o�b�t�@�̍\�z **
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

// ####################################### �t�@�C�����̕ύX<Rename���\�b�h> ####
function TExtIniFile.Rename(const NewFolder: TDefaultFolder;
  const NewName: string): Boolean;
var
  NewFileName: string;
begin
  // *********************************************** �V�����t�H���_���擾 **
  NewFileName := GetPathString(NewFolder);
  if NewFolder = dfUser then NewFileName := ExtractFilePath(NewName);
  // ******************************************* �t�H���_�̑��݊m�F�ƍ쐬 **
  if not DirectoryExists(NewFileName) then ForceDirectories(NewFileName);
  Result := DirectoryExists(NewFileName);
  // *********************************************** �t�@�C�����̕ύX���� **
  if Result then
  begin
    if NewFolder = dfUser then
      NewFileName := NewName
    else
      NewFileName := NewFileName + NewName;
    // ================================================= �t�@�C���̃R�s�[ ==
    Copy(NewFileName);
    // =============================================== ���̃t�@�C�����폜 ==
    SysUtils.DeleteFile(FullIniFileName);
    // ================================================= �v���p�e�B�̕ύX ==
    FDefaultFolder := NewFolder;
    FFileName := NewName;
    FIniFileName := ExtractFileName(NewFileName);
    FFolderPath := ExtractFilePath(NewFileName);
  end;
end;

// #############################################################################
// ##### RenameSection���\�b�h
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

// ################################# INI�t�@�C���̕ۑ�<SaveIniFile���\�b�h> ####
procedure TExtIniFile.SaveIniFile(const ARename: Boolean);
var
  Fs: TFileStream;
  Ini, Sec: TStringList;
  Lp: Integer;
begin
  // ***************************************** �ۑ��p�̃I�u�W�F�N�g���쐬 **
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
      // *********************************************************** �ۑ� **
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

// ############################ �Z�N�V�����̑��݊m�F<SectionExists���\�b�h> ####
function TExtIniFile.SectionExists(const Section: string): Boolean;
begin
  Result := (FindSectionIndex(Section) >= 0);
end;

// ########## CaseSensitive�v���p�e�B�ݒ�<SetCaseSensitive�A�N�Z�X���\�b�h> ####
procedure TExtIniFile.SetCaseSensitive(const Value: Boolean);
begin
  FCaseSensitive := Value;
  FSections.CaseSensitive := Value;
end;

// ########## DefaultFolder�v���p�e�B�ݒ�<SetDefaultFolder�A�N�Z�X���\�b�h> ####
procedure TExtIniFile.SetDefaultFolder(const Value: TDefaultFolder);
begin
  if not (csDesigning in ComponentState) then
  begin
    // ***************************************************** �t�@�C���ۑ� **
    if FAutoUpdate then SaveIniFile(True);
    // ************************************************* �V�������O�̎擾 **
    FFolderPath := GetPathString(Value);
    // ********************************************************* �ǂݍ��� **
    Reload;
  end
  else
    FFolderPath := GetPathString(Value);
  FDefaultFolder := Value;
end;

// #################### FileName�v���p�e�B�ݒ�<SetFileName�A�N�Z�X���\�b�h> ####
procedure TExtIniFile.SetFileName(const Value: TFileName);
begin
  FFileName := Value;
  if not (csDesigning in ComponentState) then
  begin
    // ********************************************* ���݂̓��e���������� **
    if FAutoUpdate then SaveIniFile(True);
    // ******************************************* �V�����t�@�C�������擾 **
    FIniFileName := FFileName;
    if FIniFileName = '' then FIniFileName := FAppName + '.ini';
    // *************************************** �V�����t�@�C���̓��e���擾 **
    Reload;
  end
  else
  begin
    FIniFileName := FFileName;
    if FIniFileName = '' then FIniFileName := FAppName + '.ini';
  end;
end;

// ############ UpdateAtOnce�v���p�e�B�ݒ�<SetUpdateAtOnce�A�N�Z�X���\�b�h> ####
procedure TExtIniFile.SetUpdateAtOnce(const Value: Boolean);
begin
  FUpdateAtOnce := Value;
  if Value and (not (csDesigning in ComponentState)) then Update;
end;

// ############################### �o�b�t�@���t�@�C���ɕۑ�<Update���\�b�h> ####
procedure TExtIniFile.Update;
begin
  SaveIniFile(False);
  if Assigned(FOnUpdate) then FOnUpdate(Self);
end;

// #################################### �_���^�̏�������<WriteBool���\�b�h> ####
procedure TExtIniFile.WriteBool(const Section, Item: string;
  const Value: Boolean);
var
  S: string;
begin
  if Value then S := '1' else S := '0';
  WriteValue(Section, Item, S);
  if FUpdateAtOnce then Update;
end;

// ############## �R���g���[���̈ʒu�ƃT�C�Y�̏�������<WriteBounds���\�b�h> ####
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

// ############################ Cardinal�^�̏�������<WriteCardinal���\�b�h> ####
procedure TExtIniFile.WriteCardinal(const Section, Item: string;
  const Value: Cardinal);
begin
  WriteValue(Section, Item, IntToStr(Value));
  if FUpdateAtOnce then Update;
end;

// ################################### �J���[�̏�������<WriteColor���\�b�h> ####
procedure TExtIniFile.WriteColor(const Section, Item: string;
  const Value: TColor);
var
  S: string;
begin
  S := '$' + IntToHex(LongInt(Value), 8);
  WriteValue(Section, Item, S);
  if FUpdateAtOnce then Update;
end;

// ################################ Currency�^�̏�������<WriteCurr���\�b�h> ####
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

// ###################################### ���t�̏�������<WriteDate���\�b�h> ####
procedure TExtIniFile.WriteDate(const Section, Item: string;
  const Value: TDate);
begin
  WriteFloat(Section, Item, Double(Value));
end;

// ########################### TDateTime�^�̏�������<WriteDateTime���\�b�h> ####
procedure TExtIniFile.WriteDateTime(const Section, Item: string;
  const Value: TDateTime);
begin
  WriteFloat(Section, Item, Double(Value));
end;

// ==========================================================================
// == method: �t�H���_�p�X�̏�������                                     ====
// ==========================================================================
procedure TExtIniFile.WriteDirectory(const Section, Item, Path: string);
begin
  if Path = '' then
    WriteValue(Section, Item, Path)
  else
    WriteValue(Section, Item, IncludeTrailingPathDelimiter(Path));
end;

// ##################################### �����̏�������<WriteFloat���\�b�h> ####
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

// ################################## �t�H���g�̏�������<WriteFont���\�b�h> ####
procedure TExtIniFile.WriteFont(const Section, Item: string; Font: TFont);
var
  S: string;
begin
  // ************************************************************* ���ʎq **
  WriteValue(Section, Item, 'FONT');
  // *************************************************** �L�����N�^�Z�b�g **
  S := IntToStr(Font.Charset);
  WriteValue(Section, Item + '.charset', S);
  // ************************************************************* �J���[ **
  S := '$' + IntToHex(Font.Color, 8);
  WriteValue(Section, Item + '.color', S);
  // *************************************************************** ���� **
  S := IntToStr(Font.Height);
  WriteValue(Section, Item + '.height', S);
  // *************************************************************** ���O **
  WriteValue(Section, Item + '.name', Font.Name);
  // ************************************************************* �s�b�` **
  S := IntToStr(Ord(Font.Pitch));
  WriteValue(Section, Item + '.pitch', S);
  // *********************************************************** �X�^�C�� **
  // =========================================================== �{�[���h ==
  if fsBold in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.b', S);
  // ========================================================= �C�^���b�N ==
  if fsItalic in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.i', S);
  // ===================================================== �A���_�[���C�� ==
  if fsUnderline in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.u', S);
  // ========================================================= �ł������� ==
  if fsStrikeOut in Font.Style then S := '1' else S := '0';
  WriteValue(Section, Item + '.s', S);
  if FUpdateAtOnce then Update;
end;

// ############################## �t�H�[�����̏�������<WriteForm���\�b�h> ####
procedure TExtIniFile.WriteForm(const Section, Item: string; Form: TCustomForm);
var
  Wp: TWindowPlacement;
begin
  // ************************************************* �t�H�[�����̎擾 **
  Wp.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Wp);
  // ***************************************************** ���̏������� **
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
// ## Method: �t�H�[���̏�������
procedure TExtIniFile.WriteForm2(const Section: string; Form: TCustomForm);
begin
  WriteForm(Section, Form.Name, Form);
end;

// ################################## Integer�^�̏�������<WriteInt���\�b�h> ####
procedure TExtIniFile.WriteInt(const Section, Item: string;
  const Value: Integer);
begin
  WriteValue(Section, Item, IntToStr(Value));
  if FUpdateAtOnce then Update;
end;

// ################################## Int64�^�̏�������<WriteInt64���\�b�h> ####
procedure TExtIniFile.WriteInt64(const Section, Item: string;
  const Value: Int64);
begin
  WriteValue(Section, Item, IntToStr(Value));
  if FUpdateAtOnce then Update;
end;

// ############################## �����񃊃X�g�̏�������<WriteList���\�b�h> ####
procedure TExtIniFile.WriteList(const Section, Item: string;
  List: TStrings);
var
  Lp: Integer;
  OldCount: Integer;  // �������X�g�̍��ڐ�
  S: string;
begin
  // *************************************************** �������X�g�̌��� **
  FindItem(Section, Item + '.count', S);
  OldCount := StrToIntDef(S, 0);
  // *********************************************************** �������� **
  WriteValue(Section, Item, 'LIST');
  WriteValue(Section, Item + '.count', IntToStr(List.Count));
  for Lp := 0 to List.Count - 1 do
    WriteValue(Section, Item + '.' + IntToStr(Lp), List.Strings[Lp]);
  // ************************************************* �s�v�ȃ��X�g���폜 **
  for Lp := OldCount downto List.Count + 1 do
    DeleteItem(Section, Item + '.' + IntToStr(Lp - 1));
  if FUpdateAtOnce then Update;
end;

// ##################################### ������̏�������<WriteStr���\�b�h> ####
procedure TExtIniFile.WriteStr(const Section, Item, Value: string);
begin
  WriteValue(Section, Item, Value);
  if FUpdateAtOnce then Update;
end;

// ##################### �G���R�[�h����������̏�������<WriteStrEx���\�b�h> ####
procedure TExtIniFile.WriteStrEx(const Section, Item, Value,
  Password: string);
var
  APos, BPos: Integer;
  LenPass, Len: Integer;
  Lp, LPass: Integer;
  Pass, S: string;
begin
  // ********************************************************* �G���R�[�h **
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

// ###################################### �����̏�������<WriteTime���\�b�h> ####
procedure TExtIniFile.WriteTime(const Section, Item: string;
  const Value: TTime);
begin
  WriteFloat(Section, Item, Double(Value));
end;

// ########################### ����������X�g�ɏ�������<WriteValue���\�b�h> ####
procedure TExtIniFile.WriteValue(const Section, Item, Value: string);
var
  SecIndex: Integer;
  ItemIndex: Integer;
  ItemValue: string;
  Sec: TStringList;
  S: string;
begin
  // ***************************************************** �A�C�e���̌��� **
  SecIndex := FindSectionIndex(Section);
  // ******************************* �Z�N�V�������Ȃ���΃Z�N�V������ǉ� **
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
  // *********************************** �Z�N�V�����̃A�C�e�����X�g���擾 **
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
 