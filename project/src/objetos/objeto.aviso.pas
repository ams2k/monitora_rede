unit Objeto.Aviso;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, DateUtils, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math, Menus;

type

  { TAviso }

  TAviso = class(TPanel)
  private
    picIcon: TImage;
    txtMemo: TMemo;
    lblSalvar: TLabel;
    lblDeletar: TLabel;
    lblFechar: TLabel;
    tmrAviso: TTimer;
    MouseDownPos : TPoint;
    DragEnabled : Boolean;

    iIDAviso: Integer;
    iIDRede: Integer;
    sAviso: String;
    iPosX: Integer;
    iPosY: Integer;
    procedure MoveObjeto(X,Y: Integer);
    procedure SetAviso(AValue: String);
    procedure tmrAvisoTimer(Sender: TObject);
    procedure SetPosX(i: Integer);
    procedure SetPosY(i: Integer);
    procedure MouseHand;
    procedure MouseReleased;
    procedure SalvaAviso;
    procedure DeletaAviso;
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure picIconMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure picIconMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure picIconMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lblSaveClick(Sender: TObject);
    procedure lblDeleClick(Sender: TObject);
    procedure lblCloseClick(Sender: TObject);
  published
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnClick;
    property Parent;
    property Name;
    property PosX: Integer read iPosX write iPosX default 100;
    property PosY: Integer read iPosY write iPosY default 100;
    property Texto: String read sAviso write SetAviso;
    property IDAviso: Integer read iIDAviso write iIDAviso;
    property IDRede: Integer read iIDRede write iIDRede;
  end;

implementation

uses
  Service.Aviso, Funcoes;

{ TAviso }

procedure TAviso.MoveObjeto(X, Y: Integer);
begin
  if ( (self.Left = Math.Max(0, X + self.Left - MouseDownPos.x)) and
       (self.Top  = Math.Max(0, Y + self.Top  - MouseDownPos.y)) ) then begin
       //se não houver mudança na postição do Aviso
       Exit;
  end;

  self.Left := Math.Max(0, x + self.Left - MouseDownPos.x);
  self.Top  := Math.Max(0, y + self.Top  - MouseDownPos.y);

  //não ultrapassa o left/top do container pai
  if self.Left < 0 then self.Left := 0;
  if self.Top  < 0 then self.Top  := 0;

  iPosX := self.Left;
  iPosY := self.Top;
end;

procedure TAviso.SetAviso(AValue: String);
begin
  if sAviso = AValue then Exit;
  sAviso := AValue;
  txtMemo.Lines.Text := AValue;
end;

procedure TAviso.tmrAvisoTimer(Sender: TObject);
begin
  lblSalvar.Enabled  := (Length(Trim(txtMemo.Lines.Text))>0);
  lblDeletar.Enabled := (iIDAviso>0);
end;

procedure TAviso.SetPosX(i: Integer);
begin
  iPosX     := i;
  self.Left := i;
end;

procedure TAviso.SetPosY(i: Integer);
begin
  iPosY     := i;
  self.PosY := i;
end;

procedure TAviso.MouseHand;
begin
  try
    Screen.Cursors[1] := LoadCursorFromLazarusResource('mouse16');
    Screen.Cursor := 1;
  except
    on e: Exception do
      Screen.Cursor := crHandPoint;
  end;
end;

procedure TAviso.MouseReleased;
//ao move o Aviso, ao soltar o botão do mouse, salva a postição no banco de dados
var
  c: TServiceAviso;
begin
  c := TServiceAviso.Create;
  c.SalvaPosicao(iIDAviso, self.Left, self.Top);
  c.Free;
end;

procedure TAviso.SalvaAviso;
//salva informações no DB
var
  n: TServiceAviso;
begin
  n := TServiceAviso.Create;
  n.IDAviso := iIDAviso;
  n.IDRede  := iIDRede;
  n.PosX    := iPosX;
  n.PosY    := iPosY;
  n.Texto   := txtMemo.Lines.Text.Trim;
  n.Salvar(iIDAviso);

  if n.MensagemErro = '' then begin
    iIDAviso := n.IDAviso;
    MessageDlg('Salvando', n.Mensagem, mtInformation, [mbOK], 0);
  end else
    MessageDlg('Atenção', n.MensagemErro, mtWarning, [mbOK], 0);

  n.Free;
end;

procedure TAviso.DeletaAviso;
//delete information from DB
var
  n: TServiceAviso;
begin
  n := TServiceAviso.Create;
  n.Deletar(iIDAviso);

  if n.MensagemErro = '' then
    DeleteObjectName := self.Name
  else
    MessageDlg('Atenção', n.MensagemErro, mtWarning, [mbOK], 0);

  n.Free;
end;

constructor TAviso.Create(AOwner: TComponent);
var
  snum: String = '';
  i: Integer;
