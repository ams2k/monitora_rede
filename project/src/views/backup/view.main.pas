unit View.Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Buttons, StdCtrls, ExtCtrls, Menus, LCLType, EditExt, Math, DateUtils;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnPushConfig: TSpeedButton;
    btnPesquisar: TSpeedButton;
    btnMostraRede: TSpeedButton;
    btnAdicHost: TSpeedButton;
    btnMostrarLinhas: TSpeedButton;
    btnMostraLinhasNoArrasto: TSpeedButton;
    btnAdicAviso: TSpeedButton;
    cboRedes: TComboBox;
    edtPesquisa: TEditExt;
    imgListMain16: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblObjetos: TLabel;
    lblOffLine: TLabel;
    mnuAddRotulo: TMenuItem;
    mnuSep: TMenuItem;
    mnuAddHost: TMenuItem;
    mnuHost: TPopupMenu;
    btnRedes: TSpeedButton;
    panTop: TPanel;
    panWorkArea: TScrollBox;
    shpOffLine: TShape;
    tmrArea: TTimer;
    tmrPrincipal: TTimer;
    procedure btnAdicAvisoClick(Sender: TObject);
    procedure btnAdicHostClick(Sender: TObject);
    procedure btnMostraLinhasNoArrastoClick(Sender: TObject);
    procedure btnMostraRedeClick(Sender: TObject);
    procedure btnMostrarLinhasClick(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnPushConfigClick(Sender: TObject);
    procedure btnRedesClick(Sender: TObject);
    procedure cboRedesChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuAddHostClick(Sender: TObject);
    procedure mnuAddRotuloClick(Sender: TObject);
    procedure panWorkAreaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tmrAreaTimer(Sender: TObject);
    procedure tmrPrincipalTimer(Sender: TObject);
  private
    FOffLineTime: TDateTime;
    FOffLineMinutes: Integer;
    FTodosOffLine: Boolean;
    IDNetWork: Integer;
    HostsCount: Integer;
    bActiveNetwork: Boolean;
    MousePoint: TPoint;
    Title: String;
    bFormClosing: Boolean;
    procedure EncheComboRedes;
    procedure AddHost(x, y: Integer);
    procedure AddRotulo(x, y: Integer);
    procedure FreeObjects;
    procedure ShowObjects(idnet: Integer);
    procedure ButtonSelected;
    procedure ReadGotify;
    procedure HostsGetPanic(AState: Boolean);
  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  DB, ZDataset,
  view.Splash, view.Host, View.Rede, View.Gotify,
  Service.Host, Service.Rede, Service.Rotulo, Service.Aviso, Service.PushGotify,
  Objeto.Host, Objeto.Line, Objeto.Rotulo, Objeto.Aviso, Service.Gotify,
  Funcoes;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   //remove objetos da memoria
   if not bFormClosing  then begin
     bFormClosing := True;
     FreeObjects;
   end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  frm: TfrmSplash;
begin
  IDNetWork      := -1;  //ID da rede em exibição
  HostsCount     := 0;
  bActiveNetwork := False;
  Title          := self.Caption;
  CounterOffLine := 0;

  frm := TfrmSplash.Create(nil);
  frm.ShowModal;
  frm.Destroy;

  Show;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if Height < 520 then Height := 520;
  if Width  < 860 then Width  := 860;
  Refresh;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  FTodosOffLine := False;
  FOffLineMinutes := 30; //minutos
  FOffLineTime := now - (FOffLineMinutes * 2);
  Randomize;
  EncheComboRedes;
  ReadGotify;
end;

procedure TfrmMain.mnuAddHostClick(Sender: TObject);
begin
  AddHost(MousePoint.x, MousePoint.y);
end;

procedure TfrmMain.mnuAddRotuloClick(Sender: TObject);
begin
  AddRotulo(MousePoint.x, MousePoint.y);
end;

procedure TfrmMain.panWorkAreaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ((Button = mbRight) and (cboRedes.ItemIndex >= 0) and (bActiveNetwork)) then begin
    MousePoint := Point(X,Y);
    mnuHost.PopUp;
  end;
end;

procedure TfrmMain.tmrAreaTimer(Sender: TObject);
// atualiza o tamanho da área do panWorkArea para o objeto TLine
// ParentHeight, ParentWidth na Unit Funcoes
begin
  ParentHeight := Max(panWorkArea.VertScrollBar.Range, panWorkArea.Height);
  ParentWidth  := Max(panWorkArea.HorzScrollBar.Range, panWorkArea.Width);
end;

procedure TfrmMain.tmrPrincipalTimer(Sender: TObject);
var
  obj: TControl;
begin
  if DeleteObjectName <> '' then begin
    //remove objeto
    tmrPrincipal.Enabled := False;
    try
      obj := panWorkArea.FindChildControl( DeleteObjectName );

      if (obj is TControl) then begin
        FreeAndNil(obj);
        panWorkArea.Refresh;
      end;
    except
    end;

    DeleteObjectName     := '';
    tmrPrincipal.Enabled := True;
  end;

  if HostsCount > 0 then begin
     lblObjetos.Caption  := IntToStr(HostsCount)+' hosts';
     edtPesquisa.Enabled := True;

     if CounterOffLine > 0 then begin
       shpOffLine.Brush.Color := clRed;
       lblOffLine.Caption     := IntToStr(CounterOffLine)+' off-line';
     end else begin
       shpOffLine.Brush.Color := clLime;
       lblOffLine.Caption     := IntToStr(CounterOffLine)+' off-line';
     end;

     if (HostsCount = CounterOffLine) and (MinutesBetween(Now, FOffLineTime) >= FOffLineMinutes) then begin
       //todos os host offline ? 😬😬😬
       FTodosOffLine := True;
       NotificacaoGlobal := True;
       FOffLineTime := Now;
       HostsGetPanic(False);
     end
     else if (CounterOffLine = 0) and (FTodosOffLine) then begin
       FTodosOffLine := False;
       NotificacaoGlobal := True;
       HostsGetPanic(True);
       NotificacaoGlobal := False;
     end;
  end else begin
     lblObjetos.Caption     := '0 hosts';
     shpOffLine.Brush.Color := clGray;
     lblOffLine.Caption     := IntToStr(CounterOffLine)+' off-line';
     edtPesquisa.Enabled    := False;
  end;

  if ShowMenuObjects then begin //menu contexto: adiciona host/Label, disparado pelo TLine
     ShowMenuObjects := False;
     if (cboRedes.ItemIndex >= 0) and (bActiveNetwork) then begin
       MousePoint := MenuObjectsPoint;
       mnuHost.PopUp;
     end;
  end;

  btnMostraRede.Enabled := (cboRedes.ItemIndex>=0);
  btnAdicHost.Enabled   := ((cboRedes.ItemIndex>=0) and (bActiveNetwork));
  btnMostrarLinhas.Enabled := ((cboRedes.ItemIndex>=0) and (bActiveNetwork));
  btnMostraLinhasNoArrasto.Enabled := ((cboRedes.ItemIndex>=0) and (bActiveNetwork));
  btnAdicAviso.Enabled := ((cboRedes.ItemIndex>=0) and (bActiveNetwork));
  btnPesquisar.Enabled := (Length(edtPesquisa.Text)>0);
end;

procedure TfrmMain.EncheComboRedes;
//enche a combo de redes com dados do DB
var
  n: TServiceRede;
begin
  n := TServiceRede.Create();
  n.EncheCombo(cboRedes);
  n.Free;
end;

procedure TfrmMain.AddHost(x, y: Integer);
//Adiciona o Host á área de trabalho
var
  h: THost;
  frm: TfrmHost;
begin
  frm := TfrmHost.Create(nil);
  frm.IDHost := 0;
  frm.PosX   := x;
  frm.PosY   := y;
  frm.IDRede := IDNetWork; // ComboBox_GetValue(cboRedes);

  frm.ShowModal;

  if frm.MR = 1 then begin //mrOK
    h := THost.Create(panWorkArea);
    h.Left           := frm.PosX;
    h.Top            := frm.PosY;
    h.R_ID           := frm.IDHost;
    h.R_Description  := frm.txtTitle.Text;
    h.R_PosX         := frm.PosX;
    h.R_PosY         := frm.PosY;
    h.R_IP           := frm.txtIp.Text;
    h.R_IPParentHost := frm.IPParent;
    h.R_IDParentHost := frm.IDParentHost;
    h.R_IDHostType   := frm.IDHostTipo;
    h.R_IDRede       := frm.IDRede;
    h.R_AcceptLink   := frm.chkAcceptLink.Checked;
    h.Parent         := panWorkArea;
    HostsCount       := HostsCount + 1;
  end;

  frm.Free;
end;

procedure TfrmMain.AddRotulo(x, y: Integer);
//adiciona rótulo na área de trabalho
var
  c: TRotulo;
begin
  if IDNetWork<1 then exit;
  c := TRotulo.Create(panWorkArea);
  c.InicializaRotulo(0, IDNetWork, x, y);
  c.Parent  := panWorkArea;
  c.Visible := True;

  panWorkArea.Refresh;
end;

procedure TfrmMain.FreeObjects;
//Remove objetos da área de trabalho
var
  i: Integer;
  obj: TComponent;
begin
  HostsCount     := 0;
  CounterOffLine := 0;

  for i := (panWorkArea.ComponentCount -1) downto 0 do begin
    //remove THost, TLine e TRotulo que existirem
    if panWorkArea.Components[i] is THost or
       panWorkArea.Components[i] is TLine or
       panWorkArea.Components[i] is TRotulo then begin
        try
          obj := panWorkArea.Components[i];
          FreeAndNil(obj);
        except
        end;
    end;
  end;

  panWorkArea.Refresh;
end;

procedure TfrmMain.ShowObjects(idnet: Integer);
//pega objetos do DB e os exibe na área de trabalho
var
  qry: TZQuery;
  h: THost;
  r: TServiceHost;
  cl: TRotulo;
  cb: TServiceRotulo;
  nob: TAviso;
  ndb: TServiceAviso;
begin
  self.Caption    := Title + '  ['+cboRedes.Text+']';
  ShowLines       := False;
  ShowLinesOnMove := False;
  HostsCount      := 0;
  bActiveNetwork  := True;
  CounterOffLine  := 0;

  //Hosts
  r   := TServiceHost.Create();
  qry := r.qryListaHosts(idnet);

  if qry.RecordCount > 0 then begin
    qry.First;

    while not qry.EOF do begin
      h := THost.Create(panWorkArea);
      h.R_ID           := qry.FieldByName('idhost').AsInteger;
      h.R_Description  := qry.FieldByName('titulo').AsString;
      h.Left           := qry.FieldByName('posx').AsInteger;
      h.Top            := qry.FieldByName('posy').AsInteger;
      h.R_IP           := qry.FieldByName('ip').AsString;
      h.R_PosX         := qry.FieldByName('posx').AsInteger;
      h.R_PosY         := qry.FieldByName('posy').AsInteger;
      h.R_IDParentHost := qry.FieldByName('idparent').AsInteger;
      h.R_IPParentHost := qry.FieldByName('ipparent').AsString;
      h.R_ParentName   := qry.FieldByName('parent').AsString;
      h.R_IDHostType   := qry.FieldByName('idhosttipo').AsInteger;
      h.R_AcceptLink   := (qry.FieldByName('aceitaligacao').AsInteger=1);
      h.R_IDRede       := idnet;
      h.Parent         := panWorkArea;
      h.Visible        := True;

      HostsCount := HostsCount + 1;
      qry.Next;
    end;

    qry.Close;
  end;

  qry.Free;
  r.Free;

  //Rotulo
  cb  := TServiceRotulo.Create();
  qry := cb.qryRotulos(idnet);

  if qry.RecordCount > 0 then begin
    qry.First;

    while not qry.EOF do begin
      cl := TRotulo.Create(panWorkArea);
      cl.InicializaRotulo(qry.FieldByName('idrotulo').AsInteger,
                          idnet,
                          qry.FieldByName('posx').AsInteger,
                          qry.FieldByName('posy').AsInteger);

      cl.Left      := qry.FieldByName('posx').AsInteger;
      cl.Top       := qry.FieldByName('posy').AsInteger;
      cl.Text      := qry.FieldByName('titulo').AsString;
      cl.PosX      := qry.FieldByName('posx').AsInteger;
      cl.PosY      := qry.FieldByName('posy').AsInteger;
      cl.Bold      := (qry.FieldByName('bold').AsInteger=1);
      cl.Underline := (qry.FieldByName('underline').AsInteger=1);
      cl.Pulse     := (qry.FieldByName('pulse').AsInteger=1);
      cl.Border    := (qry.FieldByName('border').AsInteger=1);
      cl.FontColor := StringToColor(qry.FieldByName('fontcolor').AsString);
      cl.BackColor := StringToColor(qry.FieldByName('backcolor').AsString);
      cl.Parent    := panWorkArea;
      cl.Visible   := True;
      cl.Configurar;

      qry.Next;
    end;

    qry.Close;
  end;

  qry.Free;
  cb.Free;

  //Avisos
  ndb := TServiceAviso.Create();
  qry := ndb.qryAvisos(idnet);

  if qry.RecordCount > 0 then begin
    qry.First;

    while not qry.EOF do begin
      nob := TAviso.Create(panWorkArea);
      nob.IDAviso := qry.FieldByName('idaviso').AsInteger;
      nob.Texto   := qry.FieldByName('texto').AsString;
      nob.Left    := qry.FieldByName('posx').AsInteger;
      nob.Top     := qry.FieldByName('posy').AsInteger;
      nob.PosX    := qry.FieldByName('posx').AsInteger;
      nob.PosY    := qry.FieldByName('posy').AsInteger;
      nob.IDRede  := idnet;
      nob.Parent  := panWorkArea;
      nob.Visible := True;
      nob.BringToFront;

      qry.Next;
    end;

    qry.Close;
  end;

  qry.Free;
  ndb.Free;

  ButtonSelected;
end;

procedure TfrmMain.ButtonSelected;
begin
  if ShowLines then
     btnMostrarLinhas.Color := RGBToColor(255, 170, 0)
  else
     btnMostrarLinhas.Color := clBtnFace;

  if ShowLinesOnMove then
     btnMostraLinhasNoArrasto.Color := RGBToColor(255, 170, 0)
  else
     btnMostraLinhasNoArrasto.Color := clBtnFace;
end;

procedure TfrmMain.ReadGotify;
//ler configurações do gotify
begin
  Gotify_Host := '';
  Gotify_AppKey := '';

  with TServiceGotify.Create do
  begin
    if Ler() then begin
      Gotify_Host := Host;
      Gotify_AppKey := Chave;
    end;
    Free;
  end;
end;

procedure TfrmMain.HostsGetPanic(AState: Boolean);
//todos os hosts offline ?
var
  g: TServicoPushGotify;
  s: string;
begin
  if Gotify_Host <> '' then begin
    if not AState then
      s := '🚩 Todos os Hosts OffLine'
    else
      s := '🟢 Todos os Hosts OnLine';

    g := TServicoPushGotify.Create;
    g.Notificar(Gotify_Description, s, Gotify_Host, Gotify_AppKey);
    g.Free;
  end;
end;

procedure TfrmMain.btnRedesClick(Sender: TObject);
var
  frm: TfrmRedes;
begin
  frm := TfrmRedes.Create(nil);
  frm.ShowModal;
  frm.Free;
  EncheComboRedes;
  ComboBox_Select(cboRedes, IDNetWork);
end;

procedure TfrmMain.btnMostraRedeClick(Sender: TObject);
//exibe os hosts, rotulos e avisos
begin
  ParentHeight   := Max(panWorkArea.VertScrollBar.Range, panWorkArea.Height);
  ParentWidth    := Max(panWorkArea.HorzScrollBar.Range, panWorkArea.Width);
  bActiveNetwork := False;
  IDNetWork      := ComboBox_GetValue(cboRedes);
  FreeObjects;
  ShowObjects(IDNetWork);

  //ativa a ligação entre os objetos por linha e
  //ativa a visualização das linha durante o arrasto do objeto
  Gotify_Description := cboRedes.Text;
  ShowLines       := True;
  ShowLinesOnMove := True;
  ButtonSelected;
  FOffLineTime := now - FOffLineMinutes;
  NotificacaoGlobal := False;
end;

procedure TfrmMain.btnMostrarLinhasClick(Sender: TObject);
begin
  ShowLines := not ShowLines;
  if not ShowLines then ShowLinesOnMove := False;
  ButtonSelected;
end;

procedure TfrmMain.btnPesquisarClick(Sender: TObject);
//pesquisa o nome do host pai (control)
var
  i: Integer;
  ctr: THost;
  pesquisa: String;
  bAchou: Boolean;
begin
  if Length(Trim(edtPesquisa.Text))<1 then exit;

  pesquisa := LowerCase(Trim(edtPesquisa.Text));
  bAchou := False;

  for i := 0 to panWorkArea.ComponentCount -1 do begin
    if panWorkArea.Components[i] is THost then begin

      ctr := THost( panWorkArea.Components[i] );
      if (Pos(pesquisa, ctr.R_IP)>0) or (Pos(pesquisa, LowerCase(ctr.R_Description))>0) then begin
        ctr.SayHello := True;
        bAchou := True;
      end;
    end;
  end;

  if not bAchou then
     MessageDlg('Pesquisa', 'Não encontrei!', mtWarning, [mbOK], '');
end;

procedure TfrmMain.btnPushConfigClick(Sender: TObject);
//configuração de push gotify
var
  f: TfrmGotify;
begin
  f := TfrmGotify.Create(self);
  f.ShowModal;
  if f.Alterado then
     ReadGotify;
  f.Free;
end;

procedure TfrmMain.btnAdicHostClick(Sender: TObject);
begin
  AddHost(100,100);
end;

procedure TfrmMain.btnAdicAvisoClick(Sender: TObject);
//cria novo aviso
var
  n: TAviso;
begin
  n := TAviso.Create(panWorkArea);
  n.Left    := 200;
  n.Top     := 200;
  n.PosX    := 200;
  n.PosY    := 200;
  n.IDRede  := IDNetWork;
  n.Parent  := panWorkArea;
  n.Visible := True;
  n.Refresh;
  n.BringToFront;
end;

procedure TfrmMain.btnMostraLinhasNoArrastoClick(Sender: TObject);
begin
  ShowLinesOnMove := not ShowLinesOnMove;
  ButtonSelected;
end;

procedure TfrmMain.cboRedesChange(Sender: TObject);
begin
  if IDNetWork <> ComboBox_GetValue(cboRedes) then begin
     FreeObjects;
     bActiveNetwork := False;
     IDNetWork      := 0;
  end;
end;

end.

