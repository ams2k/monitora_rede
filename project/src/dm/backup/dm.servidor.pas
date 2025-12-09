unit DM.Servidor;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, Dialogs;

type
  { TDMBancoDados }

  TDMBancoDados = class(TDataModule)
    DBServer: TZConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FMsgErro: string;
    FPathDLL, FPathBanco : String;
    FCriarTabelas: Boolean;
    procedure ChecaTabelas;
  public
    procedure Desconectar;
    procedure ChecaConexao;
    function NewQuery(): TZQuery;
    function LastIDCommand(): String;
    function LastInsertedID: Integer;
    property GetMsgErro: string read FMsgErro;
  end;

var
  DMConexao: TDMBancoDados;

implementation

{$R *.lfm}

{ TDMBancoDados }

{ será criado automaticamente pelo compilador }
procedure TDMBancoDados.DataModuleCreate(Sender: TObject);
begin
  FMsgErro      := '';
  FPathBanco    := ExtractFileDir( ParamStr(0) ) + PathDelim + 'monitora.db';
  FPathDLL      := ExtractFileDir( ParamStr(0) ) + PathDelim + 'sqlite3.dll';
  FCriarTabelas := not FileExists( FPathBanco );

  try
    with DBServer do begin
      Protocol   := 'sqlite';
      AutoCommit := True;
      Database   := FPathBanco;

      {$IFDEF WINDOWS}
      LibraryLocation := FPathDLL;
      {$ENDIF}

      Connect;
    end;

    ChecaTabelas;
  Except
    on E: Exception do begin
      FMsgErro := E.Message;
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TDMBancoDados.DataModuleDestroy(Sender: TObject);
begin
  FMsgErro := '';

  try
    if DBServer.Connected then
       DBServer.Disconnect;
  except
    on e: Exception do
      FMsgErro := e.Message;
  end;
end;

procedure TDMBancoDados.ChecaTabelas;
// Cria as tabelas se não existir
begin
  if not FCriarTabelas then Exit;

  ChecaConexao;

  try
    DBServer.ExecuteDirect('CREATE TABLE IF NOT EXISTS hosts ('+
     'idhost INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
     'titulo VARCHAR(50),'+
     'posx INTEGER NOT NULL DEFAULT (0),'+
     'posy INTEGER NOT NULL DEFAULT (0),'+
     'ip VARCHAR(20),'+
     'idparent INTEGER NOT NULL DEFAULT (0),'+
     'info TEXT,'+
     'idhosttipo INTEGER NOT NULL DEFAULT (0),'+
     'aceitaligacao INTEGER NOT NULL DEFAULT (0),'+
     'idrede INTEGER NOT NULL DEFAULT (0)'+
     ');');

    DBServer.ExecuteDirect('CREATE TABLE IF NOT EXISTS hosttipos ('+
     'idhosttipo INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
     'descricao VARCHAR(50) '+
     ');');

    DBServer.ExecuteDirect('CREATE TABLE IF NOT EXISTS rotulos ('+
     'idrotulo INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
     'idrede INTEGER NOT NULL DEFAULT (0),'+
     'titulo VARCHAR(50),'+
     'posx INTEGER NOT NULL DEFAULT (0),'+
     'posy INTEGER NOT NULL DEFAULT (0),'+
     'fontcolor VARCHAR(10) NOT NULL,'+
     'backcolor VARCHAR(10) NOT NULL,'+
     'bold INTEGER NOT NULL DEFAULT (0),'+
     'underline INTEGER NOT NULL DEFAULT (0),'+
     'border INTEGER NOT NULL DEFAULT (0),'+
     'pulse INTEGER NOT NULL DEFAULT (0)'+
     ');');

    DBServer.ExecuteDirect('CREATE TABLE IF NOT EXISTS redes ('+
     'idrede INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
     'descricao VARCHAR(50)'+
     ');');

    DBServer.ExecuteDirect('CREATE TABLE IF NOT EXISTS avisos ('+
     'idaviso INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
     'idrede INTEGER NOT NULL DEFAULT (0),'+
     'texto VARCHAR(500),'+
     'posx INTEGER NOT NULL DEFAULT (0),'+
     'posy INTEGER NOT NULL DEFAULT (0)'+
     ');');

    DBServer.ExecuteDirect('CREATE TABLE IF NOT EXISTS gotify ( ' + 
                           'host varchar(100) UNIQUE, ' + 
                           'app varchar(100) UNIQUE, ' + 
                           'chave varchar(100), ' + 
                           'usuario varchar(100) ' +
                           '); ');

    // índices
    DBServer.ExecuteDirect('CREATE INDEX IF NOT EXISTS idx_hosts ON hosts (idhost, idrede); ');
    DBServer.ExecuteDirect('CREATE INDEX IF NOT EXISTS idx_hosttipos ON hosttipos (idhosttipo); ');
    DBServer.ExecuteDirect('CREATE INDEX IF NOT EXISTS idx_rotulos ON rotulos (idrotulo, idrede); ');
    DBServer.ExecuteDirect('CREATE INDEX IF NOT EXISTS idx_redes ON redes (idrede); ');
    DBServer.ExecuteDirect('CREATE INDEX IF NOT EXISTS idx_avisos ON avisos (idaviso, idrede); ');
    DBServer.ExecuteDirect('CREATE INDEX IF NOT EXISTS idx_hosttipos ON hosttipos (idhosttipo); ');

    // cadastra tipos de hosts padrão
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''INDEFINIDO'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''MIKROTIK'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''UBIQUITI'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''DSLAM'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''ROUTER'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''SWITCH'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''WEBSITE'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''DNS SERVER'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''WEB SERVER'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''DB SERVER'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''CAMERA'')');
    DBServer.ExecuteDirect('insert into hosttipos (descricao) values(''PC'')');
  except
  end;
end;

procedure TDMBancoDados.Desconectar;
// desconecta do banco de dados
begin
  FMsgErro := '';

  try
    if DBServer.Connected then
       DBServer.Disconnect;
  except
    on e: Exception do
      FMsgErro := e.Message;
  end;
end;

procedure TDMBancoDados.ChecaConexao;
// se a conexão não estiver aberta, então tenta conectar no servidor/banco
begin
   FMsgErro := '';

   try
     if not DBServer.Connected then DBServer.Connect;
   except
    on e: Exception do
      FMsgErro := e.Message;
   end;
end;

function TDMBancoDados.NewQuery(): TZQuery;
// retorna a instância de uma nova query
begin
  ChecaConexao;

  Result := TZQuery.Create(nil);

  if FMsgErro.IsEmpty then begin
    try
      Result.Connection := DBServer;
      Result.Close;
      Result.SQL.Clear;
    except
      on e: Exception do
        FMsgErro := e.Message;
    end;
  end;
end;

{ SQL para trazer o último id auto increment inserido }
function TDMBancoDados.LastIDCommand(): String;
begin
  Result := 'select last_insert_rowid() as id; ';
end;

function TDMBancoDados.LastInsertedID: Integer;
// retorna o último ID inserido, independente da tabela
begin
  Result := 0;

  with NewQuery() do begin
    try
      SQL.Add( LastIDCommand() );
      Open;

      if RecordCount > 0 then
         Result := FieldByName('id').AsInteger;

      Close;
    except
      on e: Exception do
         ShowMessage('LastInsertedID: ' + e.Message);
    end;
  end;
end;

end.

