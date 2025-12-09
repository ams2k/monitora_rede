unit Service.Aviso;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils, DB, SQLDB, ZDataset;

type

  { TServiceAviso }

  TServiceAviso = class
    private
      sMsg: String;
      sErr: String;
    public
      IDAviso: Integer;
      IDRede: Integer;
      Texto: String;
      PosX, PosY: Integer;
      constructor Create;
      destructor Destroy; override;
      procedure Salvar(id: Integer);
      procedure Ler(id: Integer);
      procedure Deletar(id: Integer);
      procedure SalvaPosicao(id, x, y: Integer);
      function qryAvisos(idRede1:Integer):TZQuery;
    published
      property Mensagem: String read sMsg write sMsg;
      property MensagemErro: String read sErr write sErr;
  end;

implementation

uses
  dm.Servidor;

{ TServiceAviso }

constructor TServiceAviso.Create;
begin
  sMsg := '';
  sErr := '';
end;

destructor TServiceAviso.Destroy;
begin
  inherited Destroy;
end;

procedure TServiceAviso.Salvar(id: Integer);
//Salva informações do aviso
begin
   with DMConexao.NewQuery() do begin
      try
        if id < 1 then begin
           SQL.Add('insert into avisos ');
           SQL.Add('(idrede,texto,posx,posy) ');
           SQL.Add('values(:idrede, :text, :posx, :posy);');
        end else begin
           SQL.Add('update avisos set ');
           SQL.Add('idrede=:idrede, texto=:texto, posx=:posx, posy=:posy ');
           SQL.Add('where idaviso=' +  IntToStr(id));
        end;

        ParamByName('idrede').AsInteger := IDRede;
        ParamByName('texto').AsString   := Texto;
        ParamByName('posx').AsInteger   := Posx;
        ParamByName('posy').AsInteger   := Posy;

        ExecSQL;

        if id < 1 then begin
          IDAviso := DMConexao.LastInsertedID;
          sMsg    := 'Novo aviso criado com sucesso.'
        end else
          sMsg := 'Aviso atualizado com sucesso.';
      except
        on ex: Exception do
          sErr := ex.Message;
      end;
   end;
end;

procedure TServiceAviso.Ler(id: Integer);
//Ler informações do aviso
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select * from avisos where idaviso=' + IntToStr(id));
      Open;

      if RecordCount > 0 then begin
        IDAviso := id;
        IdRede  := FieldByName('idrede').AsInteger;
        Texto   := FieldByName('texto').AsString;
        Posx    := FieldByName('posx').AsInteger;
        Posy    := FieldByName('posy').AsInteger;
      end else
        sErr := 'Aviso não encontrado.';

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceAviso.Deletar(id: Integer);
//Deleta o aviso
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('delete from avisos where idaviso=' + IntToStr(id));
      ExecSQL;
      sMsg := 'Aviso deletado com sucesso.';
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceAviso.SalvaPosicao(id, x, y: Integer);
//Salva a posição (x,y) do aviso na tela
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('update avisos set posx=:posx, posy=:posy where idaviso=:id');
      ParamByName('posx').AsInteger := x;
      ParamByName('posy').AsInteger := y;
      ParamByName('id').AsInteger   := id;
      ExecSQL;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

function TServiceAviso.qryAvisos(idRede1: Integer): TZQuery;
//Returna um dataset
begin
  Result := DMConexao.NewQuery();

  with Result do begin
    try
      SQL.Add('select idaviso, idrede, texto, posx, posy ');
      SQL.Add('from avisos ');
      SQL.Add('where idrede=:idrede ');
      SQL.Add('order by idaviso asc ');
      ParamByName('idrede').AsInteger := idRede1;
      Open;

      //Fechar somente lá no cliente/destino
      //Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

end.