begin
  inherited Create(AOwner);

  for i := 1 to 10 do
     snum := snum + IntToStr(Random(23)+1) + chr(Random(26)+65);

  //Este objeto
  self.Name := 'Aviso' + snum + FormatDateTime('zzz', Now);
  self.Left := iPosX;
  self.Top  := iPosY;
  self.Width  := 175;
  self.Height := 166;
  self.Color  := TColor($00D5FFFF);
  self.BorderStyle := bsSingle;
  self.BevelOuter  := bvNone;
  self.Caption     := '';
  self.Refresh;

  OnMouseDown := @ControlMouseDown;
  OnMouseUp   := @ControlMouseUp;
  OnMouseMove := @ControlMouseMove;

  //picIcon
  picIcon := TImage.Create(self);
  picIcon.Name := 'picAviso';
  picIcon.Left := 73;
  picIcon.Top  := 1;
  picIcon.Parent   := Self;
  picIcon.AutoSize := True;
  picIcon.Stretch  := True;
  picIcon.Picture.LoadFromLazarusResource('notice16');
  picIcon.OnMouseDown := @picIconMouseDown;
  picIcon.OnMouseUp   := @picIconMouseUp;
  picIcon.OnMouseMove := @picIconMouseMove;

  //lblFechar
  lblFechar := TLabel.Create(Self);
  lblFechar.Name := 'lblFechar';
  lblFechar.Left := 156;
  lblFechar.Top  := 6;
  lblFechar.Parent  := Self;
  lblFechar.Caption := 'X';
  lblFechar.Font.Style := [fsUnderline];
  lblFechar.ShowHint   := True;
  lblFechar.Hint := 'Fecha este aviso';
  lblFechar.Cursor  := crHandPoint;
  lblFechar.OnClick := @lblCloseClick;

  //txtMemo
  txtMemo := TMemo.Create(Self);
  txtMemo.Name := 'txtMemo';
  txtMemo.Left := 5;
  txtMemo.Top  := 27;
  txtMemo.Parent := Self;
  txtMemo.Width  := 161;
  txtMemo.Height := 115;
  txtMemo.Color  := clWhite; // TColor($00D5FFFF);
  txtMemo.Font.Size := 8;
  txtMemo.Lines.Text := '';

  //lblSalvar
  lblSalvar := TLabel.Create(self);
  lblSalvar.Name := 'lblSalvar';
  lblSalvar.Left := 77;
  lblSalvar.Top  := 145;
  lblSalvar.Parent  := Self;
  lblSalvar.Caption := 'salvar';
  lblSalvar.Font.Size := 8;
  lblSalvar.Font.Color := clBlue;
  lblSalvar.ShowHint := True;
  lblSalvar.Hint := 'Salva este aviso';
  lblSalvar.Cursor  := crHandPoint;;
  lblSalvar.OnClick := @lblSaveClick;

  //lblDeletar
  lblDeletar := TLabel.Create(self);
  lblDeletar.Name := 'lblDeletar';
  lblDeletar.Left := 120;
  lblDeletar.Top  := 145;
  lblDeletar.Parent := Self;
  lblDeletar.Caption := 'deletar';
  lblDeletar.Font.Size := 8;
  lblDeletar.Font.Color := clBlue;
  lblDeletar.ShowHint := True;
  lblDeletar.Hint := 'Deleta este aviso';
  lblDeletar.Cursor  := crHandPoint;
  lblDeletar.OnClick := @lblDeleClick;

  //tmrAviso
  tmrAviso := TTimer.Create(self);
  tmrAviso.Name := 'tmrAviso';
  tmrAviso.Interval := 500;
  tmrAviso.OnTimer  := @tmrAvisoTimer;
  tmrAviso.Enabled  := True;

  self.BringToFront;
end;

destructor TAviso.Destroy;
begin
  inherited Destroy;
end;

procedure TAviso.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    MouseDownPos.X := X;
    MouseDownPos.Y := Y;
    DragEnabled    := True;
    MouseHand();
    BringToFront;
  end;
end;

procedure TAviso.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled   := False;
  Screen.Cursor := crDefault;

  if Button = mbLeft then
     MouseReleased;
end;

procedure TAviso.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if DragEnabled then begin
    if Sender is TObject then begin
       if self.Left + (X - MouseDownPos.X) >= 0 then
          self.Left := self.Left + (X - MouseDownPos.X);

       if self.Top + (Y - MouseDownPos.Y) >= 0 then
          self.Top := self.Top + (Y - MouseDownPos.Y);
    end;

    BringToFront;
  end;
end;

procedure TAviso.picIconMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
     MouseDownPos.X := X;
     MouseDownPos.Y := Y;
     DragEnabled    := True;
     MouseHand();
     BringToFront;
  end;
end;

procedure TAviso.picIconMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled   := False;
  Screen.Cursor := crDefault;

  if Button = mbLeft then
     MouseReleased;
end;

procedure TAviso.picIconMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if DragEnabled then
     MoveObjeto(X, Y);
end;

procedure TAviso.lblSaveClick(Sender: TObject);
begin
  SalvaAviso;
end;

procedure TAviso.lblDeleClick(Sender: TObject);
begin
  if MessageDlg('Atenção','Deseja deletar este aviso ?', mtConfirmation, mbYesNo, 0) = mrNo then
     Exit;

  DeletaAviso;
end;

procedure TAviso.lblCloseClick(Sender: TObject);
//remove este aviso da tela
begin
  DeleteObjectName := self.Name;
end;

initialization
{$I mousehand.lrs}
{$I aviso.lrs}

end.

