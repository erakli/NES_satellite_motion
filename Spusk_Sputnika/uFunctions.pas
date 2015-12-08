unit uFunctions;

{ Служебные функции }

interface

uses uTypes, uConstants;

function module(coord: TVector): MType; overload;

{ Функции преобразования к радианам из минут дуги }
function deg2rad(arg: MType): MType;
function amin2rad(arg: MType): MType;
function asec2rad(arg: MType): MType;

function AngleNormalize(angle: MType): MType;

function pow2(arg: MType): MType;
function pow3(arg: MType): MType;
function pow4(arg: MType): MType;
function pow5(arg: MType): MType;

implementation

function module(coord: TVector): MType;
var
  i: byte;
  output: MType;
begin

  output := 0;
  for i := 0 to High(coord) do
    output := output + sqr(coord[i]);

  result := sqrt(output);

end;

{ Функции преобразования к радианам из минут дуги }
function deg2rad(arg: MType): MType;
begin
  result := arg * Pi / 180;
end;

function amin2rad(arg: MType): MType;
begin
  result := arg * Pi / 10800; // / (180 * 60);
end;

function asec2rad(arg: MType): MType;
begin
  result := arg * Pi / 648000; // / (180 * 60 * 60);
end;

{ Нормализация угла в диапазон от 0 до 2 Pi

	входной угол в радианах }
function AngleNormalize(angle: MType): MType;
var
	NewAngle: MType;
begin

	NewAngle := angle / PI2;
  NewAngle := NewAngle - Trunc(NewAngle);
  if NewAngle < 0 then NewAngle := NewAngle + PI2;

  result := NewAngle;

end;

{ Функции возведения в степень }
function pow2(arg: MType): MType;
begin
  result := arg * arg;
end;

function pow3(arg: MType): MType;
begin
  result := arg * arg * arg;
end;

function pow4(arg: MType): MType;
begin
  result := arg * arg * arg * arg;
end;

function pow5(arg: MType): MType;
begin
  result := arg * arg * arg * arg * arg;
end;

end.
