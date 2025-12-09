unit Objeto.Rotulo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, DateUtils, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math, Menus;

type

  { TRotulo }

  TRotulo = class(TPanel)
  private
    cColor: TColor;
    tmrRotulo: TTimer;
    L: TLabel;
    MouseDownPos : TPoint;
    DragEnabled : Boolean;
    mnuMain: TPopupMenu;
    mnuEditRotulo: TMenuItem;
    mnuSep: TMenuItem;
    mnuDeletaRotulo: TMenuItem;
    MyBackColor: TColor;

    iIDRotulo: Integer;  //ID of label on database
    iIDRede: Integer;
    sTexto: String;
    iPosX: Integer;
    iPosY: Integer;
    bBold: Boolean;
    bUnderline: Boolean;
    bPulse: Boolean;
    bBorder: Boolean;
    cFontColor: TColor;
    cBackColor: TColor;
    procedure MoveObject(X,Y: Integer);
    procedure tmrLabelTimer(Sender: TObject);
    procedure MouseHand;
    procedure mnuEditLabelClick(sender: TObject);
    procedure mnuDeleteLabelClick(sender: TObject);
    procedure mnuMainOnPopup(sender: TObject);
    procedure mnuMainOnClose(sender: TObject);
    procedure SetText(s: String);
    procedure SetPosX(i: Integer);
    procedure SetPosY(i: Integer);
    procedure SetFontColor(c: TColor);
    procedure SetBackColor(c: TColor);
    procedure SetBold(b: Boolean);
    procedure SetUnderline(b: Boolean);
    procedure SetBorder(b: Boolean);
    procedure MouseReleased;
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InicializaRotulo(idtit, idrede1, x, y: Integer);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure LMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Configurar;
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
    property Text: String read sTexto write SetText;
    property IDRotulo: Integer read iIDRotulo write iIDRotulo;
    property IDRede: Integer read iIDRede write iIDRede;
    property FontColor: TColor read cColor write SetFontColor;
    property BackColor: TColor read cColor write SetBackColor;
    property Bold: Boolean read bBold write SetBold;
    property Underline: Boolean read bUnderline write SetUnderline;
    property Pulse: Boolean read bPulse write bPulse;
    property Border: Boolean read bBorder write  SetBorder;
  end;

implementation

uses
  View.Rotulo, Service.Rotulo, Funcoes;

{ TRotulo }

procedure TRotulo.MoveObject(X, Y: Integer);
begin
   if ( (self.Left = Math.Max(0, X + self.Left - MouseDownPos.x)) and
       (self.Top   = Math.Max(0, Y + self.Top  - MouseDownPos.y)) ) then begin
       //se não houver mudanças na posição do Rótulo
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

procedure TRotulo.Configurar;
var
  fs: TFontStyles;
begin
  fs := [];

  if bBold then fs := fs + [fsBold];
  if bUnderline then fs := fs + [fsUnderline];

  L.Font.Color := cFontColor;
  L.Font.Style := fs;
  L.Caption    := sTexto;
  L.Refresh;

  self.Color    := cBackColor;
  self.AutoSize := False;
  self.Width    := L.Width + 12;
  self.Height   := L.Height + 8;
  self.Refresh;

  L.Top  := trunc((self.Height-L.Height)/2)-1;
  L.Left := trunc((self.Width-L.Width)/2)-1;
  L.Refresh;
end;

procedure TRotulo.tmrLabelTimer(Sender: TObject);
begin
  if bPulse then begin
    L.Visible := not L.Visible;

    if L.Visible then
      tmrRotulo.Interval := 1500
    else
      tmrRotulo.Interval := 300;
  end else
    L.Visible := True;
end;

procedure TRotulo.MouseHand;
begin
  try
    Screen.Cursors[1] := LoadCursorFromLazarusResource('mouse16');
    Screen.Cursor := 1;
  except
    on e: Exception do
      Screen.Cursor := crHandPoint;
  end;
end;

procedure TRotulo.mnuEditLabelClick(sender: TObject);
//edit label information
var
  frm: TfrmRotulo;
begin
  frm := TfrmRotulo.Create(nil);
  frm.IDRotulo := iIDRotulo;
  frm.ShowModal;

  if frm.MR = 1 then begin
     self.Text       := frm.LabelText;
     self.bBold      := frm.Bold;
     self.bUnderline := frm.Underline;
     self.bPulse     := frm.Pulse;
     self.bBorder    := frm.Border;
     self.cFontColor := StringToColor(frm.FontColor);
     self.cBackColor := StringToColor(frm.BackColor);
     Configurar;
  end;

  frm.Free;
end;

procedure TRotulo.mnuDeleteLabelClick(sender: TObject);
//delete this label brom DB
var
  c: TServiceRotulo;
begin
  if MessageDlg('Atenção','Deseja deletar este Rótulo ?', mtConfirmation, mbYesNo, 0) = mrNo then
    exit;

  c := TServiceRotulo.Create;
  c.Deletar(iIDRotulo);
  c.Free;

  DeleteObjectName := self.Name;
end;

procedure TRotulo.mnuMainOnPopup(sender: TObject);
begin
  MyBackColor := self.Color;
  self.Color  := clSkyBlue;
end;

procedure TRotulo.mnuMainOnClose(sender: TObject);
begin
  self.Color := MyBackColor;
end;

procedure TRotulo.SetText(s: String);
begin
  sTexto := s;
  Configurar;
end;

procedure TRotulo.SetPosX(i: Integer);
begin
  iPosX     := i;
  self.Left := i;
end;

procedure TRotulo.SetPosY(i: Integer);
begin
  iPosY    := i;
  self.Top := i;
end;

