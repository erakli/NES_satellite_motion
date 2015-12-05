unit uTLE_conversation;

interface

{ unfornor - интересные формулы }

uses
  uConstants, uTypes, uTime, SysUtils, Math;

function ReadTLE(TLE: TLE_lines): TTLE_output;

implementation

function ReadTLE(TLE: TLE_lines): TTLE_output;
var
  epoch, MNMOTION, n: MType;
  year: integer;

  temp_str: string;

  Date: TDate;
  Elements: TElements;
begin

  with Date do // обнуляем дату, так как это переменная в функции
  begin
    Month := 0;
    Day := 0;
  end;

  { Читаем первую строку TLE }
  temp_str := Copy(TLE[0], 19, 2);
  year := StrToInt(temp_str);
  if year > CurYear + 1 then
    year := year + 1900
  else
    year := year + 2000;

  Date.year := year;

  temp_str := Copy(TLE[0], 21, 12);

  epoch := FromDateToJD(Date) + StrToFloat(temp_str); { посчитали дату в JD,
    на какой момент имеются TLE }
  { Закончили её читать }

  { Читаем вторую строку TLE }
  MNMOTION := StrToFloat(Copy(TLE[1], 53, 11)); { Частота обращения (оборотов
    в день) (среднее движение) [виток/день].
    Нужна для вычисления a — большой полуоси орбиты (в метрах) }

  Elements[1] := StrToFloat('0.' + Copy(TLE[1], 27, 7));
  // e — эксцентриситет орбиты
  Elements[2] := StrToFloat(Copy(TLE[1], 9, 8));
  // i — угол наклонения орбиты в градусах
  Elements[3] := StrToFloat(Copy(TLE[1], 18, 8));
  // Ω — долгота восходящего узла орбиты в градусах
  Elements[4] := StrToFloat(Copy(TLE[1], 35, 8));
  // ω — аргумент перигея орбиты в градусах
  Elements[5] := StrToFloat(Copy(TLE[1], 44, 8));
  // M — средняя аномалия орбиты в градусах
  Elements[6] := MNMOTION;
  // n - частота обращения
  { Закончили }

  { Получим большую полуось орбиты (из справочного руководства Дубошина, с. 222 }
  MNMOTION := MNMOTION / SecInDay; // Привели к периоду
  n := PI2 * MNMOTION; // среднее движение

  // откуда возведение в 1/3 ?
  Elements[0] := Power(fm / Sqr(n), Third); { a — большая полуось орбиты
    (в метрах), перед расшифровкой необходимо домножить на вес в 1 / 3
    степени }

  result.time := epoch;
  result.Elements := Elements;

end;

end.
