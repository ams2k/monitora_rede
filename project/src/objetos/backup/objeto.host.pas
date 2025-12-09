unit Objeto.Host;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, DateUtils, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math, Menus,
  {$ifdef unix}
  cthreads,
  {$endif}
  Objeto.Line, Funcoes, service.Host;

type

  TShowClientStatusEvent = procedure(iTimer: Integer) of Object;

  { TClientPing }

  TClientPing = class(TThread)
    private
      PingTime: Integer;
      IPAddress: String;
      FOnShowStatus: TShowClientStatusEvent;
      procedure ShowStatus;
    public
      Constructor Create(sIp: String; CreateSuspended : boolean);
      property OnShowStatus: TShowClientStatusEvent read FOnShowStatus write FOnShowStatus;
    protected
      procedure Execute; override;
  end;

  { THost }

  THost = class(TPanel)
  private
    tmrPing: TTimer;
    tmrLines: TTimer;
    T:TShape;
    L:TLabel;
    MouseDownPos : TPoint;
    DragEnabled : Boolean;
    iPosX, iPosY: Integer;
    mnuMain: TPopupMenu;
    mnuEditHost: TMenuItem;
    mnuSep: TMenuItem;
    mnuDeleteHost: TMenuItem;
    selfColor: TColor;
    clientPing: TClientPing;
    CountOffLine: Integer;

    iR_ID: Integer;  //ID of Host on database
    iR_IDHostTipo: Integer;
    sHostTipoNome: String;
    sR_Description: String;
    iR_PosX: Integer;
    iR_PosY: Integer;
    sR_IP, sR_IPLocal: String;
    sR_IPParentHost: String;
    iR_IDParentHost: Integer; //ID of parent host on database
    sR_ParentHostNameCTRL: String; //component name
    sR_ParentName: String; //name on DB
    iR_IdRede: Integer;
    bIAmOnLine: Boolean;
    bIAmOnLineTemp: Boolean;
    bIAmDead: Boolean;
    cColor: TColor;
    LineColor: TColor;
    bAcceptLink: Boolean;
    lin:TLine;
    sStatusPing: String;
    sTricks: String;
    bLinkedLine: Boolean;
    //ParentHostName: String;
    OffLineTime: String;
    MySons: TStringList;
    bHigthligthLine: Boolean;
    bSayHello: Boolean;
    SayHelloDuration: Integer;
    SayHelloTime: TDateTime;
    bSaingHello: Boolean;
    FOffLineTime: TDateTime;
    procedure MoveObject(X,Y: Integer);
    procedure SetChangeColor(c: TColor);
    procedure SetLineColor(c: TColor);
    procedure SetHostTitle(s: String);
    procedure Configurar;
    procedure tmrPingTimer(Sender: TObject);
    procedure tmrLinesTimer(Sender: TObject);
    procedure MouseHand;
    procedure mnuEditHostClick(sender: TObject);
    procedure mnuDeleteHostClick(sender: TObject);
    procedure mnuMainOnPopup(sender: TObject);
    procedure mnuMainOnClose(sender: TObject);
    procedure SetIMADead(b: Boolean);
    procedure SetR_ID(i: Integer);
    procedure SetR_Description(s: String);
    procedure SetR_PosX(i: Integer);
    procedure SetR_PosY(i: Integer);
    procedure SetR_IP(s: String);
    procedure SetR_ParentHostName(s: String);
    procedure SetR_IPParentHost(s: String);
    procedure SetR_IDHostType(i: Integer);
    procedure DetachMyLine;
    procedure ShowInfo;
    procedure SayToSonsHigthligthLine(b: Boolean);
    procedure ShowHideLine;
    procedure DrawLine;
    procedure RedrawLine(bIAM: Boolean);
    procedure MouseReleased;
    procedure RemoveLine;
    procedure OutFromParentHost;
    procedure LinkNoticeSons(b: Boolean);
    procedure FindParentHostCTRL;
    procedure DeadNotice;
    procedure SayToSonsChangeProfile;
    procedure PushNotification;
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ControlMouseEnter(Sender: TObject);
    procedure ControlMouseLeave(Sender: TObject);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TMouseEnter(Sender: TObject);
    procedure TMouseLeave(Sender: TObject);
    procedure TMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure TMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LMouseEnter(Sender: TObject);
    procedure LMouseLeave(Sender: TObject);
    procedure LMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure LMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ParentHostIsDead;
    procedure LinkToParentHost(b: Boolean);
    procedure DetachLine(b: Boolean);
    procedure AddSon(sSonName: String);
    procedure RemoveSon(sSonName: String);
    procedure NoticeSonsUpdadeLine;
    procedure UpdateLine;
    procedure PingStatus(iTime: Integer);
  published
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property Parent;
    property Name;
    property PosX: Integer read iPosX write iPosX default 100;
    property PosY: Integer read iPosY write iPosY default 100;
    property IAMOnLine: Boolean read bIAmOnLine;
    property R_ID: Integer read iR_ID write  SetR_ID;
    property ChangeColor: TColor read cColor write SetLineColor;
    property R_Description: String read sR_Description write SetR_Description;
    property R_PosX: Integer read iR_PosX write SetR_PosX;
    property R_PosY: Integer read iR_PosY write SetR_PosY;
    property R_IP: String read sR_IP write SetR_IP;
    property R_IDParentHost: Integer read iR_IDParentHost write iR_IDParentHost;
    property R_ParentHostNomeCTRL: String read sR_ParentHostNameCTRL write SetR_ParentHostName;
    property R_IPParentHost: String read sR_IPParentHost write SetR_IPParentHost;
    property IAMDead: Boolean read bIAmDead write SetIMADead;
    property R_IDHostType: Integer read iR_IDHostTipo write SetR_IDHostType;
    property R_AcceptLink: Boolean read bAcceptLink write bAcceptLink;
    property R_IDRede: Integer read iR_IdRede write iR_IdRede;
    property R_ParentName: String read sR_ParentName write sR_ParentName;
    property SayHello: Boolean read bSayHello write bSayHello;
  end;

