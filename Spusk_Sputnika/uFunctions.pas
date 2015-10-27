unit uFunctions;

{ Служебные функции }

interface

uses uConstants;

function module(coord: coordinates): double; overload;
function module(coord: TVector): double; overload;

{ Функции преобразования к радианам из минут дуги }
function deg2rad(arg: double): double;
function amin2rad(arg: double): double;
function asec2rad(arg: double): double;

function pow2(arg: double): double;
function pow3(arg: double): double;
function pow4(arg: double): double;
function pow5(arg: double): double;

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

{ Функции преобразования к радианам из минут дуги }
function deg2rad(arg: double): double;
begin
	result := arg * Pi / 180;
end;

function amin2rad(arg: double): double;
begin
	result := arg * Pi / (180 * 60);
end;

function asec2rad(arg: double): double;
begin
	result := arg * Pi / (180 * 60 * 60);
end;


function pow2(arg: double): double;
begin
	result := arg * arg;
end;

function pow3(arg: double): double;
begin
	result := arg * arg * arg;
end;

function pow4(arg: double): double;
begin
	result := arg * arg * arg * arg;
end;

function pow5(arg: double): double;
begin
	result := arg * arg * arg * arg * arg;
end;

end.
