unit View.Host;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, LCLType, LResources;

type

  { TfrmHost }

  TfrmHost = class(TForm)
    btnDelete: TSpeedButton;
    btnTipoHost: TSpeedButton;
    cboHost: TComboBox;
    chkAcceptLink: TCheckBox;
    cboHostType: TComboBox;
    Image1: TImage;
    panTop: TPanel;
    txtIDTemp: TEdit;
    Label4: TLabel;
    btnSave: TSpeedButton;
    Label5: TLabel;
    Timer1: TTimer;
    txtDetails: TMemo;
    txtName: TEdit;
    txtIP: TEdit;
    Label3: TLabel;
    txtTitle: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnTipoHostClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure txtDetailsEnter(Sender: TObject);
    procedure txtDetailsExit(Sender: TObject);
    procedure txtIPEnter(Sender: TObject);
    procedure txtIPExit(Sender: TObject);
    procedure txtIPKeyPress(Sender: TObject; var Key: char);
    procedure txtTitleEnter(Sender: TObject);
    procedure txtTitleExit(Sender: TObject);
  private
    bHasChanges: Boolean;
    procedure ClearFields;
    procedure SaveHost;
    procedure DeleteHost;
    procedure GetHost(id: Integer);
    procedure CarregaComboTiposHost(AId: Integer);
  public
    IDHost: Integer;
    IDParentHost: Integer;
    ParentHost: String;
    PosX: Integer;
    PosY: Integer;
    ObjectDeleted: Boolean;
    AceitaLigacao: Boolean;
    IDRede: Integer;
    IPParent: String;
    IDHostTipo: Integer;
    MR: Integer;
  end;

var
  frmHost: TfrmHost;

implementation

uses
  Service.Host, Funcoes, View.HostTipo;

{$R *.lfm}

{ TfrmHost }

procedure TfrmHost.FormCreate(Sender: TObject);
begin
  IDHost := 0;
  IDParentHost := 0;
  PosX := 0;
  PosY := 0;
  ObjectDeleted := False;
  AceitaLigacao := False;
  IDRede      := 0;
  bHasChanges := False;
  IPParent    := '';
  IDHostTipo  := 0;
  ModalResult := mrNone;
  ParentHost  := '';
  MR := 0;
end;

procedure TfrmHost.FormShow(Sender: TObject);
var
  h: TServiceHost;
begin
  h := TServiceHost.Create();
  h.ComboHostTipos(cboHostType);
  h.ComboHosts(cboHost, IDRede);
  h.Free;

  if IDHost > 0 then
     GetHost(IDHost);
end;

procedure TfrmHost.Timer1Timer(Sender: TObject);
var
  b: Boolean = True;
begin
  if Length(Trim(txtTitle.Text)) < 3 then b := False;
  if Length(Trim(txtIP.Text)) < 7 then    b := False;

  btnSave.Enabled := b;
  btnDelete.Enabled := (StrToInt('0'+txtIDTemp.Text) > 0);
end;

procedure TfrmHost.btnSaveClick(Sender: TObject);
begin
  if ComboBox_GetValue(cboHost) = ComboBox_GetValue(cboHostType) then begin
    MessageDlg('Atenção', 'O Host Pai e este Host não podem ser o mesmo.', mtWarning, [mbOK], 0);
    exit;
  end;

  SaveHost;
end;

procedure TfrmHost.btnTipoHostClick(Sender: TObject);
//cadastro de tipos de host
var
  frm: TfrmHostTipo;
  i: Integer;
begin
  i := ComboBox_GetValue( cboHostType );
  frm := TfrmHostTipo.Create(Self);
  frm.ShowModal;

  if frm.TeveAlteracao then
    CarregaComboTiposHost(i);

  frm.Free;
end;

procedure TfrmHost.btnDeleteClick(Sender: TObject);
begin
  if MessageDlg('Atenção', 'Deseja deletar este Host ?', mtConfirmation, mbYesNo, 0) = mrNo then
    exit;

  DeleteHost;