implementation

uses
  View.Host, pingsend, Service.PushGotify;

{ TClientPing }

procedure TClientPing.ShowStatus;
begin
  if Assigned(FOnShowStatus) then
     FOnShowStatus(PingTime);
end;

constructor TClientPing.Create(sIp: String; CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
  IPAddress := sIp;
end;

procedure TClientPing.Execute;
begin
  PingTime := PingHost(IPAddress);
  Synchronize(@ShowStatus);
end;

{ THost }

constructor THost.Create(AOwner: TComponent);
var
  snum: String;
  i: Integer;
begin
  inherited;
  lin := Nil;
  MySons := TStringList.Create();
  iR_ID  := 0;
  iR_IDHostTipo  := 0;
  sR_Description := 'Novo Host';
  iR_PosX := self.Left;
  iR_PosY := self.Top;
  sR_IP   := '127.0.0.1';
  sR_IPParentHost := '';
  iR_IDParentHost := 0;
  sR_ParentName   := ''; //name on DB
  sR_ParentHostNameCTRL := ''; //name of component
  iR_IdRede    := 0;
  bIAmOnLine   := True;
  bIAmOnLineTemp := True;
  bIAmDead     := False;
  cColor       := TColor($ffffff);
  LineColor    := clBlack;
  bAcceptLink  := False;
  bLinkedLine  := False;
  CountOffLine := 0;
  bSayHello    := False;
  SayHelloDuration := 4;
  SayHelloTime := GetTickCount;
  bSaingHello  := False;

  //notification
  FOffLineTime := now - NotificacaoIndividualMinutos;

  snum := '';

  for i := 1 to 10 do
    snum := snum + IntToStr(Random(23) + 1) + chr(Random(26) + 65);

  self.selfColor := self.Color;
  self.BorderSpacing.Around := 3;
  self.Top         := 100;
  self.Left        := 100;
  self.BorderStyle := bsNone;
  self.BevelOuter  := bvNone;
  self.BorderStyle := bsSingle;
  self.BorderWidth := 1;
  self.Font.Size   := 7;
  self.Font.Color  := clBlue;
  self.Color       := RGBToColor(208, 218, 228); //clWhite;// clDefault;
  self.AutoSize    := True;
  self.Name        := 'Host' + snum + FormatDateTime('zzz', Now);
  self.Caption     := '';
  self.Refresh;

  {Rectangle to show ping status color}
  T := TShape.Create(self);
  T.Shape := TShapeType.stRectangle;
  T.Left := self.Left+5;
  T.Top  := 3;
  T.Width := 10;
  T.Height := 10;
  T.Name := 'Shape_1';
  T.Parent := self;
  T.Brush.Color := TColor($80ff80);
  T.Visible := True;
  T.OnMouseDown := @TMouseDown;
  T.OnMouseUp   := @TMouseUp;
  T.OnMouseMove := @TMouseMove;
  T.Refresh;

  L := TLabel.Create(self);
  L.Font.Size := self.Font.Size;
  L.Left := T.Left + T.Width + 4;
  L.Top := 1;
  L.Font.Color := clBlack;
  L.Caption  := sR_Description + ' ';
  L.AutoSize := True;
  L.Name     := 'Label_1';
  L.Parent   := self;
  L.Visible  := True;
  L.OnMouseDown  := @LMouseDown;
  L.OnMouseUp    := @LMouseUp;
  L.OnMouseMove  := @LMouseMove;
  L.OnMouseEnter := @LMouseEnter;
  L.OnMouseLeave := @LMouseLeave;
  L.Refresh;

  OnMouseDown  := @ControlMouseDown;
  OnMouseUp    := @ControlMouseUp;
  OnMouseMove  := @ControlMouseMove;
  OnMouseEnter := @ControlMouseEnter;
  OnMouseLeave := @ControlMouseLeave;

  tmrPing := TTimer.Create(self);
  tmrPing.Interval := 500;
  tmrPing.OnTimer  := @tmrPingTimer;
  tmrPing.Enabled  := True;

  tmrLines := TTimer.Create(self);
  tmrLines.Interval := 500;
  tmrLines.OnTimer  := @tmrLinesTimer;
  tmrLines.Enabled  := True;

  //Menu Main
  mnuMain := TPopupMenu.Create(self);
  mnuMain.OnPopup := @mnuMainOnPopup;
  mnuMain.OnClose := @mnuMainOnClose;
  //Menu Item: mnuEditHost
  mnuEditHost := TMenuItem.Create(self);
  mnuEditHost.Caption := 'Editar Host';
  mnuEditHost.Bitmap.LoadFromLazarusResource('pencil_16');
  mnuEditHost.OnClick := @mnuEditHostClick;
  //Menu Item: mnuSep
  mnuSep := TMenuItem.Create(self);
  mnuSep.Caption := '-';
  //Menu Item: mnuDeleteHost
  mnuDeleteHost := TMenuItem.Create(self);
  mnuDeleteHost.Caption := 'Deletar Host';
  mnuDeleteHost.Bitmap.LoadFromLazarusResource('delete_16');
  mnuDeleteHost.OnClick := @mnuDeleteHostClick;
  //Add Items to mnuMain
  mnuMain.Items.Add(mnuEditHost);
  mnuMain.Items.Add(mnuSep);
  mnuMain.Items.Add(mnuDeleteHost);

  Configurar;
end;

destructor THost.Destroy;
begin
  if Assigned(MySons) then
     FreeAndNil(MySons);

  try
    if clientPing <> nil then begin
       clientPing.Terminate;
       FreeAndNil(clientPing);
    end;
  finally
  end;

  inherited Destroy;
end;

procedure THost.tmrPingTimer(Sender: TObject);
begin
  if Length(sR_IP) < 7 then exit;

  tmrPing.Interval := 10000; //10seg

  if clientPing <> nil then begin
     try
       clientPing.Terminate;
       FreeAndNil(clientPing);
     except
     end;
  end;

  clientPing := TClientPing.Create(sR_IP, True);
  clientPing.OnShowStatus := @PingStatus;

  if Assigned(clientPing.FatalException) then
     raise clientPing.FatalException;

  clientPing.Start;
end;

procedure THost.tmrLinesTimer(Sender: TObject);
begin
  if (bLinkedLine <> ShowLines) and (iR_IDParentHost > 0) Then
    ShowHideLine;

  if (MySons <> nil) and (MySons.Count>0) then
    self.BorderStyle := bsSingle
  else
    self.BorderStyle := bsNone;

  //say hello
  if bSayHello then begin
     if not bSaingHello then begin
       SayHelloDuration := 4000;
       SayHelloTime     := GetTickCount; //milissegundos
       bSaingHello      := True;
     end;

     if self.Color = clYellow then
       self.Color := selfColor
     else
       self.Color := clYellow;

     if (GetTickCount - SayHelloTime) > SayHelloDuration then begin
       bSayHello   := False;
       bSaingHello := False;
       self.Color  := selfColor;
       Configurar;
     end;
  end;
end;

procedure THost.MoveObject(X, Y: Integer);
begin
  if (self.Left = Math.Max(0, X + self.Left - MouseDownPos.x)) and
     (self.Top  = Math.Max(0, Y + self.Top - MouseDownPos.y)) then
    //se não houver alterações na posição do host
    Exit;

  self.Left := Math.Max(0, x + self.Left - MouseDownPos.x);
  self.Top  := Math.Max(0, y + self.Top  - MouseDownPos.y);

  //don't trespass left/top of parent container
  if self.Left < 0 then self.Left := 0;
  if self.Top  < 0 then self.Top  := 0;

  iR_PosX := self.Left;
  iR_PosY := self.Top;

  if ShowLinesOnMove then begin
     RedrawLine(True);
     NoticeSonsUpdadeLine;
  end;
end;

procedure THost.SetChangeColor(c: TColor);
begin
  cColor := c;
  Configurar;
end;

procedure THost.SetHostTitle(s: String);
begin
   L.Caption := s;
   L.Refresh;

   self.Refresh;
end;

procedure THost.Configurar;
var
  h: TServiceHost;
  i: Integer = 0;
begin
  T.Brush.Color := cColor;
  L.Caption := sR_Description;

  if Length(sHostTipoNome)=0 then begin
    h := TServiceHost.Create();
    sHostTipoNome := h.HostTipoNome(iR_IDHostTipo);
    h.Free;
  end;

  if Trim(sR_IPLocal) = '' then
    sR_IPLocal := GetIPLocal;

  try
    if MySons <> nil then
      i := MySons.Count;
  finally
  end;

  sTricks := sR_Description +
             ' (' + sHostTipoNome + ')' + sLineBreak +
             'IP: ' + sR_IP + sLineBreak + 'Ping: ' + sStatusPing + sLineBreak +
             'Sub-Hosts: ' + IntToStr(i);

  if (Length(sR_ParentName) > 0) and (Length(sR_IPParentHost) > 0) then
     sTricks := sTricks + sLineBreak + 'Conectado à ' + sR_ParentName + ' (' + sR_IPParentHost + ')';

  self.Hint     := sTricks;
  self.ShowHint := True;
  T.Hint        := sTricks;
  T.Font.Size   := self.Font.Size;
  T.ShowHint    := True;
  L.Hint        := sTricks;
  L.Font.Size   := self.Font.Size;
  L.ShowHint    := True;
end;

procedure THost.SetR_IP(s: String);
begin
  if sR_IP = s then Exit;
  sR_IP := s;
  Configurar;
end;

procedure THost.MouseHand;
begin
  try
    Screen.Cursors[1] := LoadCursorFromLazarusResource('mouse16');
    Screen.Cursor := 1;
  except
    on e: Exception do
      Screen.Cursor := crHandPoint;
  end;
end;

procedure THost.mnuEditHostClick(sender: TObject);
//edit host options
var
  frm: TfrmHost;
  idparent: Integer;
  h: TServiceHost;
begin
  idparent := iR_IDParentHost;
  frm := TfrmHost.Create(self);
  frm.IDHost := iR_ID;
  frm.IDRede := iR_IdRede;
  frm.IDParentHost := iR_IDParentHost;
  frm.ShowModal;

  if frm.MR = 1 then begin //mrOK
     h := TServiceHost.Create;

     iR_ID           := frm.IDHost;
     sR_Description  := Trim(frm.txtTitle.Text);
     sR_IP           := Trim(frm.txtIP.Text);
     iR_IDParentHost := frm.IDParentHost;
     sR_IPParentHost := h.GetHostIP(frm.IDParentHost);
     iR_IDHostTipo   := frm.IDHostTipo;
     sR_ParentName   := frm.ParentHost;

     h.Free;

     SayToSonsChangeProfile();

     if idparent <> iR_IDParentHost then
        OutFromParentHost;

     if not bAcceptLink = frm.chkAcceptLink.Checked then begin
        bAcceptLink := frm.chkAcceptLink.Checked;
        LinkNoticeSons(bAcceptLink);
     end;

     Configurar;
  end
  else if frm.MR = 2 then begin //mrNO
     if frm.ObjectDeleted then begin
        bIAMDead := True;
        DeleteObjectName := self.Name;
     end;
  end;

  frm.Free;
end;

procedure THost.mnuDeleteHostClick(sender: TObject);
var
  h: TServiceHost;
begin
   if MessageDlg('Atenção','Deseja deletar este Host ?', mtConfirmation, mbYesNo, 0) = mrNo then
      exit;

   h := TServiceHost.Create();
   h.Deletar(iR_ID);

   if h.MensagemErro = '' then begin
     bIAMDead := True;

     if CountOffLine = 1 then begin
       CounterOffLine := CounterOffLine - 1;
       if CounterOffLine < 0 then CounterOffLine := 0;
     end;

     DeleteObjectName := self.Name;
   end else
     MessageDlg('Atenção', h.MensagemErro, mtWarning, [mbOK], '');

   h.Free;
end;

procedure THost.mnuMainOnPopup(sender: TObject);
//on show menu, change back color of this host
begin
  self.Color:= clSkyBlue;
end;

procedure THost.mnuMainOnClose(sender: TObject);
//on menu leave, restore back color of this host
begin
  self.Color := self.selfColor;
end;

procedure THost.SetIMADead(b: Boolean);
//this host is dead, remove lines and say to sons about this condition
begin
  bIAmDead := b;
  if b then begin
     sR_IP := '';
     RemoveLine;
     DeadNotice;
  end;
end;

procedure THost.SetR_ID(i: Integer);
begin
  iR_ID := i;

  if i > 0 then
     self.Name := self.Name + IntToStr(i);

  Configurar;
end;

procedure THost.SetLineColor(c: TColor);
begin
  cColor := c;
end;

procedure THost.SetR_Description(s: String);
begin
  sR_Description := s;
  Configurar;
end;

procedure THost.SetR_PosX(i: Integer);
begin
  iR_PosX := i;
  Configurar;
end;

procedure THost.SetR_PosY(i: Integer);
begin
  iR_PosY := i;
  Configurar;
end;

procedure THost.SetR_ParentHostName(s: String);
begin
  sR_ParentHostNameCTRL := s;
  Configurar;
end;

procedure THost.SetR_IPParentHost(s: String);
begin
  sR_IPParentHost := s;
  Configurar;
end;

procedure THost.SetR_IDHostType(i: Integer);
begin
  if iR_IDHostTipo = i then exit;
  iR_IDHostTipo := i;
  Configurar;
end;

procedure THost.DeadNotice;
//say to sons that this host is dead
var
  i: Integer;
  ctr: TComponent;
begin
  for i := 0 to MySons.Count-1 do begin
    ctr := parent.FindComponent(MySons[i]);
    if ctr is THost then
       (ctr as THost).ParentHostIsDead;
  end;
end;

procedure THost.SayToSonsChangeProfile;
//say to sons about new profile of this host
var
  i: Integer;
  ctr: TComponent;
begin
  if MySons.Count < 1 then exit;

  for i := 0 to MySons.Count-1 do begin
    ctr := parent.FindComponent(MySons[i]);
    if ctr is THost then begin
       (ctr as THost).R_ParentName   := sR_Description;
       (ctr as THost).R_IPParentHost := sR_IP;
    end;
  end;
end;

procedure THost.PushNotification;
//envia notificação se offline ou se voltou do offline
var
  g: TServicoPushGotify;
begin
  if (Gotify_Host = '') or (NotificacaoGlobal) then exit;
  
  //notificação
  if (not bIAmOnLine) and (MinutesBetween(Now, FOffLineTime) >= NotificacaoIndividualMinutos) then begin
    //Estou offline 😬😬😬
    bIAmOnLineTemp := False;
    FOffLineTime := Now;

    g := TServicoPushGotify.Create;
    g.Notificar(Gotify_Description, '🚩OffLine: ' + sR_IP + sLineBreak + sR_Description, Gotify_Host, Gotify_AppKey);
    g.Free;
  end
  else if (bIAmOnLine) and (not bIAmOnLineTemp) then begin
    //estava offline e voltou
    bIAmOnLineTemp := True;
    g := TServicoPushGotify.Create;
    g.Notificar(Gotify_Description, '🟢 Online: ' + sR_IP + sLineBreak + sR_Description, Gotify_Host, Gotify_AppKey);
    g.Free;
  end;
end;

procedure THost.UpdateLine;
begin
  RedrawLine(False);
end;

procedure THost.DetachLine(b: Boolean);
begin
  if b then begin
     LineColor := clBlue;
     bHigthligthLine := True;
  end else begin
    LineColor := clBlack;
    bHigthligthLine := False;
  end;

  DetachMyLine;
end;

procedure THost.DetachMyLine;
//change line color
begin
  if lin is TLine then
     lin.LineColor(LineColor);
end;

procedure THost.ShowInfo;
const
  CRLF = #10 + #13;
var
  h: TServiceHost;
  i: Integer = 0;
begin
  h := TServiceHost.Create();

  try
    if MySons <> nil then
       i := MySons.Count;
  finally

  end;

  sTricks := sR_Description + ' (' + h.HostTipoNome(iR_IDHostTipo) + ')' + CRLF +
             'IP: ' + sR_IP + CRLF + 'Ping: ' + sStatusPing + CRLF +
             'Sub-Hosts: ' + i.ToString;

  if (Length(sR_ParentName)>0) and (Length(sR_IPParentHost)>0) then
     sTricks := sTricks + CRLF + 'Conectado à ' + sR_ParentName + ' (' + sR_IPParentHost + ')';

  self.Hint := sTricks;
  T.Hint    := sTricks;
  L.Hint    := sTricks;
  h.Free;
end;

procedure THost.SayToSonsHigthligthLine(b: Boolean);
//Filhos devem desconectar a linha
var
  i: Integer;
  ctr: TComponent;
begin
  for i := 0 to MySons.Count-1 do begin
    ctr := parent.FindComponent(MySons[i]);
    if ctr is THost then
       (ctr as THost).DetachLine(b);
  end;
end;

procedure THost.PingStatus(iTime: Integer);
//Status do ping no Host
var
  ctr: TComponent;
begin
  sStatusPing := IntToStr(iTime) + ' ms';

  if iTime = -1 then // -1 = sem permissão para executar ICMP
    cColor := clRed
  else if iTime < 1 then begin
    cColor := clRed;
    if sR_IPLocal = sR_IP then begin
      //ping na própria máquina pode retornar tempo = 0, o que significa
      //que está respondendo muito rápido.
      cColor := TColor($90EE90); //green
      iTime  := 1;
    end;
  end
  else if iTime < 150 then
    cColor := TColor($90EE90)   //green
  else if iTime < 200 then
    cColor := clYellow
  else
    cColor := RGBToColor(255, 146, 36);  //orange

  bIAmOnLine := (iTime > 0);

  if not bIAmOnLine then begin   //off line
     if Length(OffLineTime) = 0 then
        OffLineTime := FormatDateTime('DD/MM/YYYY hh:nn', Now);

     sStatusPing := 'Timeout (desde ' + OffLineTime + ')';

     if CountOffLine = 0 then begin
        CountOffLine   := 1;
        CounterOffLine := CounterOffLine + 1;
     end;

     PushNotification;
  end else begin
     OffLineTime := '';

     if CountOffLine = 1 then begin
        CountOffLine   := 0;
        CounterOffLine := CounterOffLine - 1;
        if CounterOffLine < 0 then CounterOffLine := 0;
     end;

     PushNotification;
  end;

  FindParentHostCTRL;

  if (Length(sR_ParentHostNameCTRL)>0) and bIAMOnLine then begin
     ctr := parent.FindComponent(sR_ParentHostNameCTRL);

     if (ctr is THost) and ((ctr as THost).IAMOnLine = False) then
        cColor := TColor($EE82EE);
  end;

  Configurar;
  Application.ProcessMessages;
end;

procedure THost.ShowHideLine;
//exibe ou esconde uma linha ligando este host com o host pai
begin
  if iR_IDParentHost > 0 then begin
     if bLinkedLine = False then begin
        bLinkedLine := True;
        DrawLine;
     end else begin
        bLinkedLine := False;
        RemoveLine;
     end;
  end;
end;

procedure THost.DrawLine;
//exibe uma linha ligando este host com o host pai
var
  ctr: TComponent;
begin
  if ShowLines and not bIAMDead then begin
    if lin <> nil then
       RedrawLine(True)
    else begin
      FindParentHostCTRL;

      if Length(sR_ParentHostNameCTRL) < 1 then exit;
      ctr := parent.FindComponent(sR_ParentHostNameCTRL);
      if ctr is THost and (ctr as THost).R_AcceptLink = False then exit;

      FreeAndNil(lin);

      lin := TLine.Create(self.Parent);
      lin.Parent := self.Parent;
      lin.Name   := 'Line_' + IntToStr(iR_ID);
      lin.DrawLine(iR_PosX + trunc(self.Width / 2),
                   iR_PosY + trunc(self.Height / 2),
                   (ctr as THost).R_PosX + trunc((ctr as THost).Width / 2),
                   (ctr as THost).R_PosY + trunc((ctr as THost).Height / 2),
                   LineColor);
    end;
  end;
end;

procedure THost.RedrawLine(bIAM: Boolean);
//atualiza coordenadas, se o host alterar suas coordenadas
var
  ctr: TComponent;
begin
  if (ShowLines) and (not bIAmDead) then begin
    if lin <> nil then begin
       if bIAM then begin
          //este host alterou suas coordenadas
          lin.X1 := iR_PosX + trunc(self.Width / 2);
          lin.Y1 := iR_PosY + trunc(self.Height / 2);
       end else begin
          FindParentHostCTRL;

          if Length(sR_ParentHostNameCTRL) < 1 then exit;
          ctr := parent.FindComponent(sR_ParentHostNameCTRL);

          if ctr is THost then begin
             lin.X1 := iR_PosX + trunc(self.Width / 2);
             lin.Y1 := iR_PosY + trunc(self.Height / 2);
             lin.X2 := (ctr as THost).R_PosX + trunc((ctr as THost).Width / 2);
             lin.Y2 := (ctr as THost).R_PosY + trunc((ctr as THost).Height / 2);
          end;
       end;

       lin.LineColor(LineColor);
       lin.UpdateLine;
    end;
  end;
end;

procedure THost.MouseReleased;
//movendo o host, ao soltar o botão do mouse, salva as coordendas do host no DB
var
  h: TServiceHost;
begin
  h := TServiceHost.Create();
  h.SalvaHostPosicao(iR_ID, self.Left, self.Top);
  h.Free;

  if lin is TLine then
     RedrawLine(True)
  else begin
     RemoveLine;
     DrawLine;
  end;

  NoticeSonsUpdadeLine;
end;

procedure THost.RemoveLine;
//remove a linha ligando este host e o host pai
begin
  if lin is TLine then begin
     bLinkedLine := False;
     FreeAndNil(lin);
  end;
end;

procedure THost.OutFromParentHost;
//desconecta do hosta pai
var
  ctr: TComponent;
begin
  if Length(sR_ParentHostNameCTRL) > 0 then begin
     ctr := parent.FindComponent(sR_ParentHostNameCTRL);
     if ctr is THost then begin
        (ctr as THost).RemoveSon(self.Name);
        sR_ParentHostNameCTRL := '';
        RemoveLine;
        ShowHideLine;
     end;
  end;
end;

procedure THost.LinkNoticeSons(b: Boolean);
//notice sons about accept link or not
var
  i: Integer;
  ctr: TComponent;
begin
  if MySons.Count < 1 then exit;

  for i := 0 to MySons.Count-1 do begin
    ctr := parent.FindComponent(MySons[i]);
    if ctr is THost then
       (ctr as THost).LinkToParentHost(b);
  end;
end;

procedure THost.FindParentHostCTRL;
//find parent host name (control)
var
  i: Integer;
  ctr: TComponent;
begin
  if Length(sR_ParentHostNameCTRL) > 0 then exit;

  for i := 0 to parent.ComponentCount -1 do begin
    if parent.Components[i] is THost then begin
      if ((THost(parent.Components[i]).R_ID = iR_IDParentHost) and (iR_IDParentHost>=0)) then begin
        ctr := parent.Components[i];
        sR_ParentHostNameCTRL := THost(ctr).Name;
        (ctr as THost).AddSon(self.Name);
        exit;
      end;
    end;
  end;
end;

procedure THost.ControlMouseEnter(Sender: TObject);
begin
  if not MouseMovingObject then begin
     ShowInfo;
     SayToSonsHigthligthLine(True);
     DetachLine(True);
  end;
end;

procedure THost.ControlMouseLeave(Sender: TObject);
begin
  if not MouseMovingObject then begin
     self.Hint := '';
     SayToSonsHigthligthLine(false);
     DetachLine(False);
  end;
end;

procedure THost.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
     MouseMovingObject := True;
     MouseDownPos.X := X;
     MouseDownPos.Y := Y;
     DragEnabled := True;
     MouseHand();
     Refresh;
  end;

  if Button = mbRight then begin
     mnuMain.Parent := self;
     mnuMain.PopUp;
  end;
end;

procedure THost.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled := False;
  Screen.Cursor := crDefault;
  MouseMovingObject := False;

  if Button = mbLeft then
     MouseReleased;
end;

procedure THost.ControlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if DragEnabled then begin
    if Sender is TObject then begin
       if self.Left + (X - MouseDownPos.X)>=0 then
          self.Left := self.Left + (X - MouseDownPos.X);

       if self.Top + (Y - MouseDownPos.Y)>=0 then
          self.Top := self.Top + (Y - MouseDownPos.Y);
    end;

    iR_PosX := self.Left;
    iR_PosY := self.Top;

    if ShowLinesOnMove then begin
       RedrawLine(True);
       NoticeSonsUpdadeLine;
    end;
  end;
end;

procedure THost.TMouseEnter(Sender: TObject);
begin
  if not MouseMovingObject then begin
     ShowInfo;
     SayToSonsHigthligthLine(True);
     DetachLine(True);
  end;
end;

procedure THost.TMouseLeave(Sender: TObject);
begin
  if not MouseMovingObject then begin
     T.Hint := '';
     SayToSonsHigthligthLine(False);
     DetachLine(False);
  end;
end;

procedure THost.TMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
     MouseMovingObject := True;
     MouseDownPos.X := X;
     MouseDownPos.Y := Y;
     DragEnabled := True;
     MouseHand();
     Refresh;
  end;

  if Button = mbRight then begin
     mnuMain.Parent := T;
     mnuMain.PopUp;
  end;

end;

procedure THost.TMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled := False;
  Screen.Cursor := crDefault;
  MouseMovingObject := False;

  if Button = mbLeft then
     MouseReleased;
end;

procedure THost.TMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if DragEnabled then
     MoveObject(X,Y);
end;

procedure THost.LMouseEnter(Sender: TObject);
begin
  if not MouseMovingObject then begin
     ShowInfo;
     SayToSonsHigthligthLine(True);
     DetachLine(True);
  end;
end;

procedure THost.LMouseLeave(Sender: TObject);
begin
  if not MouseMovingObject then begin
     T.Hint := '';
     SayToSonsHigthligthLine(False);
     DetachLine(False);
  end;
end;

procedure THost.LMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
     MouseMovingObject := True;
     Refresh;
     MouseDownPos.X := X;
     MouseDownPos.Y := Y;
     DragEnabled    := True;
     MouseHand();
  end;

  if Button = mbRight then begin
     mnuMain.Parent := L;
     mnuMain.PopUp;
  end;
end;

procedure THost.LMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled := False;
  Screen.Cursor := crDefault;
  MouseMovingObject := False;

  if Button = mbLeft then
     MouseReleased;
end;

procedure THost.LMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if DragEnabled then
     MoveObject(X,Y);
end;

procedure THost.ParentHostIsDead;
begin
  //Parent Host is dead, so, notice your sons to disconnect from him
  RemoveLine;
  sR_ParentHostNameCTRL := '';
  iR_IDParentHost := -1;
end;

procedure THost.LinkToParentHost(b: Boolean);
//say to host sons if accept ou not connection by line
begin
  if b then begin
     sR_ParentHostNameCTRL := '';
     bLinkedLine := False;
     ShowHideLine;
  end else
     RemoveLine;
end;

procedure THost.AddSon(sSonName: String);
//saves child host name
begin
  if MySons.IndexOf(sSonName)<0 then
     MySons.Add(sSonName);
end;

procedure THost.RemoveSon(sSonName: String);
//delete child host name
var
  i: Integer;
begin
  i := MySons.IndexOf(sSonName);

  if i >= 0 then
     MySons.Delete(i);
end;

procedure THost.NoticeSonsUpdadeLine;
//diz a seus filhos para atualizar as coordenadas da linha
var
  i: Integer;
  ctr: TComponent;
begin
  if MySons.Count < 1 then exit;

  for i := 0 to MySons.Count-1 do begin
    ctr := parent.FindComponent(MySons[i]);
    if ctr is THost then
       (ctr as THost).UpdateLine;
  end;
end;

initialization
{$I mousehand.lrs}
{$I host.lrs}

end.

