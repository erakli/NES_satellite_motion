unit uSputnik;

interface

uses
  System.Classes, uConstants;

type
  TSputnik = class(TObject)
  private
  public
    state: param;
    mass, Sb_coeff, // �������������� �����������
    _space { s - ������� ������������/����������� ������� }
      : double;

    constructor Create;
    destructor Destroy; override;
  end;

var
  Sputnik: TSputnik;

implementation

{ TSputnik }

constructor TSputnik.Create;
begin

end;

destructor TSputnik.Destroy;
begin

  inherited;
end;

end.