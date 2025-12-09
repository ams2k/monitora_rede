unit Service.Rede;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils, DB, SQLDB, StdCtrls, ZDataset;

type

  { TServiceRede }

  TServiceRede = class

    private
      sMsg: String;
      sErr: String;
      function Existe(s: String): Integer;
      procedure DeletaObjetos(s: String);
    public
      IDRede: Integer;
      Descricao: String;
      constructor Create;
      procedure Salvar(id: Integer);
      procedure Deletar(id: Integer);
      procedure Ler(id: Integer);
      procedure EncheCombo(var combo: TComboBox);
      function qryRedes(): TZQuery;
      function dsGridRedes(APesquisa: String): TDataSource;
    published
      property Menssagem: String read sMsg;
      property MensagemErro: String read sErr;
  end;

implementation

uses
  DM.Servidor, ComboBoxItemData;

{ TServiceRede }

function TServiceRede.Existe(s: String): Integer;
//verifica se o nome da Rede já existe
begin
  Result := 0;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idrede from redes where descricao=:descricao');
      ParamByName('descricao').AsString := s;
      Open;

      if RecordCount > 0 then Result := FieldByName('idrede').AsInteger;

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceRede.DeletaObjetos(s: String);
//deleta objetos ligados a esta rede
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add(s);
      ExecSQL;
    except
    end;
  end;
end;

constructor TServiceRede.Create;
begin
  sErr := '';
  sMsg := '';
end;

procedure TServiceRede.Salvar(id: Integer);
//salva dados da rede
var
  idh: Integer;
begin
  idh := Existe(Descricao);

  if (idh > 0) and (idh <> id) then begin
     sErr := 'Já existe uma Rede com este nome!';
     exit;
  end;

  with DMConexao.NewQuery() do begin
    try
      if id < 1 then begin
        SQL.Add('insert into redes (descricao) values(:descricao); ');
      end else begin
        SQL.Add('update redes set descricao=:descricao ');
        SQL.Add('where idrede=' + IntToStr(id));
      end;

      ParamByName('descricao').AsString := Descricao;

      ExecSQL;

      if id < 1 then begin
        IDRede := DMConexao.LastInsertedID;
        sMsg   := 'Nova Rede criada com sucesso.'
      end else
        sMsg := 'Rede atualizada com sucesso.';
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceRede.Deletar(id: Integer);
//deleta a rede e todos os objetos relacionados
begin
  DeletaObjetos('delete from redes where idrede=' + IntToStr(id));
  DeletaObjetos('delete from hosts where idrede=' + IntToStr(id));
  DeletaObjetos('delete from rotulos where idrede=' + IntToStr(id));
  DeletaObjetos('delete from avisos where idrede=' + IntToStr(id));
end;

procedure TServiceRede.Ler(id: Integer);
//ler dados da rede
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select * from redes where idrede=' + IntToStr(id));
      Open;

      if RecordCount > 0 then begin
         Descricao := FieldByName('descricao').AsString;
         IDRede    := id;
      end else
        sErr := 'Rede não encontrada.';

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceRede.EncheCombo(var combo: TComboBox);
//Enche a combobox os nomes das redes existentes
begin
  combo.Items.Clear;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idrede, descricao from redes order by descricao asc');
      Open;

      if RecordCount > 0 then
         while not EOF do begin
            combo.items.AddObject( FieldByName('descricao').AsString,
                                   TComboBoxItemData.Create( FieldByName('idrede').AsInteger ) );
            Next;
         end;

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;

  if combo.Items.Count > 0 then
    combo.ItemIndex := 0;
end;

function TServiceRede.qryRedes: TZQuery;
//retorna uma query com as redes existentes
begin
  Result := DMConexao.NewQuery();

  try
    with Result do begin
      SQL.Add('select idrede, descricao from redes order by descricao asc');
      Open;
      //Fechar somente lá no cliente/destino
      //Close;
    end;
  except
    on ex: Exception do
      sErr := ex.Message;
  end;
end;

function TServiceRede.dsGridRedes(APesquisa: String): TDataSource;
// Retorna um  datasource
var
  qry : TZQuery;
begin
  Result  := TDataSource.Create(nil);
  qry := DMConexao.NewQuery();

  try
    qry.SQL.Add('select idrede, descricao ');
    qry.SQL.Add('from redes ');

    if APesquisa.Trim <> '' then
      qry.SQL.Add('where descricao like :descricao ');

    qry.SQL.Add('order by descricao asc ');

    if APesquisa.Trim <> '' then
      qry.ParamByName('descricao').AsString := '%' + APesquisa + '%';

    qry.Open;
    Result.DataSet := qry;
    // fechar lá no destino/cliente
    //qry.Close;
  except
   on ex: Exception do
     sErr := ex.Message;
  end;
end;

end.

