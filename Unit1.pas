unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.StdActns, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.BaseImageCollection, Vcl.ImageCollection,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, System.IniFiles, ExtIniFile,
  Vcl.Menus, Vcl.AppEvnts;

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
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ActionTop: TAction;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ActionList1: TActionList;
    ApplicationEvents1: TApplicationEvents;
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
  private
    { Private �錾 }
    procedure HandleThemes;
  public
    { Public �錾 }
  end;

var
  Form1: TForm1;
  ExIniFile: TExtIniFile;

implementation

uses Unit2, WindowsDarkMode;

{$R *.dfm}

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

procedure TForm1.Action1Execute(Sender: TObject);
var
  iLineNow: integer;
begin
  RichEdit1.Lines.Insert(0, '----------------------------------------');
  RichEdit1.Lines.Insert(0, DateTimeToStr(Now));
  RichEdit1.Lines.Insert(0, '');
  RichEdit1.Lines.Insert(0, '');
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
  RichEdit1.Clear;
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

procedure TForm1.EditRedo1Execute(Sender: TObject);
begin
  RichEdit1.Undo;
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
