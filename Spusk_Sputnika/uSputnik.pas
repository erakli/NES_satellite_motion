unit uSputnik;

interface

uses
  System.Classes, uTypes, uConstants;

type
  TSputnik = class(TObject)
  private
  public
    state: param;
    mass, Sb_coeff, // баллистический коэффициент
    _space { s - площадь эффективного/поперечного сечения }
      : MType;

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
