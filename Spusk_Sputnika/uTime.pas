unit uTime;

interface

{ Счёт юлианских дней идёт от 1 января 4713 года до нашей эры.
  Юлианские сутки (JD) начинаются в полдень.

  MJD - Модифицированные Юлианские Сутки: JD - 2400000.5
  Модифицированные юлианские сутки начинаются в гринвичскую полночь.

  Момент всемирного координированного времени UTC соответствует моменту
  московского декретного времени, уменьшенному на три часа.


  Алгоритмы дают правильный результат на интервале календарных дат со
  2 марта 1900 года по 27 февраля 2100 года. }

uses
  System.SysUtils, Classes, Dialogs, uConstants, uTypes;

const
  TAI_TT: MType = 32.184; // Константа добавляемая к Атомному времени для перевода в Земное
  TAI_file = 'TAI-UTC.txt';
  EOP_file = 'finals2000A.txt';

type
  TDate = record
    Year, Month: word;
    Day: MType;
  end;

function FromDateToJD(Date: TDate): MType;
function FromJDToDate(JD: MType): TDate;

function GetDeltaTAI(Date: TDate): MType;
// Поправка к шкале всемирного времени
function GetDeltaUT(JD: MType): TVector;
// Получение поправки ΔUT = UT1 − UTC и координат полюса

function UT1_time(JD: MType): MType; // Вычисление Всемирного времени
function TT_time(JD: MType): MType; // Вычисление земного времени
function TT2UTC(JD: MType): MType;

function TDB_time(JD: MType): MType;
{ Вычисление барицентрического динамического времени }

var
  FS: TFormatSettings;

  TAI_list, EOP // Сюда будет загружаться файл с ΔUT (finals2000A.txt)
    : TStringList;

  _xp, _yp, // глобальные переменные для мгновенного положения полюса
  _deltaUT: MType; // .. для поправки ΔUT = UT1 − UTC

  delta_got: boolean; // были ли координаты и поправка получены?

implementation

// ---------------------------------------------------------------

function FromDateToJD(Date: TDate): MType;
var
  temp_year, temp_month, A, B: integer;
  // MJD: MType;
  JD: MType;
begin

  with Date do
  begin
    // реализация из comalg.pdf для MJD
    // temp_year := Year - 1900;
    // temp_month := Month - 3;
    // MJD := 15078 + 365.0 * temp_year + INT(temp_year / 4) +
    // INT(0.5 + 30.6 * temp_month);
    //
    // result := MJD + Day + Hour / 24 + Minute / 1440 + second / SecInDay;

    // реализация из AA.pdf
    temp_year := Year;

    temp_month := Month;

    if temp_month <= 2 then
    begin
      temp_year := temp_year - 1;
      temp_month := temp_month + 12;
    end;

    A := Trunc(temp_year / 100);
    B := 2 - A + Trunc(A / 4);

    JD := Trunc(365.25 * (temp_year + 4716)) +
      Trunc(30.6001 * (temp_month + 1)) + Day + B - 1524.5;

    Result := JD;

  end;

end;

function FromJDToDate(JD: MType): TDate;
{ из comalg.pdf для MJD }
// var
// sp, rd: MType;
// nd, nz, na, nb, ma, Year, Month, Day, Hour, Minute: longword;
// begin
//
// rd := INT(JD) - 15078;
// nd := trunc(rd);
// nz := trunc(rd / 1461.01);
// na := nd - 1461 * nz;
// nb := trunc(na / 365.25);
//
// Year := 4 * nz + nb + 1900;
//
// if na = 1461 then
// begin
// Month := 2;
// Day := 29;
// end
// else
// begin
// nz := na - 365 * nb;
// ma := trunc((nz - 0.5) / 30.6);
// Month := ma + 3;
// Day := nz - trunc(30.6 * Month - 91.3);
// end;
//
// if Month > 12 then
// begin
// Month := Month - 12;
// Year := Year + 1;
// end;
//
// sp := 24 * (JD - INT(JD));
// Hour := trunc(sp);
//
// sp := 60 * (sp - Hour);
// Minute := trunc(sp);
//
// result.second := 60 * (sp - Minute);
// result.Minute := Minute;
// result.Hour := Hour;
// result.Day := Day;
// result.Month := Month;
// result.Year := Year;

