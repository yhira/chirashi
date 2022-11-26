program chirashi;

uses
  Vcl.Forms,
  Windows,
  Dialogs,
  Messages,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Vcl.Themes,
  Vcl.Styles,
  System.Math,
  WindowsDarkMode in 'WindowsDarkMode.pas',
  ExtIniFile in 'ExtIniFile.pas';

{$R *.res}

const
  UniqueName:string = 'HogeHogeApp';

//-----------------------------------------------------------------------------
//  EnumWindows �̃R�[���o�b�N�֐�
//  �N���ς݂̃A�v�����őO�ʂɕ\�����邽�߂Ɏg�p
//
//  lazarus-2.0.8 �ł� ShowWindow(hWindow, SW_RESTORE) �͋@�\���Ȃ�
//  ����� WM_SYSCOMMAND �� SC_RESTORE ���|�X�g���Ă���
//-----------------------------------------------------------------------------
function EnumWndProc(hWindow: HWND; lData: LPARAM): BOOL;stdcall;
begin
  Result := True;
  if GetProp(hWindow, PChar(lData)) = 1111 then begin
    if IsIconic(hWindow) then begin
      PostMessage(hWindow, WM_SYSCOMMAND, $FFF0 and SC_RESTORE, 0);
    end;
    SetForegroundWindow(hWindow);
    Result := False;
  end;
end;

//-----------------------------------------------------------------------------
//  �����Ŏw�肵���v���p�e�B�����E�B���h�E���N�����Ă��邩���m�F����֐�
//-----------------------------------------------------------------------------
function IsPrevAppExist(AName: string):Boolean;
begin
  Result := False;
  CreateMutex(nil, True, PChar(AName));
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    ShowMessage('���̃A�v���͓�d�N���ł��܂���');
    EnumWindows(@EnumWndProc, LPARAM(PChar(AName)));
    Result := True;
  end;
end;
begin
  if IsPrevAppExist(UniqueName) then Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '�`���V�̗�';
  //���������_��O���g��Ȃ�
  //���̕s��΍�Fhttps://learn.microsoft.com/en-us/windows/release-health/status-windows-11-22h2#2947msgdesc
  //�Q�l:https://qiita.com/ht_deko/items/d572f0b965e21c8125f4
  SetExceptionMask(exAllArithmeticExceptions);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
