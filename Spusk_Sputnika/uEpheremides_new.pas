unit uEpheremides_new;

interface

{ Модуль для получения эфемерид

	Planetary positions are stored in units of kilometers (TDB-compatible). }

uses Math, SysUtils, uTypes, Classes;

const

  eph_file = 'ascp1900.421';

type
  TStrVector = array [0 .. 2] of string;

  TFacility = class(TObject)
    private
      XYZ: TVector;
      BB: array of MType;
      N: Word;
      LUB: integer; // Строка крайнего задействованного блока
      k, koefs, LUS: Byte;
      { LUS - Last Used SubInterval, параметр, в котором хранится позиция (в
      	массиве ВВ) левой границы последнего считанного подинтервала }

    public
      function Get(JD: MType): TVector;

      constructor Create(aX, aY, aZ: MType; aN: Word; ak, akoefs: Byte);
    	destructor Destroy; override;
  end;

function ChebPol(x: MType; j: integer): MType;

// возвращает номер 1-ой строки блока
function BinSearch(need: MType): integer;

// заполняет черный ящик (ВВ)
procedure FillBB(Facility: TFacility; pos: integer; date: MType);

// ищет подынтервал, в который входит need
function SearchSubinterval(Facility: TFacility; need: MType): TVector;

function StepSearch(Facility: TFacility; need: MType): integer;

// разбивает строку на три отдельных слова
function Separation(str: string): TStrVector;

// получение эфемерид для определённого объекта
procedure EphCreation(FacilityNum: byte);
{
	 1	Mercury
   2	Venus
   3	Earth-Moon barycenter
   4	Mars
   5	Jupiter
   6	Saturn
   7	Uranus
   8	Neptune
   9	Pluto
   10	Moon (geocentric)
   11	Sun
}

var
	// можно оптимизировать, введя динамический массив, расширяемый при добавлении
  // нового объекта
  Mercury, Venus, Earth_Moon, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto,
    Moon, Sun_bary: TFacility;

  // Глобальная переменная для хранения всего файла DE.
  // Внимание: может оказаться ресурсоёмким
  DEfile_list: TStringList;


implementation // --------------------------------------------------------------

{ TFacility }

constructor TFacility.Create;
begin
  LUS := 153; // Если LUS = 153 => вызов функции Get еще не проводился
  XYZ[0] := aX;
  XYZ[1] := aY;
  XYZ[2] := aZ;
  N := aN; // Этот параметр - индетефикатор объекта
  k := ak;
  koefs := akoefs;
  SetLength(BB, 4 * k + 1);
end;

destructor TFacility.Destroy;
begin
	SetLength(BB, 0);
	inherited;
end;

function TFacility.Get;
var
  Search: integer;
begin
  if LUS = 153 then
    Search := BinSearch(JD)
  else
  	if (JD >= BB[0]) and (JD < BB[k]) then // Входит ли в тот же интервал?

      if (JD >= BB[LUS]) and (JD < BB[LUS + 1]) then
      { Да, Входит ли в тот же подынтервал?

      	Первое выражение в квадратных скобках позволяет получить позицию,
        на которой в ВВ хранится первая граница полуинтервала,
        второе - соответственно }
      begin // Да
        Result := XYZ;
        exit;
      end
      else
      begin
        XYZ := SearchSubinterval(self, JD);
        Result := XYZ;
        exit;
      end

    else
      Search := StepSearch(self, JD);

  FillBB(self, Search, JD);
  LUB := Search;
  XYZ := SearchSubinterval(self, JD);
  Result := XYZ;
end;


{ ------------- Вспомогательные функции ------------- }

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

// возвращает номер 1-ой строки блока
function BinSearch(need: MType): integer;
var
  LB, RB, MIB: Word;
  LMIB, RMIB: MType;

  block: TStrVector;
begin
  LB := 1;
  //RB := 1018;
  RB := 1713; // крайний блок файла эфемерид (блоки по 32 дня)
  Result := -1;

  repeat
    MIB := round((RB - LB) / 2) + LB;

    block := Separation(DEfile_list[(MIB - 1) * 341 + 1]);
    LMIB := StrToFloat(block[0]);
    RMIB := StrToFloat(block[1]);

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

// заполняет черный ящик (ВВ)
procedure FillBB(Facility: TFacility; pos: integer; date: MType);
var
  f: boolean;
  i, cor, p: Byte;
  Nu, a, b: integer;
  stt: TStrVector;

  temp_value: MType;