end;

procedure TfrmHost.txtDetailsEnter(Sender: TObject);
begin
  TextBox(Sender, True);
end;

procedure TfrmHost.txtDetailsExit(Sender: TObject);
begin
  TextBox(Sender, False);
end;

procedure TfrmHost.txtIPEnter(Sender: TObject);
begin
  TextBox(Sender, True);
end;

procedure TfrmHost.txtIPExit(Sender: TObject);
begin
  TextBox(Sender, False);
end;

procedure TfrmHost.txtIPKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in['0'..'9','.',#8]) then Key := #0;
end;

procedure TfrmHost.txtTitleEnter(Sender: TObject);
begin
  TextBox(Sender, True);
end;

procedure TfrmHost.txtTitleExit(Sender: TObject);
begin
  TextBox(Sender, False);
end;

procedure TfrmHost.ClearFields;
begin
  txtIDTemp.Text := '0';
  cboHostType.ItemIndex := 0;
  txtTitle.Text := 'Novo Host';
  txtIP.Text := '';
  cboHost.ItemIndex := -1;
  txtDetails.Lines.Clear;
  txtName.Text := '';
end;

procedure TfrmHost.SaveHost;
var
  h: TServiceHost;
begin
  h := TServiceHost.Create();
  h.IdHost := StrToInt('0'+txtIDTemp.Text);
  h.IDHostTipo := ComboBox_GetValue(cboHostType);
  h.Titulo := Trim(txtTitle.Text);
  h.Posx := PosX;
  h.Posy := PosY;
  h.Ip   := Trim(txtIP.Text);
  h.IdParent := ComboBox_GetValue(cboHost);
  h.Info := txtDetails.Lines.Text;
  h.AceitaLigacao := chkAcceptLink.Checked;
  h.IDRede := IDRede;
  h.Salvar( StrToInt('0'+txtIDTemp.Text) );

  if h.MensagemErro = '' then begin
     MR := 1; //mrOK
     IDHost := h.IdHost;
     IDParentHost := h.IdParent;
     IPParent   := h.GetHostIP(h.IdParent); //pega o IP do Host Pai
     IDHostTipo := h.IDHostTipo;
     ParentHost := cboHost.Text;
     Close;
  end else
    MessageDlg('Atenção', h.MensagemErro, mtWarning, [mbOK], 0);

  h.Free;
end;

procedure TfrmHost.DeleteHost;
var
  h: TServiceHost;
begin
  h := TServiceHost.Create();
  h.Deletar( StrToInt('0'+txtIDTemp.Text) );

  if h.MensagemErro = '' then begin
     ObjectDeleted := True;
     IDHost        := h.IdHost;
     MR            := 2; //mrNo
     Close;
  end else
     MessageDlg('Atenção', h.MensagemErro, mtInformation, [mbOK], 0);

  h.Free;
end;

procedure TfrmHost.GetHost(id: Integer);
var
  h: TServiceHost;
begin
  h := TServiceHost.Create();
  h.Ler(id);

  if h.MensagemErro = '' then begin
     PosX := h.Posx;
     PosY := h.Posy;
     txtIDTemp.Text := h.IdHost.ToString;
     chkAcceptLink.Checked := h.AceitaLigacao;
     ComboBox_Select(cboHostType, h.IDHostTipo);
     txtTitle.Text := h.Titulo;
     txtIP.Text    := h.Ip;
     ComboBox_Select(cboHost, h.IdParent);
     txtDetails.Lines.Text := h.Info;
  end else
     MessageDlg('Atenção', h.MensagemErro, mtWarning, [mbOK], 0);

  h.Free;
end;

procedure TfrmHost.CarregaComboTiposHost(AId: Integer);
//carrega a combobox com os tipos de host
var
  h: TServiceHost;
begin
  h := TServiceHost.Create();
  h.ComboHostTipos(cboHostType);
  h.Free;

  ComboBox_Select(cboHostType, AId);
end;

end.

