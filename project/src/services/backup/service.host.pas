unit Service.Host;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, DB, SQLDB, ZDataset;

const
  INDEFINIDO = 0;
  MIKROTIK   = 1;
  UBIQUITI   = 2;
  DSLAM      = 3;

type

  { TInfoHost }

  TInfoHost = class
    public
     IDHost: Integer;
     Nome: String;
     constructor Create;
     destructor Destroy;override;
  end;

  { TServiceHost }

  TServiceHost = class
    private
      sMsg, sErr: String;
    public
      IdHost: Integer;     // int Primary Key
      IDHostTipo: Integer; // int
      Titulo: String;      // 50 / varchar
      Posx: Integer;       // int
      Posy: Integer;       // int
      Ip: String;          // 20 / varchar
      IdParent: Integer;   // int
      Info: String;        // text
      AceitaLigacao: Boolean; // int
      IDRede: Integer;     // int

      constructor Create;
      destructor Destroy; override;
      procedure Salvar(id: Integer);
      procedure Ler(id: Integer);
      procedure Deletar(id: Integer);
      procedure RemoveHostPai(idpar: Integer);
      procedure DefineHostPai(idpar: Integer);
      function qryHosts(sSearch: String; idrede1:Integer):TZQuery;
      function qryListaHosts(idrede1: Integer):TZQuery;
      procedure ComboHosts(var combo:TComboBox; idr: Integer);
      procedure SalvaHostPosicao(id: Integer; x: Integer; y: Integer);
      function IPEmUso(sip: String; idrede1: Integer): TInfoHost;
      function ExisteHost(sTitulo: String; idrede1: Integer): Integer;
      procedure ComboHostTipos(var combo: TComboBox);
      function HostTipoNome(id: Integer): String;
      function GetHostIP(id: Integer): String;
    published
      property Mensagem: String read sMsg;
      property MensagemErro: String read sErr;
  end;

implementation

uses
  DM.Servidor, ComboBoxItemData;

{ TInfoHost }

constructor TInfoHost.Create;
begin
  IDHost := 0;
  Nome   := '';
end;

destructor TInfoHost.Destroy;
begin
  inherited Destroy;
end;

{ TServiceHost }

constructor TServiceHost.Create;
begin
  sMsg := '';
  sErr := '';
end;

destructor TServiceHost.Destroy;
begin
  inherited Destroy;
end;

procedure TServiceHost.Salvar(id: Integer);
//Salva as informações no host
var
  inf: TInfoHost;
  idh: Integer;
  aceita: Integer;
begin
  inf := IPEmUso(Ip, IDRede);

  if (inf.IDHost > 0) and (inf.IDHost <> id) then begin
     sErr := 'Endereço IP já em uso pelo Host ' + #13 + #13 + inf.Nome;
     inf.Free;
     Exit;
  end;

  inf.Free;

  idh := ExisteHost(Titulo, IDRede);

  if (idh > 0) and (idh <> id) then begin
     sErr := 'Este nome de Host já existe';
     exit;
  end;

  if AceitaLigacao then aceita := 1 else aceita := 0;

  with DMConexao.NewQuery() do begin
    try
      if id < 1 then begin
         SQL.Add('insert into hosts ');
         SQL.Add('(titulo, posx, posy, ip, idparent, info, idhosttipo, aceitaligacao, idrede) ');
         SQL.Add('values(:titulo, :posx, :posy, :ip, :idparent, :info, :idhosttipo, :aceitaligacao, :idrede);');
      end else begin
         SQL.Add('update hosts set ');
         SQL.Add('titulo=:titulo, posx=:posx, posy=:posy, ip=:ip, ');
         SQL.Add('idparent=:idparent, info=:info,');
         SQL.Add('idhosttipo=:idhosttipo, aceitaligacao=:aceitaligacao, idrede=:idrede ');
         SQL.Add('where idhost=' +  IntToStr(id));
      end;

      ParamByName('titulo').AsString         := Titulo;
      ParamByName('posx').AsInteger          := Posx;
      ParamByName('posy').AsInteger          := Posy;
      ParamByName('ip').AsString             := Ip;
      ParamByName('idparent').AsInteger      := IdParent;
      ParamByName('info').AsString           := Info;
      ParamByName('idhosttipo').AsInteger    := IDHostTipo;
      ParamByName('aceitaligacao').AsInteger := aceita;
      ParamByName('idrede').AsInteger        := IDRede;

      ExecSQL;

      if id < 1 then begin
        IdHost := DMConexao.LastInsertedID;
        sMsg   := 'Novo Host criado com sucesso.'
      end else
        sMsg := 'Host atualizado com sucesso.';
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceHost.Ler(id: Integer);
//obtém dados no Host
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select * from hosts where idrede=' + IntToStr(id));
      Open;

      if RecordCount > 0 then begin
         IdHost        := id;
         Titulo        := FieldByName('titulo').AsString;
         Posx          := FieldByName('posx').AsInteger;
         Posy          := FieldByName('posy').AsInteger;
         Ip            := FieldByName('ip').AsString;
         IdParent      := FieldByName('idparent').AsInteger;
         Info          := FieldByName('info').AsString;
         IDHostTipo    := FieldByName('idhosttipo').AsInteger;
         AceitaLigacao := (FieldByName('aceitaligacao').AsInteger = 1);
         IDRede        := FieldByName('idrede').AsInteger;
      end else
        sErr := 'Host não encontrado.';

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceHost.Deletar(id: Integer);
//Deleta o host
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('delete from hosts where idhost=' + IntToStr(id));
      ExecSQL;

      sMsg := 'Host deletado com sucesso.';

      RemoveHostPai(id); //desvincula do host Pai
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceHost.RemoveHostPai(idpar: Integer);
//remove ligação com o host pai
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('update hosts set idparent=0 where idparent=' + IntToStr(idpar));
      ExecSQL;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceHost.DefineHostPai(idpar: Integer);
