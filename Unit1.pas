unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.StdActns, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.BaseImageCollection, Vcl.ImageCollection,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, System.IniFiles, ExtIniFile,
  Vcl.Menus, Vcl.AppEvnts, ShellAPI, System.NetEncoding;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ActionManager1: TActionManager;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditDelete1: TEditDelete;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    VirtualImageList1: TVirtualImageList;
    ImageCollection1: TImageCollection;
    ToolButton7: TToolButton;
    Action1: TAction;
    RichEdit1: TRichEdit;
    FontDialog1: TFontDialog;
    Action2: TAction;
    Action3: TAction;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    EditUndo1: TEditUndo;
    ToolButton10: TToolButton;
    EditRedo1: TAction;
    ToolButton6: TToolButton;
    Action4: TAction;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    T1: TMenuItem;
    C1: TMenuItem;
    P1: TMenuItem;
    D1: TMenuItem;
    ToolButton13: TToolButton;
    N3: TMenuItem;
    A1: TMenuItem;
    N4: TMenuItem;
    C2: TMenuItem;
    ToolButtonUndo: TToolButton;
    ToolButton15: TToolButton;
    ActionTop: TAction;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ActionList1: TActionList;
    ApplicationEvents1: TApplicationEvents;
    ActionSearch: TAction;
    N5: TMenuItem;
    PopupSearch: TMenuItem;
    SeparatorSearch: TMenuItem;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButtonRedo: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure EditRedo1Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionTopUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplicationEvents1SettingChange(Sender: TObject; Flag: Integer;
      const Section: string; var Result: Integer);
    procedure RichEdit1SelectionChange(Sender: TObject);
    procedure ActionSearchExecute(Sender: TObject);
    procedure EditPaste1Execute(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
  private
    { Private �錾 }
    procedure HandleThemes;
    function CanUndo(RichEdit: TRichEdit): Boolean;
    function CanRedo(RichEdit: TRichEdit): Boolean;
    procedure Undo(RichEdit: TRichEdit);
    procedure Redo(RichEdit: TRichEdit);
  public
    { Public �錾 }
  end;

var
  Form1: TForm1;
  ExIniFile: TExtIniFile;

const
  EM_CANUNDO = WM_USER + 23;
  EM_UNDO = WM_USER + 23;
  EM_CANREDO = WM_USER + 84;
  EM_REDO = WM_USER + 84;
  EM_EMPTYUNDOBUFFER = WM_USER + 28;

implementation

uses Unit2, WindowsDarkMode, clipbrd;

{$R *.dfm}

function TForm1.CanUndo(RichEdit: TRichEdit): Boolean;
begin
  Result := SendMessage(RichEdit.Handle, EM_CANUNDO, 0, 0) <> 0;
end;

function TForm1.CanRedo(RichEdit: TRichEdit): Boolean;
begin
  Result := SendMessage(RichEdit.Handle, EM_CANREDO, 0, 0) <> 0;
end;

procedure TForm1.Undo(RichEdit: TRichEdit);
begin
  if CanUndo(RichEdit) then
    SendMessage(RichEdit.Handle, EM_UNDO, 0, 0);
end;

procedure TForm1.Redo(RichEdit: TRichEdit);
begin
  if CanRedo(RichEdit) then
    SendMessage(RichEdit.Handle, EM_REDO, 0, 0);
end;

procedure TForm1.HandleThemes;
begin
  SetAppropriateThemeMode('Windows10 Media', 'Windows');
  if DarkModeIsEnabled then
  begin
   RichEdit1.Font.Color := clWhite;
  end else begin
   RichEdit1.Font.Color := clBlack;
  end;
end;

procedure TForm1.RichEdit1Change(Sender: TObject);
begin
  ToolButtonUndo.Enabled := TRichEdit(Sender).CanUndo;
  ToolButtonRedo.Enabled := CanRedo(TRichEdit(Sender));
end;

procedure TForm1.RichEdit1SelectionChange(Sender: TObject);
var
  s: string;
begin
  s := Trim(RichEdit1.SelText);
  if not (s = '') then
  begin
    PopupSearch.Visible := true;
    ActionSearch.Enabled := true;
    if Length(s) > 10 then
    begin
      s := Copy(s, 1, 10) + '...';
    end;
    ActionSearch.Caption := 'Google �Ō����F"' + s + '"';
  end
  else
  begin
    PopupSearch.Visible := false;
    ActionSearch.Enabled := false;
  end;

end;

procedure TForm1.Action1Execute(Sender: TObject);
var
  iLineNow: integer;
  sl: TStringList;
begin
  sl := TStringList.Create();
  try
    // �}�������̍쐬
    sl.Insert(0, '----------------------------------------');
    sl.Insert(0, DateTimeToStr(Now));
    sl.Insert(0, '');
    sl.Insert(0, '');

    // �L�����b�g�ʒu���ŏ��̍s�̐擪�Ɉړ�
    RichEdit1.SelStart := 0;
    RichEdit1.SelLength := 0;

    // �쐬�����e�L�X�g��}��
    SendMessage(RichEdit1.Handle, EM_REPLACESEL, WPARAM(True), LPARAM(PChar(sl.Text)));
  finally
    sl.Free;
  end;

  with RichEdit1 do
  begin
    // ���݂̃J�[�\���̂���s�𓾂�
    iLineNow := SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0);
    // �擪�s�փX�N���[��
    SendMessage(Handle, EM_LINESCROLL, 0, -iLineNow);         // ���݂̍s�������߂�
    SelStart := 0;
    SetFocus;
   end;
