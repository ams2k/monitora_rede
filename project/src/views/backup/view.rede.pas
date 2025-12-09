unit View.Rede;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, Buttons, ExtCtrls, Grids, LResources;

type

  { TfrmRedes }

  TfrmRedes = class(TForm)
    btnSave: TBitBtn;
    btnDelete: TBitBtn;
    btnClear: TBitBtn;
    dgvRedes: TDBGrid;
    Image1: TImage;
    panTop: TPanel;
    Timer1: TTimer;
    txtIDNet: TEdit;
    txtDescription: TEdit;
    Label1: TLabel;
    procedure btnClearClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure dgvRedesCellClick(Column: TColumn);
    procedure dgvRedesPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure txtDescriptionEnter(Sender: TObject);
    procedure txtDescriptionExit(Sender: TObject);
  private
    procedure Save;
    procedure Delete;
    procedure Get(id: Integer);
    procedure CarregaGrid;
  public
    { public declarations }
  end;

var
  frmRedes: TfrmRedes;

implementation

uses
  Funcoes, Service.Rede;

{$R *.lfm}

{ TfrmRedes }

procedure TfrmRedes.FormShow(Sender: TObject);
begin
  CarregaGrid;
end;

procedure TfrmRedes.Timer1Timer(Sender: TObject);
begin
  btnSave.Enabled   := (Length(Trim(txtDescription.Text))>0);
  btnDelete.Enabled := (StrToInt('0'+txtIDNet.Text)>0);
end;

procedure TfrmRedes.btnSaveClick(Sender: TObject);
begin
  Save;
end;

procedure TfrmRedes.dgvRedesCellClick(Column: TColumn);
begin
  if dgvRedes.DataSource.DataSet.RecordCount>0 then
     Get( dgvRedes.DataSource.DataSet.FieldByName('idrede').AsInteger );
end;

procedure TfrmRedes.dgvRedesPrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
// ajustes na configuração das células
var
  txtEstilo: TTextStyle;
begin
  txtEstilo := dgvRedes.Canvas.TextStyle;
  txtEstilo.SingleLine := False;
  //txtEstilo.Alignment  := taCenter;

  //dgvRedes.Canvas.TextStyle := txtEstilo;
  dgvRedes.Canvas.Font.Color := clBlue;
end;

procedure TfrmRedes.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    if dgvRedes.DataSource<>nil then //) and (dgvRedes.DataSource.DataSet.Active) then
       dgvRedes.DataSource.DataSet.Close;
  except
  end;
end;

procedure TfrmRedes.btnDeleteClick(Sender: TObject);
begin
  if MessageDlg('Atenção','Deletar esta rede e todos os seus objetos ?', mtConfirmation, mbYesNo,0) = mrNo then
     exit;

  Delete;
end;

procedure TfrmRedes.btnClearClick(Sender: TObject);
begin
  txtIDNet.Text := '0';
  txtDescription.Text := '';
  txtDescription.SetFocus;
end;

procedure TfrmRedes.txtDescriptionEnter(Sender: TObject);
begin
  TextBox(sender, True);
end;

procedure TfrmRedes.txtDescriptionExit(Sender: TObject);
begin
  TextBox(Sender, False);
end;

procedure TfrmRedes.Save;
//Salves network data to DB
var
  n: TServiceRede;
begin
  n := TServiceRede.Create();
  n.IDRede := StrToInt('0'+txtIDNet.Text);
  n.Descricao := txtDescription.Text;
  n.Salvar( StrToInt('0'+txtIDNet.Text) );

  if n.MensagemErro = '' then begin
    txtIDNet.Text := '0';
    txtDescription.Text := '';
    CarregaGrid;
    txtDescription.SetFocus;
  end else
    MessageDlg('Atenção', n.MensagemErro, mtWarning, [mbOK], 0);

  n.Free;
end;

procedure TfrmRedes.Delete;
//delete network data on DB
var
  n: TServiceRede;
begin
  n := TServiceRede.Create();
  n.Deletar( StrToInt('0'+txtIDNet.Text) );

  if n.MensagemErro = '' then begin
    txtIDNet.Text := '0';
    txtDescription.Text := '';
    CarregaGrid;
    txtDescription.SetFocus;
  end else
    MessageDlg('Atenção', n.MensagemErro, mtWarning, [mbOK], 0);

  n.Free;
end;

procedure TfrmRedes.Get(id: Integer);
//gets network data from DB
var
  n: TServiceRede;
begin
  n := TServiceRede.Create();
  n.Ler(id);

  if n.MensagemErro = '' then begin
    txtIDNet.Text := n.IDRede.ToString;
    txtDescription.Text := n.Descricao;
    txtDescription.SetFocus;
    txtDescription.SelStart := Length(txtDescription.Text);
  end else
    MessageDlg('Atenção', n.MensagemErro, mtWarning, [mbOK], 0);

  n.Free;
end;

procedure TfrmRedes.CarregaGrid;
//enche a grid com dados da rede
var
  n: TServiceRede;
begin
  n := TServiceRede.Create();

  dgvRedes.DataSource     := n.dsGridRedes('');
  dgvRedes.Color          := TColor($EFEFEF);
  dgvRedes.AlternateColor := TColor($00F2E2D3);
  dgvRedes.SelectedColor  := RGBToColor(255,181,106);

  n.Free;
end;

end.