//Define o host pai a todos os outros hosts
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('update hosts set idparent=:idpar where idhost<>' + IntToStr(idpar));
      ParamByName('idpar').AsInteger := idpar;
      ExecSQL;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

function TServiceHost.qryHosts(sSearch: String; idrede1: Integer): TZQuery;
//Retorna um dataset
begin
  Result := DMConexao.NewQuery();

  with Result do begin
    try
      SQL.Add('select w.idhost, w.titulo, w.ip, ');
      SQL.Add('(select distinct h.titulo from hosts h where h.idhost=w.idparent) as parent ');
      SQL.Add('from hosts w ');
      SQL.Add('where w.idrede=:idrede ');

      if sSearch.Trim <> '' then SQL.Add('and w.titulo like :sSearch ');

      SQL.Add('order by w.titulo asc ');

      ParamByName('idrede').AsInteger := idrede1;
      ParamByName('sSearch').AsString := sSearch;

      Open;

      //Fechar somente lá no cliente/destino
      //Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

function TServiceHost.qryListaHosts(idrede1: Integer): TZQuery;
//Retorna um dataset, lista de hosts
begin
  Result := DMConexao.NewQuery();

  with Result do begin
    try
      SQL.Add('select w.idhost, w.titulo, w.ip, w.posx, w.posy, w.idparent,');
      SQL.Add('(select distinct h.titulo from hosts h where h.idhost=w.idparent) as parent, ');
      SQL.Add('(select distinct h.ip from hosts h where h.idhost=w.idparent) as ipparent, ');
      SQL.Add('w.idhosttipo, w.aceitaligacao ');
      SQL.Add('from hosts w ');
      SQL.Add('where w.idrede=' + IntToStr(idrede1) + ' ');
      SQL.Add('order by w.idparent desc'); //exibe os pais primeiro

      Open;

      //Fechar somente lá no cliente/destino
      //Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceHost.ComboHosts(var combo: TComboBox; idr: Integer);
//enche a combo com os hosts
begin
  combo.Items.Clear;
  combo.Items.AddObject(' ', TComboBoxItemData.Create(0));

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idhost, titulo, ip from hosts where idrede=:idrede order by titulo asc');
      ParamByName('idrede').AsInteger := idr;
      Open;

      if RecordCount > 0 then begin
         while not EOF do begin
            combo.Items.AddObject( FieldByName('titulo').AsString,
                                   TComboBoxItemData.Create(FieldByName('idhost').AsInteger));
            Next;
         end;
      end;

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;

  combo.ItemIndex := 0;
end;

procedure TServiceHost.SalvaHostPosicao(id: Integer; x: Integer; y: Integer);
//salva a posição (x, y) do host na tela
begin
  with DMConexao.NewQuery() do begin
    try
      SQL.Add('update hosts set posx=:posx, posy=:posy where idhost=:idhost ');
      ParamByName('posx').AsInteger   := x;
      ParamByName('posy').AsInteger   := y;
      ParamByName('idhost').AsInteger := id;
      ExecSQL;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

function TServiceHost.IPEmUso(sip: String; idrede1: Integer): TInfoHost;
//checa se o IP está em uso por algum host
begin
  Result := TInfoHost.Create();

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idhost, titulo from hosts where ip=:sip and idrede=:idrede');
      ParamByName('sip').AsString     := sip;
      ParamByName('idrede').AsInteger := idrede1;
      Open;

      if RecordCount > 0 then begin
         Result.IDHost := FieldByName('idhost').AsInteger;
         Result.Nome   := FieldByName('titulo').AsString;
      end;

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

function TServiceHost.ExisteHost(sTitulo: String; idrede1: Integer): Integer;
//Checa se o nome no host já existe
begin
  Result := 0;

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select coalesce(idhost, 0) as idhost from hosts where titulo=:titulo and idrede=:idrede ');
      ParamByName('titulo').AsString  := sTitulo;
      ParamByName('idrede').AsInteger := idrede1;
      Open;

      if RecordCount > 0 then
         Result := FieldByName('idhost').AsInteger;

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

procedure TServiceHost.ComboHostTipos(var combo: TComboBox);
//enche a combo com os tipos de host
begin
  combo.Items.Clear;
  combo.Items.AddObject(' ', TComboBoxItemData.Create(0));

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select idhosttipo, descricao from hosttipos order by descricao asc');
      Open;

      if RecordCount > 0 then begin
        while not EOF do begin
           combo.Items.AddObject( FieldByName('descricao').AsString,
                                  TComboBoxItemData.Create(FieldByName('idhosttipo').AsInteger));
           Next;
        end;
      end;

      Close;
    except
    end;
  end;

  combo.ItemIndex := 0;
end;

function TServiceHost.HostTipoNome(id: Integer): String;
//retorna o nome do tipo de host
begin
  Result := '';

  with DMConexao.NewQuery() do begin
    SQL.Add('select descricao from hosttipos where idhosttipo=' + IntToStr(id));
    Open;

    if RecordCount = 1 then
       Result := FieldByName('descricao').AsString;

    Close;
  end;
end;

function TServiceHost.GetHostIP(id: Integer): String;
//retorna o IP do host
begin
  Result := '';

  with DMConexao.NewQuery() do begin
    try
      SQL.Add('select ip from hosts where idhost=:id');
      ParamByName('id').AsInteger := id;
      Open;

      if RecordCount > 0 then
         Result := FieldByName('ip').AsString;

      Close;
    except
      on ex: Exception do
        sErr := ex.Message;
    end;
  end;
end;

end.

