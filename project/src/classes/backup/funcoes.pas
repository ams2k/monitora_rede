unit Funcoes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Graphics, LCLType, LResources, blcksock;

  procedure TextBox(var obj: TObject; b: Boolean);
  procedure ComboBox_Select(var cbox: TComboBox; AValue: Integer);
  function ComboBox_GetValue(var cbox: TComboBox): Integer;
  function ComboBox_GetIndexByValue(cbox: TComboBox; AValue: Integer): Integer;
  function GetIPLocal: String;

var
  ShowLines: Boolean = False;
  ShowLinesOnMove: Boolean = False;
  DeleteObjectName: String = '';
  ShowMenuObjects: Boolean;
  MenuObjectsPoint: TPoint;
  MouseMovingObject: Boolean = False;
  CounterOffLine: Integer = 0;
  ParentWidth: Integer = 1000;
  ParentHeight: Integer = 1000;
  NotificacaoGlobal: Boolean = False; //se True, cada host não envia a notificação, fica a cargo do View.Main
  NotificacaoIndividualMinutos: Integer = 30; //cada host envia notificação a cada XX minutos
  Gotify_Host: string = '';
  Gotify_AppKey: string = '';

implementation

uses
  ComboBoxItemData;

procedure TextBox(var obj: TObject; b: Boolean);
//change EditBox background color on focus and lost focus
begin
  if b then begin
      if obj Is TEdit then (obj As Tedit).Color := TColor($00D5FFFF);
      if obj Is TMemo then (obj As TMemo).Color := TColor($00D5FFFF);
  end else begin
    if obj Is TEdit then (obj As TEdit).Color := clWhite;
    if obj Is TMemo then (obj As TMemo).Color := clWhite;
  end;
end;

{ Seleciona o item na combobox conforme o AValue/ID indicado }
procedure ComboBox_Select(var cbox: TComboBox; AValue: Integer);
var
  i: Integer;
begin
  for i := 0 to cbox.Items.Count -1 do
    if TComboBoxItemData( cbox.Items.Objects[i] ).Value = AValue then begin
      cbox.ItemIndex := i;
      Break;
    end;
end;

{ Retorna o Value/ID do item selecionado na combobox }
function ComboBox_GetValue(var cbox: TComboBox): Integer;
begin
  Result := 0;

  if cbox.Items.Count > 0 then begin
     try
       Result := TComboBoxItemData( cbox.Items.Objects[ cbox.ItemIndex ] ).Value;
     except
     end;
  end;
end;

{ Retorna o indice do item conforme o AValue/ID a ser pesquisado }
function ComboBox_GetIndexByValue(cbox: TComboBox; AValue: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  try
    for i := 0 to cbox.Items.Count -1 do
      if TComboBoxItemData( cbox.Items.Objects[ i ] ).Value = AValue then begin
         Result := i;
         Break;
      end;
  except
  end;
end;

function GetIPLocal: String;
//Retorna uma lista de IP local
var
  Sock: TUDPBlockSocket;
  lista: TStringList;
  i: integer;
begin
  Result := '';
  lista := TStringList.Create;
  Sock := TUDPBlockSocket.Create;
  try
    sock.ResolveNameToIP(sock.LocalName, lista);
  finally
    Sock.Free;
  end;

  for i := 0 to lista.Count -1 do begin
    if i < lista.count -1 then Result := Result + ',';
    Result := Result + Trim(lista.Strings[i]);
  end;
end;

end.

