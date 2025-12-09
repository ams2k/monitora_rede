unit View.Gotify;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, EditExt;

type

  { TfrmGotify }

  TfrmGotify = class(TForm)
    edtApiHost: TEditExt;
    edtGotifyChave: TEditExt;
    edtGotifyApp: TEditExt;
    edtApiUsuario: TEditExt;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    panTop: TPanel;
    spbSalvar: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure spbSalvarClick(Sender: TObject);
  private
    FAlterado: Boolean;
  public
    property Alterado: Boolean read FAlterado default False;
  end;

var
  frmGotify: TfrmGotify;

implementation

uses
  Service.Gotify;

{$R *.lfm}

{ TfrmGotify }

procedure TfrmGotify.spbSalvarClick(Sender: TObject);
var
  g: TServiceGotify;
begin
  g := TServiceGotify.Create;
  g.Host    := Trim(edtApiHost.Text);
  g.AppNome := Trim(edtGotifyApp.Text);
  g.Chave   := Trim(edtGotifyChave.Text);
  g.Usuario := Trim(edtApiUsuario.Text);

  if g.Salvar() then
  begin
    ShowMessage('Configuração salva com sucesso!');
    ModalResult := mrOK;
    FAlterado := True;
    Close;
  end
  else
    ShowMessage('Falha ao salvar as configurações!');

  g.Free;
end;

procedure TfrmGotify.FormShow(Sender: TObject);
var
  g: TServiceGotify;
begin
  g := TServiceGotify.Create;

  if g.Ler() then begin
    edtApiHost.Text     := g.Host;
    edtGotifyApp.Text   := g.AppNome;
    edtGotifyChave.Text := g.Chave;
    edtApiUsuario.Text  := g.Usuario;
  end;

  g.Free;

  edtApiHost.SetFocus;
end;

end.

