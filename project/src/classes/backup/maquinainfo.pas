unit MaquinaInfo;

{$mode ObjFPC}{$H+}

interface

uses
  {$IFDEF UNIX} cnetdb, sockets, baseunix {$ELSE} Winsock {$ENDIF}, Classes, SysUtils;

type
  TMaquinaInfo = class
    public
      class function GetLocalIP: string;
  end;

implementation

end.

