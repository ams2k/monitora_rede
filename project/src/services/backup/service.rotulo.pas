unit Service.Rotulo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, ZDataset;

type

  { TServiceRotulo }

  TServiceRotulo = class
    private
      sMsg, sErr: String;
    public
      IdRotulo: Integer; //int Primary Key
      IdRede: Integer;   // int
      Titulo: String;    //50 / varchar
      Posx: Integer;     // int
      Posy: Integer;     // int
      FontColor: String; //10 / varchar
      BackColor: String; //10 / varchar
      Bold: Boolean;     // int
      Underline: Boolean;// int
      Border: Boolean;   // int
      Pulse: Boolean;    //int

      constructor Create;
      destructor Destroy; override;
      procedure Salvar(id: Integer);
      procedure Ler(id: Integer);
      procedure Deletar(id: Integer);
      function qryRotulos(idrede1:Integer):TZQuery;
      procedure SalvarPosicao(id: Integer; x: Integer; y: Integer);
    published
      property Memssagem: String read sMsg;
      property MensagemErro: String read sErr;
  end;

implementation

uses
  DM.Servidor;

constructor TServiceRotulo.Create;
begin
  sMsg := '';
  sErr := '';
end;

destructor TServiceRotulo.Destroy;
begin
  inherited Destroy;
end;

procedure TServiceRotulo.Salvar(id: Integer);
//alva as informações do rótulo
var
  iBold: Integer = 0;
  iUnderline: Integer = 0;
  iBorder: Integer = 0;
  iPulse: Integer = 0;
begin
  if Bold then iBold := 1;
  if Underline then iUnderline := 1;
  if Border then iBorder := 1;
  if Pulse then iPulse   := 1;

  with DMConexao.NewQuery() do begin
    try
      if id < 1 then begin
        SQL.Add('insert into rotulos ');
        SQL.Add('(idrede, titulo, posx, posy, fontcolor, backcolor, bold, underline, border, pulse) ');
        SQL.Add('values(:idrede,:titulo,:posx,:posy,:fontcolor,:backcolor,:bold,:underline, :border, :pulse);');
      end else begin
        SQL.Add('update rotulos set ');
        SQL.Add('idrede=:idrede, titulo=:titulo, posx=:posx, posy=:posy, fontcolor=:fontcolor, ');
        SQL.Add('backcolor=:backcolor, bold=:bold, underline=:underline, border=:border, pulse=:pulse ');
        SQL.Add('where idrotulo=' +  IntToStr(id));
      end;

      ParamByName('idrede').AsInteger    := IdRede;
      ParamByName('titulo').AsString     := Titulo;
      ParamByName('posx').AsInteger      := Posx;
      ParamByName('posy').AsInteger      := Posy;
      ParamByName('fontcolor').AsString  := FontColor;
      ParamByName('backcolor').AsString  := BackColor;
      ParamByName('bold').AsInteger      := iBold;
      ParamByName('underline').AsInteger := iUnderline;
      ParamByName('border').AsInteger    := iBorder;
      ParamByName('pulse').AsInteger     := iPulse;
      ExecSQL;

      if id < 1 then begin
        IdRotulo := DMConexao.LastInsertedID;
        sMsg := 'Novo Rótulo criado com sucesso.'
      end else
        sMsg := 'Rótulo atualizado com sucesso.';
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceRotulo.Ler(id: Integer);
//obtém dados do rótulo indicado
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select * from rotulos where idrotulo=' + IntToStr(id));
      Open;

      if RecordCount > 0 then begin
         IdRotulo := id;
         IdRede   := FieldByName('idrede').AsInteger;
         Titulo   := FieldByName('titulo').AsString;
         Posx     := FieldByName('posx').AsInteger;
         Posy     := FieldByName('posy').AsInteger;
         FontColor:= FieldByName('fontcolor').AsString;
         BackColor:= FieldByName('backcolor').AsString;
         Bold     := (FieldByName('bold').AsInteger = 1);
         Underline:= (FieldByName('underline').AsInteger = 1);
         Border   := (FieldByName('border').AsInteger = 1);
         Pulse    := (FieldByName('pulse').AsInteger = 1);
      end else
        sErr := 'Rótulo não encontrado.';

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceRotulo.Deletar(id: Integer);
//Deleta o rótulo
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('delete from rotulos where idrotulo=' + IntToStr(id));
      ExecSQL;

      sMsg := 'Rótulo deletado com sucesso.';
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

function TServiceRotulo.qryRotulos(idrede1: Integer): TZQuery;
//Retorna um dataset
begin
  Result := DMConexao.NewQuery();

  with Result do begin
    try
      SQL.Add('select * from rotulos where idrede=:idrede ');
      SQL.Add('order by idrotulo asc');
      ParamByName('idrede').AsInteger := idrede1;
      Open;

      //Fechar somente lá no cliente/destino
      //Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceRotulo.SalvarPosicao(id: Integer; x: Integer; y: Integer);
//salva a posição (x, y) do rótulo na tela
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('update rotulos set posx=:posx, posy=:posy where idrotulo=:idrotulo');
      ParamByName('posx').AsInteger     := x;
      ParamByName('posy').AsInteger     := y;
      ParamByName('idrotulo').AsInteger := id;
      ExecSQL;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

end.