{ реализация из AA+ }
var
  Z: integer; // the integer part of JD + 0.5
  F: MType; // the fractional (decimal) part of JD + 0.5
  A, alpha, B, C, D, E, m, Year // month number
    : integer;
begin

  Z := Trunc(JD + 0.5);
  F := Frac(JD + 0.5);

  if Z < 2299161 then
    A := Z
  else
  begin
    alpha := Trunc((Z - 1867216.25) / 36524.25);
    A := Z + 1 + alpha - Trunc(alpha / 4);
  end;

  B := A + 1524;
  C := Trunc((B - 122.1) / 365.25);
  D := Trunc(365.25 * C);
  E := Trunc((B - D) / 30.6001);

  Result.Day := B - D - Trunc(30.6001 * E) + F;
  // day of the month (with decimals)

  // month number
  if E < 14 then
    m := E - 1
  else if (E = 14) OR (E = 15) then
    m := E - 13;

  // year
  if m > 2 then
    Year := C - 4716
  else if (m = 1) OR (m = 2) then
    Year := C - 4715;

  Result.Month := m;
  Result.Year := Year;

end;

// *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

{ Получение поправки к шкале Земного времени TT

  Поправка получается из разницы Атомного и Всемирного времени
  (DeltaTT = TAI - UTC) в сек }
function GetDeltaTAI(Date: TDate): MType;
var
  i, SearchYear: integer;
  SearchStr, text: string;
begin

  text := '';

  for i := 1 to TAI_list.Count - 1 do // Поиск строчки с нужной датой
  begin

    SearchStr := TAI_list[i];

    with Date do
    begin

    	SearchYear := StrToInt(Copy(SearchStr, 1, 4));

    	if SearchYear < Year then continue
      else
      if SearchYear = Year then
      	if StrToInt(Copy(SearchStr, 6, 2)) < Month then	continue;

      text := Copy(TAI_list[i - 1], 14, 2);
      break;

    end;

  end;

  if text <> '' then
  	result := StrToFloat(text)
  else
  begin
  	ShowMessage('Ошибка поиска поправки DeltaTT для даты ' + IntToStr(Date.Year)
      + '/' + IntToStr(Date.Month) + '/' + FloatToStr(Date.Day) + '#13#10' +
      ' ' + text);
    Result := -1;
    exit;
  end;

end;

{ Получение поправки к UTC для получения UT1 и координат полюса на момент
  времени UT1

  На вход - время UTC

  Проверить, кто обращается к этой функции }
function GetDeltaUT(JD: MType): TVector;
// 0 - DUT1, 1-2 - xp, yp (коорд. полюса)
var
  i: integer;
  Date: TDate;
  SearchDate, delta, // Поправка DUT1 (сек)
  xp, yp // Координаты полюса Земли, изменяющиеся со временем (сек дуги)
    : string;
