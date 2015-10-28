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
  System.SysUtils, uConstants, uTypes, Classes, Dialogs;

const
  TAI_TT = 32.184; // Константа добавляемая к Атомному времени для перевода в
  // Земное
  TAI_file = 'TAI-UTC.txt';
  EOP_file = 'finals2000A.txt';

type
  TDate = record
    Year, Month, Day, Hour, Minute: word;
    second: MType;
  end;

function FromDateToMJD(Date: TDate): MType;
function FromMJDToDate(MJD: MType): TDate;

function GetDeltaTAI(Date: TDate): MType;
// Поправка к шкале всемирного времени
function GetDeltaUT(MJD: MType): TVector;
// Получение поправки ΔUT = UT1 − UTC и координат полюса

function UT1_time(MJD: MType): MType; // Вычисление Всемирного времени
function TT_time(MJD: MType): MType; // Вычисление земного времени

function TDB_time(MJD: MType): MType;
{ Вычисление барицентрического динамического времени }

var
  FS: TFormatSettings;

  TAI_list, EOP // Сюда будет загружаться файл с ΔUT (finals2000A.txt)
    : TStringList;

implementation

// ---------------------------------------------------------------

function FromDateToMJD(Date: TDate): MType;
var
  temp_year, temp_month, A, B: integer;
//  MJD: MType;
	JD: MType;
  short_period: boolean;
begin

	short_period := true; // если нас интересует промежуток между 1901 и 2099

  with Date do
  begin
		// реализация из comalg.pdf для MJD
//    temp_year := Year - 1900;
//    temp_month := Month - 3;
//    MJD := 15078 + 365.0 * temp_year + INT(temp_year / 4) +
//      INT(0.5 + 30.6 * temp_month);
//
//    result := MJD + Day + Hour / 24 + Minute / 1440 + second / SecInDay;

		// реализация из AA.pdf
		temp_year := Year;

    if short_period then // выбираем короткий промежуток дат
    begin

      temp_year := temp_year - 1;

      B := -13;
      A := Trunc(temp_year / 100);

      JD := 1721409.5 + Trunc(365.25 * (temp_year));

    end
    else   // иначе выбрали полный диапазон
    begin

      temp_month := Month;

      if temp_month <= 2 then
      begin
        temp_year := temp_year - 1;
        temp_month := temp_month + 12;
      end;

      A := Trunc(temp_year / 100);
      B := 2 - A + Trunc(A / 4);

      JD := Trunc(365.25 * (temp_year + 4716))
       + Trunc(30.6001 * (temp_month + 1)) + Day + B - 1524.5;

    end;

    Result := JD - MJDCorrection + Hour / 24 + Minute / 1440 + second / SecInDay;

  end;

end;

function FromMJDToDate(MJD: MType): TDate;
var
  sp, rd: MType;
  nd, nz, na, nb, ma, Year, Month, Day, Hour, Minute: longword;
begin

  rd := INT(MJD) - 15078;
  nd := trunc(rd);
  nz := trunc(rd / 1461.01);
  na := nd - 1461 * nz;
  nb := trunc(na / 365.25);

  Year := 4 * nz + nb + 1900;

  if na = 1461 then
  begin
    Month := 2;
    Day := 29;
  end
  else
  begin
    nz := na - 365 * nb;
    ma := trunc((nz - 0.5) / 30.6);
    Month := ma + 3;
    Day := nz - trunc(30.6 * Month - 91.3);
  end;

  if Month > 12 then
  begin
    Month := Month - 12;
    Year := Year + 1;
  end;

  sp := 24 * (MJD - INT(MJD));
  Hour := trunc(sp);

  sp := 60 * (sp - Hour);
  Minute := trunc(sp);

  result.second := 60 * (sp - Minute);
  result.Minute := Minute;
  result.Hour := Hour;
  result.Day := Day;
  result.Month := Month;
  result.Year := Year;

end;

// *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

{ Получение поправки к шкале Земного времени TT

  Поправка получается из разницы Атомного и Всемирного времени
  (DeltaTT = TAI - UTC) в сек }
function GetDeltaTAI(Date: TDate): MType;
var
  i: integer;
  SearchStr, text: string;
