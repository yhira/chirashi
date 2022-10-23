unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls ,ShellAPI,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

type
  TForm2 = class(TForm)
    ImageSupermarket: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ImagePachi1: TImage;
    ImageSushi: TImage;
    ImagePachi2: TImage;
    ImageButsudan: TImage;
    ImageHuku1: TImage;
    ImageKaden: TImage;
    ImageCar: TImage;
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
var
  r: Integer;
begin
  Label4.Caption := GetSelfVersion();

  Randomize;
  r := Random(99);
  if (r = 0) then begin
    // 1/100
    ImageButsudan.Align := alClient;
    ImageButsudan.Visible := True;
  end else if (r <= 1) and (r <= 2) then begin
   // 2/100
    ImagePachi2.Align := alClient;
    ImagePachi2.Visible := True;
  end else if (r <= 3) and (r <= 5) then begin
    // 3/100
    ImageSushi.Align := alClient;
    ImageSushi.Visible := True;
  end else if (r <= 6) and (r <= 9) then begin
    // 4/100
    ImageCar.Align := alClient;
    ImageCar.Visible := True;
  end else if (r <= 10) and (r <= 14) then begin
    // 5/100
    ImageKaden.Align := alClient;
    ImageKaden.Visible := True;
  end else if (r <= 15) and (r <= 19) then begin
    // 5/100
    ImageHuku1.Align := alClient;
    ImageHuku1.Visible := True;
  end else if (r <= 20) and (r <= 29) then begin
    // 10/100
    ImagePachi1.Align := alClient;
    ImagePachi1.Visible := True;
  end else begin
    // 70/100
    ImageSupermarket.Align := alClient;
    ImageSupermarket.Visible := True;
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
