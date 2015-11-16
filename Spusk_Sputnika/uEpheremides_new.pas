unit uEpheremides_new;

interface

uses Math, SysUtils, uTypes;

type
  Ttales = array [0 .. 2] of string;

  TFacility = class
    private
      XYZ: TVector;
      BB: array of MType;
      N: Word;
      LUB: integer; // Строка крайнего задействованного блока
      k, koefs, LUS: Byte;
      // LUS - Last Used SubInterval, параметр, в котором хранится позиция(в массиве ВВ) левой границы последнего считанного подинтервала

    public
      constructor Create(ax, ay, az: MType; aN: Word; ak, akoefs: Byte);
      function Get(JD: MType): TVector;
  end;

function ChebPol(x: MType; j: integer): MType;

// возвращает номер 1-ой строки блока
function BinSearch(need: MType): integer;

// заполняет черный ящик(ВВ)
procedure FillBB(Facility: TFacility; pos: integer; date: MType);

// ищет подынтервал, в который входит need
function SearchSubinterval(Facility: TFacility; need: MType): TVector;

function StepSearch(Facility: TFacility; need: MType): integer;

// разбивает строку на три отдельных слова
function Separation(str: string): Ttales;
procedure creation;

var
  Mercury, Venus, Eart_Moon, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto,
    Moon, Sun: TFacility;

implementation

constructor TFacility.Create;
begin
  LUS := 153; // Если LUS = 153 => вызов функции Get еще не проводился
  XYZ[0] := ax;
  XYZ[1] := ay;
  XYZ[2] := az;
  N := aN; // Этот параметр - индетефикатор объекта
  k := ak;
  koefs := akoefs;
  setlength(BB, 4 * k + 1);
end;

function TFacility.Get;
var
  Search: integer;
begin
  if LUS = 153 then
    Search := BinSearch(JD)
  else if (JD >= BB[0]) and (JD < BB[k]) then // Входит ли в тот же интервал?
    if (JD >= BB[LUS]) and (JD < BB[LUS + 1]) then
    // Да, Входит ли в тот же подынтервал? Первое выражение в квадратных скобках позволяет получить позицию, на которой в ВВ хранится первая граница полуинтервала, второе - соответственно
    begin // Да
      Result := XYZ;
      exit;
    end
    else
    begin
      Result := SearchSubinterval(self, JD);
      exit;
    end
  else
    Search := StepSearch(self, JD);
  FillBB(self, Search, JD);
  LUB := Search;
  Result := SearchSubinterval(self, JD);
end;

function ChebPol(x: MType; j: integer): MType;
begin
  if j = 0 then
    Result := 1
  else if j = 1 then
    Result := x
  else
  begin
    Result := 2 * x * ChebPol(x, j - 1) - ChebPol(x, j - 2);
  end
end;

function BinSearch(need: MType): integer;
var
  LB, RB, MIB: Word;
  LMIB, RMIB: MType;
begin
  LB := 1;
  RB := 1018;
  Result := -1;
  repeat
    MIB := round((RB - LB) / 2) + LB;
    LMIB := StrToFloat(Separation(form2.SVL.Strings[(MIB - 1) * 341 + 1])[0]);
    // НАЗВАНИЕ ФОРМЫ
    RMIB := StrToFloat(Separation(form2.SVL.Strings[(MIB - 1) * 341 + 1])[1]);
    if (need > LMIB) and (need < RMIB) then
      Result := (MIB - 1) * 341
    else if (need > LMIB) then
      LB := MIB + 1
    else
      RB := MIB - 1;
    if RB < LB then
      Result := (LB - 1) * 341;
  until Result > -1;
end;

procedure FillBB(Facility: TFacility; pos: integer; date: MType);
var
  f: boolean;
  i, cor, p: Byte;
  Nu, a, b: integer;
  stt: Ttales;
