unit ComboBoxItemData;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TComboBoxItemData }

  TComboBoxItemData = class(TObject)
    Value: Integer;
    public
      constructor Create(AValue: Integer);
  end;

implementation

{ TComboBoxItemData }

constructor TComboBoxItemData.Create(AValue: Integer);
begin
  Value := AValue;
end;

end.