end;

procedure TForm1.Action2Execute(Sender: TObject);
begin
  FontDialog1.Font := RichEdit1.Font;
  if FontDialog1.Execute then
  begin
   RichEdit1.Font := FontDialog1.Font;
  end;
end;

procedure TForm1.Action3Execute(Sender: TObject);
begin
  RichEdit1.SelectAll;
  RichEdit1.ClearSelection;
end;

procedure TForm1.Action4Execute(Sender: TObject);
begin
  if ActionTop.Checked then begin
    //��Ɏ�O�ɕ\��������
    SetWindowPos(handle,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE Or SWP_NOSIZE or SWP_NOACTIVATE);
  end;
  Form2 := TForm2.Create(self);
  try
    Form2.ShowModal;
  finally
    Form2.Free;
    if ActionTop.Checked then begin
      //��Ɏ�O�ɕ\��
      SetWindowPos(handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE Or SWP_NOSIZE or SWP_NOACTIVATE);
    end;
  end;
end;

procedure TForm1.ActionSearchExecute(Sender: TObject);
var s, url: String;
begin
  s := trim(RichEdit1.SelText);
  if not (s = '') then
  begin
    url := 'https://www.google.com/search?q=' + TNetEncoding.URL.EncodeQuery(s);
    ShellExecute(Self.Handle, 'open', PChar(url),
          '', '', SW_SHOWNORMAL);
  end;
end;

procedure TForm1.ActionTopUpdate(Sender: TObject);
begin
  if ActionTop.Checked then begin
    //��Ɏ�O�ɕ\��
    SetWindowPos(handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE Or SWP_NOSIZE or SWP_NOACTIVATE);
  end else begin
    //��Ɏ�O�ɕ\��������
    SetWindowPos(handle,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE Or SWP_NOSIZE or SWP_NOACTIVATE);
  end;
end;

procedure TForm1.ApplicationEvents1SettingChange(Sender: TObject; Flag: Integer;
  const Section: string; var Result: Integer);
begin
  if SameText('ImmersiveColorSet', String(Section)) then
    HandleThemes; //�_�[�N���[�h
end;

procedure TForm1.EditPaste1Execute(Sender: TObject);
begin
  if Clipboard.HasFormat(CF_TEXT) then
  begin
    SendMessage(RichEdit1.Handle, EM_REPLACESEL, WPARAM(True), LPARAM(PChar(Clipboard.AsText)));
  end;
end;

procedure TForm1.EditRedo1Execute(Sender: TObject);
begin
  Redo(RichEdit1);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  RichEdit1.SetFocus;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //�G�f�B�^�[�̕ۑ�
  RichEdit1.Lines.SaveToFile(ChangeFileExt( Application.ExeName, '.txt' ));

  //�ݒ�̕ۑ�
  ExIniFile.WriteForm2('Main', Self);
  ExIniFile.WriteFont('Edit', 'Font', RichEdit1.Font);
  ExIniFile.WriteBool('Config', 'TopForm', ActionTop.Checked);

  //���
  ExIniFile.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  FileName: String;
 begin
   //�_�[�N���[�h
   HandleThemes;

   //�G�f�B�^�[�̓ǂݍ���
   FileName := ChangeFileExt( Application.ExeName, '.txt' );
   if FileExists(FileName) then
   begin
     RichEdit1.Lines.LoadFromFile(FileName);
   end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  //����
  ExIniFile := TExtIniFile.Create(Self);
  ExIniFile.FileName := 'settings.ini';

  //�ݒ�̓ǂݍ��ݓǂݍ���
  ExIniFile.ReadFormEx2('Main', Self);
  ExIniFile.ReadFont('Edit', 'Font', RichEdit1.Font);
  ActionTop.Checked := ExIniFile.ReadBool('Config', 'TopForm', ActionTop.Checked);
end;

end.