begin
  stt := Separation(form2.SVL.Strings[pos + 1]);
  case Facility.k of
    1:
      begin
        Facility.BB[0] := StrToFloat(stt[0]);
        Facility.BB[1] := StrToFloat(stt[1]);
      end;
    2:
      begin
        Facility.BB[0] := StrToFloat(stt[0]);
        Facility.BB[2] := StrToFloat(stt[1]);
        Facility.BB[1] := Facility.BB[0] + 0.5 *
          (Facility.BB[2] - Facility.BB[0]);
      end;
    4:
      begin
        Facility.BB[0] := StrToFloat(stt[0]);
        Facility.BB[4] := StrToFloat(stt[1]);
        Facility.BB[1] := Facility.BB[0] + 0.25 *
          (Facility.BB[4] - Facility.BB[0]);
        Facility.BB[2] := Facility.BB[0] + 0.5 *
          (Facility.BB[4] - Facility.BB[0]);
        Facility.BB[3] := Facility.BB[0] + 0.75 *
          (Facility.BB[4] - Facility.BB[0]);
      end;
    8:
      begin
        Facility.BB[0] := StrToFloat(stt[0]);
        Facility.BB[8] := StrToFloat(stt[1]);
        Facility.BB[1] := Facility.BB[0] +
          (Facility.BB[8] - Facility.BB[0]) / 8;
        Facility.BB[2] := Facility.BB[0] + 2 *
          (Facility.BB[8] - Facility.BB[0]) / 8;
        Facility.BB[3] := Facility.BB[0] + 3 *
          (Facility.BB[8] - Facility.BB[0]) / 8;
        Facility.BB[4] := Facility.BB[0] + 4 *
          (Facility.BB[8] - Facility.BB[0]) / 8;
        Facility.BB[5] := Facility.BB[0] + 5 *
          (Facility.BB[8] - Facility.BB[0]) / 8;
        Facility.BB[6] := Facility.BB[0] + 6 *
          (Facility.BB[8] - Facility.BB[0]) / 8;
        Facility.BB[7] := Facility.BB[0] + 7 *
          (Facility.BB[8] - Facility.BB[0]) / 8;
      end;
  end;
  Facility.LUB := pos;
  Nu := Facility.N - 1;
  f := true;
  for i := 0 to Facility.k - 1 do
    for cor := 0 to 2 do
      for p := 0 to Facility.koefs - 1 do
      begin
        Nu := Nu + 1;
        if Nu mod 3 = 0 then
          b := Nu div 3 + pos
        else
          b := Nu div 3 + 1 + pos;
        if f then
        begin
          stt := Separation(form2.SVL.Strings[b]);
          f := False;
        end;
        a := ((Nu - 1) mod 3);
        if a = 2 then
          f := true;

        if p = 0 then
          Facility.BB[3 * i + Facility.k + 1 + cor] := 0;
        Facility.BB[3 * i + Facility.k + 1 + cor] :=
          Facility.BB[3 * i + Facility.k + 1 + cor] + StrToFloat(stt[a]) *
          ChebPol((2 * date - Facility.BB[i] - Facility.BB[i + 1]) /
          (Facility.BB[i + 1] - Facility.BB[i]), p);

      end;
end;

function SearchSubinterval(Facility: TFacility; need: MType): TVector;
var
  N: Smallint;
begin
  for N := 0 to Facility.k - 1 do
    if (need >= Facility.BB[N]) and (need < Facility.BB[N + 1]) then
      break;
  Facility.LUS := N;
  Result[0] := Facility.BB[3 * N + Facility.k + 1];
  Result[1] := Facility.BB[3 * N + Facility.k + 2];
  Result[2] := Facility.BB[3 * N + Facility.k + 3];
end;

function StepSearch(Facility: TFacility; need: MType): integer;
begin
  repeat
    Facility.LUB := Facility.LUB + 341;
  until ((need >= StrToFloat(Separation(form2.SVL.Strings[Facility.LUB + 1])[0])
    ) and (need < StrToFloat(Separation(form2.SVL.Strings[Facility.LUB +
    1])[1])));
  Result := Facility.LUB
end;

function Separation(str: string): Ttales;
var
  i: Byte;
  num1, num2, num3: Byte;
begin
  i := 1;
  while str[i] = ' ' do
    i := i + 1;
  num1 := ifthen(str[i] = '-', 25, 24);
  Result[0] := copy(str, i, num1);
  while str[i + num1] = ' ' do
    i := i + 1;
  num2 := ifthen(str[i + num1] = '-', 25, 24);
  Result[1] := copy(str, i + num1, num2);
  while str[i + num1 + num2] = ' ' do
    i := i + 1;
  num3 := ifthen(str[i + num1 + num2] = '-', 25, 24);
  Result[2] := copy(str, i + num1 + num2, num3);
end;

procedure creation;
begin
  form2.SVL.Strings.LoadFromFile('Здесь мог бы быть путь к файлу');
  Mercury := TFacility.Create(0, 0, 0, 3, 4, 14);
  Venus := TFacility.Create(0, 0, 0, 171, 2, 10);
  Eart_Moon := TFacility.Create(0, 0, 0, 231, 2, 13);
  Mars := TFacility.Create(0, 0, 0, 309, 1, 11);
  Jupiter := TFacility.Create(0, 0, 0, 342, 1, 8);
  Saturn := TFacility.Create(0, 0, 0, 366, 1, 7);
  Uranus := TFacility.Create(0, 0, 0, 387, 1, 6);
  Neptune := TFacility.Create(0, 0, 0, 405, 1, 6);
  Pluto := TFacility.Create(0, 0, 0, 423, 1, 6);
  Moon := TFacility.Create(0, 0, 0, 441, 8, 13);
  Sun := TFacility.Create(0, 0, 0, 753, 2, 11);
end;

end.
