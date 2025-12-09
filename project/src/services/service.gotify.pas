unit Service.Gotify;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, ZDataset, DM.Servidor;

type

  { TServiceGotify }

  TServiceGotify = class

  private
    FAppNome: String;
    FChave: String;
    FHost: String;
    FMsgErro: String;
    FUsuario: String;
    public
      property Host: String read FHost write FHost;
      property AppNome: String read FAppNome write FAppNome;
      property Chave: String read FChave write FChave;
      property Usuario: String read FUsuario write FUsuario;
      property GetErroMsg: String read FMsgErro;
      function Salvar(): Boolean;
      function Ler(): Boolean;
      function Deletar(): Boolean;
  end;

implementation

{ TServiceGotify }

function TServiceGotify.Salvar(): Boolean;
// salva os dados
var
  q: TZQuery;
begin
  Deletar();
  FMsgErro := '';
  Result   := False;

  q := DMConexao.NewQuery();
  q.SQL.Add('insert into gotify ');
  q.SQL.Add('(host, app, chave, usuario)  ');
  q.SQL.Add('values ');
  q.SQL.Add('(:host, :app, :chave, :usuario); ');

  //parâmetros
  q.ParamByName('host').AsString    := FHost;
  q.ParamByName('app').AsString     := FAppNome;
  q.ParamByName('chave').AsString   := FChave;
  q.ParamByName('usuario').AsString := FUsuario;

  try
     q.ExecSQL;
     Result := True;
  except
    on e: Exception do
     FMsgErro := e.Message;
  end;

  if Assigned(q) then FreeAndNil(q);
end;

function TServiceGotify.Ler(): Boolean;
// ler os dados
var
  q: TZQuery;
begin
  FMsgErro := '';
  FHost    := '';
  FAppNome := '';
  FChave   := '';
  FUsuario := '';
  Result   := False;

  q := DMConexao.NewQuery();
  q.SQL.Add('select host, app, chave, usuario ');
  q.SQL.Add('from gotify ');

  try
     q.Open;

     if q.RecordCount > 0 then begin
       FHost    := q.FieldByName('host').AsString;
       FAppNome := q.FieldByName('app').AsString;
       FChave   := q.FieldByName('chave').AsString;
       FUsuario := q.FieldByName('usuario').AsString;
       Result   := True;
     end;

     q.Close;
  except
    on e: Exception do
     FMsgErro := e.Message;
  end;

  if Assigned(q) then FreeAndNil(q);
end;

function TServiceGotify.Deletar(): Boolean;
// deletar os dados
var
  q: TZQuery;
begin
  FMsgErro := '';
  Result   := False;

  q := DMConexao.NewQuery();
  q.SQL.Add('delete from gotify');

  try
     q.ExecSQL;
  except
    on e: Exception do
     FMsgErro := e.Message;
  end;

  if Assigned(q) then FreeAndNil(q);
end;

end.

