unit Service.HostTipos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, DB, SQLDB, ZDataset;

type

  { TServiceHostTipos }

  TServiceHostTipos = class
    private
      FDescricao: string;
      FIdHostTipo: Integer;
      sErro: String;
      sMsg: String;
      function Existe(s: String): Integer;
      function PodeExcluir(AId: Integer): Boolean;
    public
      constructor Create;
      property GetMenssagem: String read sMsg;
      property GetErro: String read sErro;
      property IdHostTipo: Integer read FIdHostTipo;
      property Descricao: string read FDescricao write FDescricao;
      function Salvar(AId: Integer): Boolean;
      function Excluir(AId: Integer): Boolean;
      function Ler(AId: Integer): Boolean;
      function DataSetHostTipos(APesquisa: String): TDataSource;
      procedure EncheCombo(var combo: TComboBox; id: Integer);
  end;

implementation

uses
  DM.Servidor, ComboBoxItemData;

{ TServiceHostTipos }

constructor TServiceHostTipos.Create;
begin
  sMsg := '';
  sErro := '';
end;

function TServiceHostTipos.Salvar(AId: Integer): Boolean;
//cadastra ou altera um tipo de host
var
  q: TZQuery;
  idh: Integer;
begin
  Result := False;
  sErro  := '';
  sMsg   := '';
  idh    := Existe(FDescricao);

  if (idh > 0) and (idh <> AId) then
  begin
    sErro := 'Já existe tipo de host com este nome!';
    Exit;
  end;

  q := DMConexao.NewQuery();

  try
    if AId < 1 then
    begin
      q.SQL.Add('insert into hosttipos ');
      q.SQL.Add('(descricao) ');
      q.SQL.Add('values(:descricao); ');
    end
    else
    begin
      q.SQL.Add('update hosttipos set ');
      q.SQL.Add('descricao = :descricao ');
      q.SQL.Add('where idhosttipo = ' + IntToStr(AId) );
    end;

    q.ParamByName('descricao').AsString := FDescricao;

    q.ExecSQL;

    if AId < 1 then
    begin
      FIdHostTipo := DMConexao.LastInsertedID;
      sMsg        := 'Novo Tipo de Host criado com sucesso.';
      Result      := True;
    end
    else
      sMsg := 'Tipo de Host atualizado com sucesso.';

    q.Free;
  except
    on ex: Exception do
      sErro := ex.Message;
  end;
end;

function TServiceHostTipos.Excluir(AId: Integer): Boolean;
//exclui o registro indicado
begin
  sMsg   := '';
  sErro  := '';
  Result := False;

  if not PodeExcluir(AId) then
  begin
    sErro := 'Não pode ser excluído por estar em uso!';
    Exit;
  end;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('delete from hosttipos where idhosttipo=' + IntToStr(AId));
      ExecSQL;

      sMsg := 'Tipo de Host deletado com sucesso.';

      Result := True;
    except
      on ex: Exception do
        sErro := ex.Message;
    end;
  end;
end;

function TServiceHostTipos.Existe(s: String): Integer;
//verifica se o tipo de host já existe
begin
  sMsg   := '';
  sErro  := '';
  Result := 0;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idhosttipo from hosttipos where descricao = :descricao');
      ParamByName('descricao').AsString := s;
      Open;

      if RecordCount > 0 then
        Result := FieldByName('idhosttipo').AsInteger;

      Close;
    except
      on ex: Exception do
        sErro := ex.Message;
    end;
  end;
end;

function TServiceHostTipos.Ler(AId: Integer): Boolean;
//pega dados do tipo de host indicado pelo seu ID
begin
  Result := False;
  sMsg   := '';
  sErro  := '';

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select descricao from hosttipos where idhosttipo=' + IntToStr(AId));
      Open;

      if RecordCount > 0 then begin
        FDescricao  := FieldByName('descricao').AsString;
        FIdHostTipo := AId;
        Result      := True;
      end else
        sErro := 'Tipo de Host não encontrado.';

      Close;
    except
      on ex: Exception do
        sErro := ex.Message;
    end;
  end;
end;

function TServiceHostTipos.DataSetHostTipos(APesquisa: String): TDataSource;
// Retorna um  datasource
var
  q : TZQuery;
begin
  Result  := TDataSource.Create(nil);
  q := DMConexao.NewQuery();

  try
    q.SQL.Add('select idhosttipo, descricao ');
    q.SQL.Add('from hosttipos ');

    if APesquisa.Trim <> '' then
    begin
      q.SQL.Add('where descricao like :descricao ');
      q.ParamByName('descricao').AsString := '%' + APesquisa + '%';
    end;

    q.SQL.Add('order by descricao asc ');

    q.Open;
    Result.DataSet := q;
    // fechar lá no destino/cliente
    //q.Close;
  except
   on ex: Exception do
     sErro := ex.Message;
  end;
end;

procedure TServiceHostTipos.EncheCombo(var combo: TComboBox; id: Integer);
//Enche a combobox os nomes das redes existentes
begin
  combo.Items.Clear;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idhosttipo, descricao from hosttipos order by descricao asc');
      Open;

      if RecordCount > 0 then
         while not EOF do begin
            combo.items.AddObject( FieldByName('descricao').AsString,
                                   TComboBoxItemData.Create( FieldByName('idhosttipo').AsInteger ) );
            Next;
         end;

      Close;
    except
      on ex: Exception do
        sErro := ex.Message;
    end;
  end;

  if combo.Items.Count > 0 then
    combo.ItemIndex := 0;
end;

function TServiceHostTipos.PodeExcluir(AId: Integer): Boolean;
//verifica se pode exclui o registro indicado
begin
  sMsg   := '';
  sErro  := '';
  Result := False;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select count(*) as qde from hosts where idhosttipo = ' + IntToStr(AId));
      Open;

      if not EOF then
        Result := (FieldByName('qde').AsInteger = 0);

      Close;
    except
      on ex: Exception do
        sErro := ex.Message;
    end;
  end;
end;

end.

