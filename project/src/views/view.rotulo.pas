unit View.Rotulo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, LResources;

type

  { TfrmRotulo }

  TfrmRotulo = class(TForm)
    btnSave: TBitBtn;
    chkPulse: TCheckBox;
    chkBorder: TCheckBox;
    chkUnderline: TCheckBox;
    chkBold: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    shpFontColor: TShape;
    shpBackColor: TShape;
    txtCaption: TEdit;
    Label1: TLabel;
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure shpBackColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpFontColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure txtCaptionEnter(Sender: TObject);
    procedure txtCaptionExit(Sender: TObject);
  private
    IDRede: Integer;
    PosX: Integer;
    PosY: Integer;
    procedure GetRotulo(id: Integer);
    procedure SalvaRotulo;
  public
    IDRotulo: Integer;
    //retorna
    LabelText: String;
    FontColor: String;
    BackColor: String;
    Bold: Boolean;
    Underline: Boolean;
    Pulse: Boolean;
    Border: Boolean;
    MR: Integer;
  end;

var
  frmRotulo: TfrmRotulo;

implementation

uses
  Funcoes, Service.Rotulo;

{$R *.lfm}

{ TfrmRotulo }

procedure TfrmRotulo.FormCreate(Sender: TObject);
begin
  shpFontColor.Brush.Color := clBlack;
  shpBackColor.Brush.Color := clWhite;
 end;

procedure TfrmRotulo.btnSaveClick(Sender: TObject);
begin
  if Trim(txtCaption.Text) = '' then begin
     MessageDlg('Atenção','Informe um texto para o Rótulo.', mtInformation, [mbOK], 0);
     Exit;
  end;

  SalvaRotulo;
end;

procedure TfrmRotulo.FormShow(Sender: TObject);
begin
  shpFontColor.Brush.Color := TColor($000000);
  shpBackColor.Brush.Color := TColor($ffffff);
  MR := 0;

  if IDRotulo > 0 then
     GetRotulo(IDRotulo);
end;

procedure TfrmRotulo.shpBackColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  c: TColorDialog;
begin
  c := TColorDialog.Create(self);
  c.Title := 'Selecione a cor de fundo.';
  if c.Execute then
     shpBackColor.Brush.Color := c.Color;

  c.Free;
end;

procedure TfrmRotulo.shpFontColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  c: TColorDialog;
begin
  c := TColorDialog.Create(self);
  c.Title := 'Selecione a cor da fonte.';
  if c.Execute then
     shpFontColor.Brush.Color := c.Color;

  c.Free;
end;

procedure TfrmRotulo.txtCaptionEnter(Sender: TObject);
begin
  TextBox(sender, True);
end;

procedure TfrmRotulo.txtCaptionExit(Sender: TObject);
begin
  TextBox(sender, False);
end;

procedure TfrmRotulo.GetRotulo(id: Integer);
//obtṕem informações do Rótulo no DB
var
  c: TServiceRotulo;
begin
  c := TServiceRotulo.Create;
  c.Ler(id);

  if c.MensagemErro = '' then begin
     txtCaption.Text      := c.Titulo;
     chkBold.Checked      := c.Bold;
     chkUnderline.Checked := c.Underline;
     chkBorder.Checked    := c.Border;
     chkPulse.Checked     := c.Pulse;
     shpFontColor.Brush.Color := StringToColor(c.FontColor);
     shpBackColor.Brush.Color := StringToColor(c.BackColor);
     PosX   := c.Posx;
     PosY   := c.Posy;
     IDRede := c.IdRede;
  end else begin
    MessageDlg('Atenção', c.MensagemErro, mtWarning, [mbOK], 0);
    MR := 2; //mbNo
    Close;
  end;

  c.Free;
end;

procedure TfrmRotulo.SalvaRotulo;
//Salva as informações do Rótulo no DB
var
  c: TServiceRotulo;
begin
  c := TServiceRotulo.Create;
  c.IdRotulo  := IDRotulo;
  c.Posx      := PosX;
  c.Posy      := PosY;
  c.Titulo    := Trim(txtCaption.Text);
  c.IdRede    := IDRede;
  c.Bold      := chkBold.Checked;
  c.Underline := chkUnderline.Checked;
  c.Pulse     := chkPulse.Checked;
  c.Border    := chkBorder.Checked;
  c.FontColor := ColorToString(shpFontColor.Brush.Color);
  c.BackColor := ColorToString(shpBackColor.Brush.Color);
  c.Salvar(IDRotulo);

  if c.MensagemErro = '' then begin
     self.LabelText := txtCaption.Text;
     self.Bold      := chkBold.Checked;
     self.Underline := chkUnderline.Checked;
     self.Pulse     := chkPulse.Checked;
     self.Border    := chkBorder.Checked;
     self.FontColor := ColorToString(shpFontColor.Brush.Color);
     self.BackColor := ColorToString(shpBackColor.Brush.Color);
     self.MR        := 1; //mrbOK
     Close;
  end else
    MessageDlg('Atenção', c.MensagemErro, mtWarning, [mbOK], 0);

  c.Free;
end;

end.

