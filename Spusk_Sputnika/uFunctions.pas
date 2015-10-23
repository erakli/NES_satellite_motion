unit uFunctions;

{ Служебные функции }

interface

uses uConstants;

function module(coord: coordinates): double; overload;
function module(coord: TVector): double; overload;

implementation

function module(coord: coordinates): double;
begin

  with coord do
    result := sqrt(sqr(x) + sqr(y) + sqr(z));

end;

function module(coord: TVector): double;
var
	i: byte;
  output: double;
begin

	output := 0;
	for i := 0 to High(coord) do
  	output := output + sqr(coord[i]);

	result := sqrt(output);

end;

end.