begin

  if NOT delta_got then
  begin

    // Date := FromMJDToDate(MJD);
    delta := '';

    SearchDate := ' ' + IntToStr(Trunc(JD - MJDCorrection)) + '.00 ';

    // with Date do // Формирование искомой строки по дате
    // begin
    //
    // if MJD <= 51543 then
    // Year := Year - 1900
    // else
    // Year := Year - 2000;
    //
    // SearchDate := IntToStr(Year);
    //
    // if Month < 10 then
    // SearchDate := SearchDate + ' ';
    //
    // SearchDate := SearchDate + IntToStr(Month);
    //
    // if Day < 10 then
    // SearchDate := SearchDate + ' ';
    //
    // SearchDate := SearchDate + IntToStr(Day);
    //
    // end;

    for i := 0 to EOP.Count - 1 do
      if pos(SearchDate, EOP[i]) > 0 then  // Поиск строчки с нужной датой
      begin
        delta := Copy(EOP[i], 59, 10);
        xp := Copy(EOP[i], 19, 9);
        yp := Copy(EOP[i], 38, 9);
        break;
      end;

    if delta <> '' then
    begin

      _deltaUT := StrToFloat(delta);
      _xp := StrToFloat(xp);
      _yp := StrToFloat(yp);

      delta_got := true;

    end
    else
    begin
      ShowMessage('Ошибка поиска поправки DeltaUT для даты ' +
        IntToStr(Date.Year) + '/' + IntToStr(Date.Month) + '/' +
        FloatToStr(Date.Day));
      for i := Low(TVector) to High(TVector) do
        Result[i] := -1;
      exit;
    end;

  end; // end of   if NOT delta_got

  Result[0] := _deltaUT;
  Result[1] := _xp;
  Result[2] := _yp;

end;

// *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

{ Вычисление Всемирного времени

	На вход UTC }
function UT1_time(JD: MType): MType;
var
  DeltaUT: MType;
  // Поправка ΔUT = UT1 − UTC, приближение UTC к UT1 (Всемирному времни)
begin

  DeltaUT := GetDeltaUT(JD)[0];

  Result := JD + DeltaUT / SecInDay;

end;

{ Вычисление земного времени

  !!! Важно: используется вместо TDB так как СК привязаны к земле !!!

  На вход подаётся время в UTC

  На поверхности Земли и в околоземном пространстве пользуются равномерной
  шкалой земного времени TT. }
function TT_time(JD: MType): MType;
var
  DeltaTT: MType;
  Date: TDate;
begin

  Date := FromJDToDate(JD);
  DeltaTT := GetDeltaTAI(Date) + TAI_TT; // Поправка к шкале всемирного времени

  Result := JD + DeltaTT / SecInDay; // 86400 - сек в дне

end;

function TT2UTC(JD: MType): MType;
var
  DeltaTT: MType;
  Date: TDate;
begin

  Date := FromJDToDate(JD);
  DeltaTT := GetDeltaTAI(Date) + TAI_TT; // Поправка к шкале всемирного времени

  Result := JD - DeltaTT / SecInDay; // 86400 - сек в дне

end;

{ Вычисление барицентрического динамического времени

  !!! Важно: не используется в виду сложности перевода !!!

  В пределах Солнечной системы пользуются равномерной шкалой барицентри-
  ческого динамического времени TDB.
  В этой шкале вычисляются положения Луны, Солнца и параметры прецессии
  и нутации. }
function TDB_time(JD: MType): MType;
var
  D, g, // Вспомогательные переменные
  TT { Момент в шкале земного времени TT, выраженный в модифицированных юли-
    анских днях. }
    : MType;
begin

  TT := TT_time(JD);

  D := (TT - 51544.5) / 36525; { - интервал времени в юлианских столетиях, от
    стандартной эпохи J2000.0, начало которой
    соответствует 1.5 января 2000 года, до текущего
    момента }

  g := 0.017453 * (357.258 + 35999.050 * D); { - приближённое значение аргумента
    перигелия Земли в радианах.
    !Уточнить! }

  Result := TT + 0.001658 * sin(g + 0.0167 * sin(g)) / SecInDay;

end;

initialization

// ---------------------------------------------------------------

_xp := 0;
_yp := 0;
_deltaUT := 0;

delta_got := false;

with FS do
begin
  Create;
  DateSeparator := '/';
  ShortDateFormat := 'yyyy/mm/dd';
end;

TAI_list := TStringList.Create;
TAI_list.LoadFromFile(file_dir + TAI_file);

EOP := TStringList.Create;
EOP.LoadFromFile(file_dir + EOP_file);

finalization

// -----------------------------------------------------------------

TAI_list.Free;
EOP.Free;

end.
