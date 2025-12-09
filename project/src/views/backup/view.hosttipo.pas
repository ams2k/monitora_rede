unit View.HostTipo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls,
  Buttons, ExtCtrls, Grids;

type

  { TfrmHostTipo }

  TfrmHostTipo = class(TForm)
    btnClear: TBitBtn;
    btnDelete: TBitBtn;
    btnSave: TBitBtn;
    dgvTiposHost: TDBGrid;
    Image1: TImage;
    Label1: TLabel;
    panTop: TPanel;
    txtDescricao: TEdit;
    txtIDHostTipo: TEdit;
    procedure btnClearClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure dgvTiposHostCellClick(Column: TColumn);
    procedure dgvTiposHostPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure txtDescricaoEnter(Sender: TObject);
    procedure txtDescricaoExit(Sender: TObject);
  private
    FTeveAlteracao: Boolean;
     procedure CarregaGrid;
     procedure Limpar;
     procedure LerDados(AId: Integer);
     procedure SalvarDados(AId: Integer);
     procedure ExcluirDados(AId: Integer);
  public
     property TeveAlteracao: Boolean read FTeveAlteracao;
  end;

var
  frmHostTipo: TfrmHostTipo;

implementation

uses
  Funcoes, Service.HostTipos;

{$R *.lfm}

{ TfrmHostTipo }

procedure TfrmHostTipo.dgvTiposHostPrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
// ajustes na configuração das células
var
  txtEstilo: TTextStyle;
begin
  txtEstilo := dgvTiposHost.Canvas.TextStyle;
  txtEstilo.SingleLine := False;
  //txtEstilo.Alignment  := taCenter;

  //dgvTiposHost.Canvas.TextStyle := txtEstilo;
  dgvTiposHost.Canvas.Font.Color := clBlue;
end;

procedure TfrmHostTipo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    if dgvTiposHost.DataSource<>nil then
      dgvTiposHost.DataSource.DataSet.Close;
  except
  end;
end;

procedure TfrmHostTipo.FormShow(Sender: TObject);
begin
  FTeveAlteracao := False;
  CarregaGrid;
end;

procedure TfrmHostTipo.txtDescricaoEnter(Sender: TObject);
begin
  TextBox(sender, True);
end;

procedure TfrmHostTipo.txtDescricaoExit(Sender: TObject);
begin
  TextBox(sender, False);
end;

procedure TfrmHostTipo.CarregaGrid;
//enche a grid com dados da rede
var
  n: TServiceHostTipos;
begin
  n := TServiceHostTipos.Create();

  dgvTiposHost.DataSource     := n.DataSetHostTipos('');
  dgvTiposHost.Color          := TColor($EFEFEF);
  dgvTiposHost.AlternateColor := TColor($00F2E2D3);
  dgvTiposHost.SelectedColor  := RGBToColor(255,181,106);

  n.Free;
end;

procedure TfrmHostTipo.Limpar;
begin
  txtIDHostTipo.Text := '0';
  txtDescricao.Clear;
end;

procedure TfrmHostTipo.LerDados(AId: Integer);
var
  p: TServiceHostTipos;
begin
  Limpar;
  p := TServiceHostTipos.Create;

  if p.Ler( AId ) then begin
    txtIDHostTipo.Text := IntToStr(p.IdHostTipo);
    txtDescricao.Text  := p.Descricao;
  end else
    ShowMessage(p.GetErro);

  p.Free;
end;

procedure TfrmHostTipo.SalvarDados(AId: Integer);
var
  p: TServiceHostTipos;
begin
  p := TServiceHostTipos.Create;
  p.Descricao := Trim(txtDescricao.Text);

  if p.Salvar( AId ) then begin
    FTeveAlteracao := True;
    ShowMessage(p.GetMenssagem);
    Limpar;
    CarregaGrid;
  end else
    ShowMessage(p.GetErro);

  p.Free;
end;

procedure TfrmHostTipo.ExcluirDados(AId: Integer);
var
  p: TServiceHostTipos;
begin
  p := TServiceHostTipos.Create;

  if p.Excluir( AId ) then begin
    FTeveAlteracao := True;
    Limpar;
    CarregaGrid;
  end else
    ShowMessage(p.GetErro);

  p.Free;
end;

procedure TfrmHostTipo.dgvTiposHostCellClick(Column: TColumn);
begin
  if dgvTiposHost.DataSource.DataSet.RecordCount>0 then
     LerDados( dgvTiposHost.DataSource.DataSet.FieldByName('idhosttipo').AsInteger );
end;

procedure TfrmHostTipo.btnSaveClick(Sender: TObject);
var
  LId: Integer;
  sMsg: string;
begin
  LId := StrToIntDef(txtIDHostTipo.Text, 0);
  if LId < 1 then
    sMsg := 'Confirma a Inclusão deste novo Tipo de Host ?'
  else
    sMsg := 'Confirma a Alteração deste Tipo de Host ?';

  if MessageDlg('Salvar', sMsg, mtConfirmation, mbYesNo, 0) = mrNo then
     exit;

  SalvarDados( LId );
end;

procedure TfrmHostTipo.btnDeleteClick(Sender: TObject);
begin
  if MessageDlg('Exclusão','Confirma a Exclusão este Tipo de Host ?', mtConfirmation, mbYesNo, 0) = mrNo then
    exit;

  ExcluirDados( StrToIntDef(txtIDHostTipo.Text, 0) );
end;

procedure TfrmHostTipo.btnClearClick(Sender: TObject);
begin
  Limpar;
  txtDescricao.SetFocus;
end;

end.

