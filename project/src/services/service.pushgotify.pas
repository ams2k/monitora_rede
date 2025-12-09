unit Service.PushGotify;

// Acesso ao serviço de notificação do Gotify

// https://wiki.lazarus.freepascal.org/fphttpclient#Posting_JSON

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser,
  fphttpclient, ssockets, openssl, opensslsockets;

type
  { TServicoPushGotify }

  TServicoPushGotify = class
    public
      function Notificar(ATitulo, AMsg, AHost, AToken: String): Boolean;
  end;

implementation

{ TServicoPushGotify }

function TServicoPushGotify.Notificar(ATitulo, AMsg, AHost, AToken: String): Boolean;
// Envia notificação para os gotify disparar para o usuário
var
  httpClient: TFPHTTPClient;
  StreamResposta: TStringStream;
  jsonResposta: TJSONData;
  jsonDados: TJSONObject;
  appid: integer;
  sUrl: String;
begin
  Result := False;
  //sUrl := gfy.Host + Format('/message?token=%s&title=%s&message=%s&priority=5',[gfy.Chave, ATitulo, AMsg]);
  sUrl := AHost + '/message';

  jsonDados := TJSONObject.Create;
  jsonDados.Add('title', ATitulo);
  jsonDados.Add('message', AMsg);
  jsonDados.Add('priority', 5);

  httpClient := TFPHTTPClient.Create(nil);

  // Retorno 200 OK
  // {id: integer, appid: integer, message: string, title: string, priority: integer, date: string}
  // Retorno Erro
  // {error: string, errorCode: interger, errorDescription: string}

  try
    try
      // Adicionar cabeçalho user-agent para evitar bloqueio de requisições
      httpClient.AllowRedirect := True;
      httpClient.AddHeader('User-Agent', 'Mozilla/5.0');
      httpClient.AddHeader('Content-Type', 'application/json; charset=UTF-8');
      httpClient.AddHeader('Accept', 'application/json');
      httpClient.AddHeader('X-Gotify-Key', AToken);
      //httpClient.AddHeader('Authorization', 'Bearer ' + gfy.Chave);
      //httpClient.UserName := gfy.Usuario;
      //httpClient.Password := gfy.Senha;

      StreamResposta := TStringStream.Create(''); // receberá a resposta
      httpClient.RequestBody := TRawByteStringStream.Create( jsonDados.AsJSON ); // json no body

      httpClient.Post(sUrl, StreamResposta); // post dos dados para o host
      Result := (httpClient.ResponseStatusCode = 200); // código de resposta

      // conversão da resposta (stream) em json
      jsonResposta := GetJSON( StreamResposta.DataString ); // objeto json data
      appid  := TJSONObject( jsonResposta ).Get('appid', 0); // se deu tudo certo...
      Result := (appid > 0); // criou a mensagem no gotify
    except
      on E: ESocketError do begin
        //
      end;
    end;
  finally
    httpClient.RequestBody.Free;
    httpClient.Free;
    StreamResposta.Free;
    jsonDados.Free;
  end;
end;

end.

