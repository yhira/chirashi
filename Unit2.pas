unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls ,ShellAPI,
  Vcl.Imaging.jpeg;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image2: TImage;
    procedure Label3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label3MouseEnter(Sender: TObject);
    procedure Label3MouseLeave(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function GetSelfVersion: String;
var
  VerInfoSize  : DWORD;
  VerInfo      : Pointer;
  VerValueSize : DWORD;
  VerValue     : PVSFixedFileInfo;
  Dummy        : DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize( PChar(ParamStr(0)), Dummy );

  GetMem(VerInfo, VerInfoSize);
  try
    GetFileVersionInfo( PChar(ParamStr(0)), 0, VerInfoSize, VerInfo );
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);

    with VerValue^ do begin
      Result := Format('Ver %d.%d.%d' , [(dwFileVersionMS shr 16)
                                          , (dwFileVersionMS and $FFFF)
                                          , (dwFileVersionLS shr 16)])
    end;
  finally
    FreeMem(VerInfo, VerInfoSize);
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Label4.Caption := GetSelfVersion();

  Randomize;
  if (Random(10) = 0) then
  begin
    Image1.Visible := False;
    Image2.Visible := True;
  end else begin
    Image1.Visible := True;
    Image2.Visible := False;
  end;
end;

procedure TForm2.Image2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TForm2.Label3Click(Sender: TObject);
begin
  ShellExecute(Self.Handle, 'open', PChar('https://nelog.jp/chirashi'),
        '', '', SW_SHOWNORMAL);
end;

procedure TForm2.Label3MouseEnter(Sender: TObject);
begin
  Label3.Font.Color := clRed;
end;

procedure TForm2.Label3MouseLeave(Sender: TObject);
begin
  Label3.Font.Color := clBlue;
end;

end.