procedure TRotulo.SetFontColor(c: TColor);
begin
  cFontColor := c;
  Configurar;
end;

procedure TRotulo.SetBackColor(c: TColor);
begin
  cBackColor := c;
  Configurar;
end;

procedure TRotulo.SetBold(b: Boolean);
begin
  bBold := b;
  Configurar;
end;

procedure TRotulo.SetUnderline(b: Boolean);
begin
  bUnderline := b;
  Configurar;
end;

procedure TRotulo.SetBorder(b: Boolean);
begin
  bBorder := b;

  if b then
     self.BorderStyle := bsSingle
  else
     self.BorderStyle := bsNone;
end;

procedure TRotulo.MouseReleased;
//moving label, on release mouse button, saves label position on DB
var
  c: TServiceRotulo;
begin
  c := TServiceRotulo.Create;
  c.SalvarPosicao(iIDRotulo, self.Left, self.Top);
  c.Free;
end;

constructor TRotulo.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TRotulo.Destroy;
begin
  inherited Destroy;
end;

procedure TRotulo.InicializaRotulo(idtit, idrede1, x, y: Integer);
//Initialize label
var
  snum: string = '';
  i: Integer;
  m: TServiceRotulo;
begin
  inherited;
  iIDRotulo := idtit;
  iIDRede   := idrede1;
  sTexto    := 'Novo Rótulo';
  MyBackColor := clDefault;
  cFontColor  := TColor($000000);
  cBackColor  := TColor($ffffff);

  L := TLabel.Create(self);
  L.Left := 6;
  L.Top  := 2;
  L.Font.Color := clBlack;
  L.Caption  := sTexto + ' ';
  L.AutoSize := True;
  L.Name := 'Label_1';
  L.Parent := self;
  L.Visible := True;
  L.OnMouseDown := @LMouseDown;
  L.OnMouseUp   := @LMouseUp;
  L.OnMouseMove := @LMouseMove;
  L.Caption := sTexto;
  L.Refresh;

  for i := 1 to 10 do
    snum := snum + IntToStr(Random(23)+1) + chr(Random(26)+65);

  self.AutoSize := False;
  self.BorderSpacing.Around := 3;
  self.Top  := x;
  self.Left := y;
  self.BorderStyle := bsNone;
  self.BevelOuter  := bvNone;
  self.Color := clDefault;
  self.Name  := 'Label' + snum + FormatDateTime('zzz', Now);
  self.Caption := '';
  self.Refresh;

  OnMouseDown := @ControlMouseDown;
  OnMouseUp   := @ControlMouseUp;
  OnMouseMove := @ControlMouseMove;

  tmrRotulo := TTimer.Create(self);
  tmrRotulo.Interval := 500;
  tmrRotulo.OnTimer  := @tmrLabelTimer;
  tmrRotulo.Enabled  := True;

  //Main menu
  mnuMain := TPopupMenu.Create(self);
  mnuMain.OnPopup := @mnuMainOnPopup;
  mnuMain.OnClose := @mnuMainOnClose;
  //Menu Item: mnuEditRotulo
  mnuEditRotulo := TMenuItem.Create(self);
  mnuEditRotulo.Caption := 'Editar Rótulo';
  mnuEditRotulo.Bitmap.LoadFromLazarusResource('pencil_16');
  mnuEditRotulo.OnClick := @mnuEditLabelClick;
  //Menu Item: mnuSep
  mnuSep := TMenuItem.Create(self);
  mnuSep.Caption := '-';
  //Menu Item: mnuDeletaRotulo
  mnuDeletaRotulo := TMenuItem.Create(self);
  mnuDeletaRotulo.Caption := 'Deletar Rótulo';
  mnuDeletaRotulo.Bitmap.LoadFromLazarusResource('delete_16');
  mnuDeletaRotulo.OnClick := @mnuDeleteLabelClick;
  //Add Items to mnuMain
  mnuMain.Items.Add(mnuEditRotulo);
  mnuMain.Items.Add(mnuSep);
  mnuMain.Items.Add(mnuDeletaRotulo);

  if idtit > 0 then
     IDRotulo := idtit
  else
     begin
       m := TServiceRotulo.Create;
       m.Titulo    := sTexto;
       m.IdRede    := idrede1;
       m.Bold      := False;
       m.Underline := False;
       m.Pulse     := False;
       m.Border    := False;
       m.FontColor := ColorToString(TColor($000000));
       m.BackColor := ColorToString(TColor($ffffff));
       m.Salvar(IDRotulo);

       if m.MensagemErro = '' then
          IDRotulo := m.IdRotulo;

       m.Free;
     end;

  Configurar;
end;

procedure TRotulo.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    MouseDownPos.X := X;
    MouseDownPos.Y := Y;
    DragEnabled    := True;
    MouseHand();
    BringToFront;
    Refresh;
  end;

  if Button = mbRight then begin
    mnuMain.Parent := self;
    mnuMain.PopUp;
  end;
end;

procedure TRotulo.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled   := False;
  Screen.Cursor := crDefault;

  if Button = mbLeft then
     MouseReleased;
end;

procedure TRotulo.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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

procedure TRotulo.LMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
     MouseDownPos.X := X;
     MouseDownPos.Y := Y;
     DragEnabled    := True;
     MouseHand();
     BringToFront;
     Refresh;
  end;

  if Button = mbRight then begin
     mnuMain.Parent := Self;
     mnuMain.PopUp;
  end;
end;

procedure TRotulo.LMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragEnabled   := False;
  Screen.Cursor := crDefault;

  if Button = mbLeft then
     MouseReleased;
end;

procedure TRotulo.LMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if DragEnabled then
     MoveObject(X,Y);
end;

initialization
{$I mousehand.lrs}
{$I host.lrs}

end.

