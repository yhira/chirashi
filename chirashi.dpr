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
//  EnumWindows のコールバック関数
//  起動済みのアプリを最前面に表示するために使用
//
//  lazarus-2.0.8 では ShowWindow(hWindow, SW_RESTORE) は機能しない
//  代わりに WM_SYSCOMMAND で SC_RESTORE をポストしている
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
//  引数で指定したプロパティを持つウィンドウが起動しているかを確認する関数
//-----------------------------------------------------------------------------
function IsPrevAppExist(AName: string):Boolean;
begin
  Result := False;
  CreateMutex(nil, True, PChar(AName));
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    ShowMessage('このアプリは二重起動できません');
    EnumWindows(@EnumWndProc, LPARAM(PChar(AName)));
    Result := True;
  end;
end;
begin
  if IsPrevAppExist(UniqueName) then Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'チラシの裏';
  //浮動小数点例外を使わない
  //次の不具合対策：https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-22h2#2947msgdesc
  //参考:https://qiita.com/ht_deko/items/d572f0b965e21c8125f4
  SetExceptionMask(exAllArithmeticExceptions);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
