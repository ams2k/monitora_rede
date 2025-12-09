program monitora;

{$mode objfpc}{$H+}

{
  No Linux o ping pode não funcionar por falta de privilégios.
  Execute seu programa como root: sudo ./seu_programa

  OU você pode dar permissão ao binário para enviar ICMP:
  sudo setcap cap_net_raw+ep ./seu_programa
}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, DM.Servidor, View.Main;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title := 'Monitoração de Rede Privada';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TDMBancoDados, DMConexao);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmHostTipo, frmHostTipo);
  Application.Run;
end.

