unit uFunctions;

{ Служебные функции }

interface

uses uConstants;

function module(coord: coordinates): double;

implementation

function module(coord: coordinates): double;
begin

  with coord do
    result := sqrt(sqr(x) + sqr(y) + sqr(z));

end;

end.