begin
  stt := Separation(DEfile_list[pos + 1]);

  with Facility do
    case k of
      1:
        begin
          BB[0] := StrToFloat(stt[0]);
          BB[1] := StrToFloat(stt[1]);
        end;
      2:
        begin
          BB[0] := StrToFloat(stt[0]);
          BB[2] := StrToFloat(stt[1]);
          BB[1] := BB[0] + 0.5 * (BB[2] - BB[0]);
        end;
      4:
        begin
          BB[0] := StrToFloat(stt[0]);
          BB[4] := StrToFloat(stt[1]);
          BB[1] := BB[0] + 0.25 * (BB[4] - BB[0]);
          BB[2] := BB[0] + 0.5 * (BB[4] - BB[0]);
          BB[3] := BB[0] + 0.75 * (BB[4] - BB[0]);
        end;
      8:
        begin
          BB[0] := StrToFloat(stt[0]);
          BB[8] := StrToFloat(stt[1]);

          temp_value := (BB[8] - BB[0]) / 8;
          for i := 1 to 7 do
          	BB[i] := BB[0] + i * temp_value;
        end;
    end; // end of case

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
          stt := Separation(DEfile_list[b]);
          f := False;
        end;
        a := ((Nu - 1) mod 3);
        if a = 2 then
          f := true;

        with Facility do
        begin
          if p = 0 then
            BB[3 * i + k + 1 + cor] := 0;

          BB[3 * i + k + 1 + cor] :=
                                  BB[3 * i + k + 1 + cor] + StrToFloat(stt[a]) *
                                  ChebPol((2 * date - BB[i] - BB[i + 1]) /
                                  (BB[i + 1] - BB[i]), p);
        end; // end of: with Facility do

      end; // end of: for p := 0 to Facility.koefs - 1 do
end;

// ищет подынтервал, в который входит need
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
var
	block: TStrVector;
  dec_const: ShortInt;
begin
	dec_const := 1;

	with Facility do
  begin

  	block := Separation(DEfile_list[LUB + 1]);
  	if need < StrToFloat(block[0]) then     // если искомая дата находится до нижней границы текущего блока, идём в обратном направлении
    	dec_const := -1;

    repeat
      LUB := LUB + 341 * dec_const;
      block := Separation(DEfile_list[LUB + 1]);
    until ( (need >= StrToFloat(block[0])) AND (need < StrToFloat(block[1])) );

  end;

  Result := Facility.LUB;
end;

// разбивает строку на три отдельных слова
function Separation(str: string): TStrVector;
var
  i: Byte;
  num1, num2, num3: Byte;

  work_str: string;
begin
  work_str := StringReplace(str, 'D', 'e', [rfReplaceAll, rfIgnoreCase]);

  i := 1;
  while work_str[i] = ' ' do
    i := i + 1;
  num1 := ifthen(work_str[i] = '-', 25, 24);
  Result[0] := copy(work_str, i, num1);

  while work_str[i + num1] = ' ' do
    i := i + 1;
  num2 := ifthen(work_str[i + num1] = '-', 25, 24);
  Result[1] := copy(work_str, i + num1, num2);

  while work_str[i + num1 + num2] = ' ' do
    i := i + 1;
  num3 := ifthen(work_str[i + num1 + num2] = '-', 25, 24);
  Result[2] := copy(work_str, i + num1 + num2, num3);
end;

// получение эфемерид для определённого объекта
procedure EphCreation;
begin
  DEfile_list.LoadFromFile(eph_file);

  case FacilityNum of
  	1:  Mercury := TFacility.Create(0, 0, 0, 3, 4, 14);

    2:  Venus := TFacility.Create(0, 0, 0, 171, 2, 10);

    3:	Earth_Moon := TFacility.Create(0, 0, 0, 231, 2, 13);

    4:	Mars := TFacility.Create(0, 0, 0, 309, 1, 11);

    5:	Jupiter := TFacility.Create(0, 0, 0, 342, 1, 8);

    6:  Saturn := TFacility.Create(0, 0, 0, 366, 1, 7);

    7:  Uranus := TFacility.Create(0, 0, 0, 387, 1, 6);

    8:  Neptune := TFacility.Create(0, 0, 0, 405, 1, 6);

    9:  Pluto := TFacility.Create(0, 0, 0, 423, 1, 6);

    10:  Moon := TFacility.Create(0, 0, 0, 441, 8, 13);

    11:  Sun_bary := TFacility.Create(0, 0, 0, 753, 2, 11)

  end;

end;

initialization

	DEfile_list := TStringList.Create;

finalization

	DEfile_list.Free;

end.