begin

  text := '';

  for i := 0 to TAI_list.Count - 1 do // Поиск строчки с нужной датой
  begin

    SearchStr := TAI_list[i];

    with Date do
    begin

      if (StrToInt(Copy(SearchStr, 1, 4)) <= Year) AND
        (StrToInt(Copy(SearchStr, 6, 2)) <= Month) AND
        (StrToInt(Copy(SearchStr, 9, 2)) < Day) AND (i > 0) then
      begin
        text := Copy(TAI_list[i - 1], 14, 2);
        break;
      end;

    end;

  end;

  if (i = TAI_list.Count - 1) or (text = '') then
  begin
    ShowMessage('Ошибка поиска поправки DeltaTT для даты ' + inttostr(Date.Year)
      + '/' + inttostr(Date.Month) + '/' + inttostr(Date.Day) + '#13#10' +
      ' ' + text);
    result := -1;
    exit;
  end
  else
    result := StrToFloat(text);

end;

{ Получение поправки к UTC для получения UT1 и координат полюса на момент
  времени UT1 }
function GetDeltaUT(MJD: MType): TVector;
// 0 - DUT1, 1-2 - xp, yp (коорд. полюса)
var
  i: integer;
  Date: TDate;
  SearchDate, delta, // Поправка DUT1 (сек)
  xp, yp // Координаты полюса Земли, изменяющиеся со временем (сек дуги)
    : string;
begin

  // Date := FromMJDToDate(MJD);
  delta := '';

  SearchDate := ' ' + inttostr(trunc(MJD)) + '.00 ';

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

  for i := 0 to EOP.Count - 1 do // Поиск строчки с нужной датой
    if pos(SearchDate, EOP[i]) > 0 then
    begin
      delta := Copy(EOP[i], 59, 10);
      xp := Copy(EOP[i], 19, 9);
      yp := Copy(EOP[i], 38, 9);
      break;
    end;

  if (i = EOP.Count - 1) or (delta = '') then
  begin
    ShowMessage('Ошибка поиска поправки DeltaT для даты ' + inttostr(Date.Year)
      + '/' + inttostr(Date.Month) + '/' + inttostr(Date.Day));
    for i := Low(TVector) to High(TVector) do
      result[i] := -1;
    exit;
  end
  else
  begin
    result[0] := StrToFloat(delta);
    result[1] := StrToFloat(xp);
    result[2] := StrToFloat(yp);
  end;

end;

// *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

{ Вычисление Всемирного времени }
function UT1_time(MJD: MType): MType;
var
  DeltaUT: MType;
  // Поправка ΔUT = UT1 − UTC, приближение UTC к UT1 (Всемирному времни)
begin

  DeltaUT := GetDeltaUT(MJD)[0];

  result := MJD + DeltaUT / SecInDay;

end;

{ Вычисление земного времени

  !!! Важно: используется вместо TDB так как СК привязаны к земле !!!

  На вход подаётся время в UTC

  На поверхности Земли и в околоземном пространстве пользуются равномерной
  шкалой земного времени TT. }
function TT_time(MJD: MType): MType;
var
  DeltaTAI: MType;
  Date: TDate;
begin

  Date := FromMJDToDate(MJD);
  DeltaTAI := GetDeltaTAI(Date) + TAI_TT; // Поправка к шкале всемирного времени

  result := MJD + DeltaTAI / SecInDay; // 86400 - сек в дне

end;

{ Вычисление барицентрического динамического времени

  !!! Важно: не используется в виду сложности перевода !!!

  В пределах Солнечной системы пользуются равномерной шкалой барицентри-
  ческого динамического времени TDB.
  В этой шкале вычисляются положения Луны, Солнца и параметры прецессии
  и нутации. }
function TDB_time(MJD: MType): MType;
var
  d, g, // Вспомогательные переменные
  TT { Момент в шкале земного времени TT, выраженный в модифицированных юли-
    анских днях. }
    : MType;
begin

  TT := TT_time(MJD);

  d := (TT - 51544.5) / 36525; { - интервал времени в юлианских столетиях, от
    стандартной эпохи J2000.0, начало которой
    соответствует 1.5 января 2000 года, до текущего
    момента }

  g := 0.017453 * (357.258 + 35999.050 * d); { - приближённое значение аргумента
    перигелия Земли в радианах.
    !Уточнить! }

  result := TT + 0.001658 * sin(g + 0.0167 * sin(g)) / SecInDay;

end;

initialization

// ---------------------------------------------------------------

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
