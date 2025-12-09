unit Objeto.Line;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, ExtCtrls, Math;

type

  { TLine }

  TLine = class(TGraphicControl)
    private
      Timer1: TTimer;
      fx1, fy1, fx2, fy2: Integer;
      ncolor: TColor;
      procedure Timer1Timer(Sender: TObject);
    protected
      procedure Paint; override;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure DrawLine(x1, y1, x2, y2: Integer; linColor: TColor);
      procedure LineColor(linColor: TColor);
      procedure UpdateLine;
      procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    published
      property Parent;
      property DragCursor;
      property DragKind;
      property DragMode;
      property Align;
      property AutoSize;
      property ParentShowHint;
      property Hint;
      property ShowHint;
      property Visible;
      property PopupMenu;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
      property OnEndDock;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnClick;
      property OnDblClick;
      property X1: Integer read fx1 write fx1;
      property Y1: Integer read fy1 write fy1;
      property X2: Integer read fx2 write fx2;
      property Y2: Integer read fy2 write fy2;
  end;

implementation

uses
  Funcoes;

{ TLine }

procedure TLine.Timer1Timer(Sender: TObject);
var
  AHeight, AWidth: Integer;
begin
  AHeight :=  Max(Parent.VertScrollBar.Range, Parent.Height);
  AWidth  := Max(Parent.HorzScrollBar.Range, Parent.Width);

  //if (self.Width <> Parent.Width) or (self.Height <> Parent.Height) then begin
  //  //Self.Width  := Parent.Width;
  //  //Self.Height := Parent.Height;
  //  Self.Width := Parent.ClientWidth;
  //  Self.Height := parent.ClientHeight;
  //  Self.Refresh;
  //  Canvas.Refresh;
  //end;

  if (self.Width <> AWidth) or (self.Height <> AHeight) then begin
    Self.Width  := AWidth;
    Self.Height := AHeight;
    Self.Refresh;
    Canvas.Refresh;
  end;
end;

procedure TLine.Paint;
begin
  inherited Paint;
  with Canvas do begin
     Pen.Style := psSolid;
     Pen.Color := ncolor;
     Line(fx1, fy1, fx2, fy2);
  end;
end;

constructor TLine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := True;
  fx1 := 0;
  fy1 := 0;
  fx2 := 0;
  fy2 := 0;
  Timer1 := TTimer.Create(self);
  Timer1.Interval := 500;
  Timer1.OnTimer  := @Timer1Timer;
  Timer1.Enabled  := True;
  OnMouseDown     := @ControlMouseDown;
end;

destructor TLine.Destroy;
begin
  inherited Destroy;
end;

procedure TLine.DrawLine(x1, y1, x2, y2: Integer; linColor: TColor);
begin
  fx1 := x1;
  fy1 := y1;
  fx2 := x2;
  fy2 := y2;
  ncolor := linColor;
  Invalidate;
end;

procedure TLine.LineColor(linColor: TColor);
begin
  ncolor := linColor;
  Invalidate;
end;

procedure TLine.UpdateLine;
begin
  Invalidate;
end;

procedure TLine.ControlMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then begin
     MenuObjectsPoint := Point(X,Y);
     ShowMenuObjects  := True;
  end;
end;

end.

