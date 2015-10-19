unit uIntegrator;

interface

uses
  uConstants, Math;

const
  num = 7;

type

  TFunc = function(t: double; x, dif_x: coordinates): coordinates of object;

  TResult = record
    x, dif_x: coordinates;
  end;

  TCoefVect = array [0 .. num - 1] of double;
  TCoordVect = array [0 .. num - 1] of coordinates;
  TVect = array [0 .. num] of double;
  TXVect = array [0 .. num] of coordinates;

  {
    TO-DO:
    * Трёхразовое уточнение коэффициентов - как?
    * Вывод результата по окончании шага - как связать с имеющимеся функциями
    ClcCoord и ClcVeloc? - ok
    * Описать процесс интегрирования - ok
    * Создать функцию получения правых частей!
  }

  TEverhart = class(TObject)
  private
    x: TXVect;
    dif_x: TXVect;

    h: TVect; { Коэффициенты уточнений }
    F: TXVect; { Вектор значений функций в подшагах }
    t: TVect; { t[i] := h[i] * step - подшаги }
    c: array [0 .. num, 0 .. num - 1] of double;
    { Коэффициенты для вычисления A }

    coefA: TCoordVect;
    coefAlpha: TCoordVect;

    coefCoord: TCoefVect; // Численные коэффициенты при вычислении координаты
    coefVeloc: TCoefVect; // и скорости

    memoAlpha: boolean;
    // step : double; // Шаг интегрирования T
  public
    function ClcCoord(t: double): coordinates;
    function ClcVeloc(t: double): coordinates;

    procedure ClcC(step: double);
    procedure ClcA(n: byte);
    procedure ClcAlpha(i: byte);

    function Integrate(time: double; x0, dif_x0: coordinates; step: double;
      Func: TFunc): TResult;

    constructor Create;
    destructor Destroy; override;
  end;

var
  Everhart: TEverhart;

implementation
// ---------------------------------------------------------------

constructor TEverhart.Create;
var
  i: byte;
begin

  inherited;

  for i := Low(coefA) to High(coefA) do
  begin
    coefA[i] := ResetCoord;
    coefAlpha[i] := ResetCoord;
  end;

  { Разбиения шага интегрирования }
  h[0] := 0.000000000000000000;
  h[1] := 0.056262560526922147;
  h[2] := 0.180240691736892365;
  h[3] := 0.352624717113169637;
  h[4] := 0.547153626330555383;
  h[5] := 0.734210177215410532;
  h[6] := 0.885320946839095768;
  h[7] := 0.977520613561287501;

  { Численные коэффициенты перед слагаемыми с A в вычислении координаты }
  coefCoord[0] := 1 / 6;
  coefCoord[1] := 1 / 12;
  coefCoord[2] := 1 / 20;
  coefCoord[3] := 1 / 30;
  coefCoord[4] := 1 / 42;
  coefCoord[5] := 1 / 56;
  coefCoord[6] := 1 / 72;

  { Численные коэффициенты перед слагаемыми с A в вычислении скорости }
  for i := Low(coefVeloc) to High(coefVeloc) do
    coefVeloc[i] := 1 / (i + 2);

  memoAlpha := false; // Запоминание коэффициентов Альфа для следующего шага

end;

destructor TEverhart.Destroy;
begin

  inherited;
end;

{ Вычисление координаты в заданный момент времени с учётом предыдущих
  уточнений (индексация приведена из оригинальной формулы):
  x(t) = x1 + x1' * t + 1/2 * F1 * t^2 + 1/6 * A[1] * t^3 +
  + 1/12 * A[2] * t^4 + 1/20 * A[3] * t^5 + 1/30 * A[4] * t^6 +
  + 1/42 * A[5] * t^7 + 1/56 * A[6] * t^8 + 1/72 * A[7] * t^9 }

function TEverhart.ClcCoord(t: double): coordinates;
var
  i: byte;
  temp_sum: coordinates;
begin

  temp_sum := ResetCoord;

  { IntPower(X, Y) - возведение числа X в целочисленную степень Y }
  for i := Low(coefA) to High(coefA) do
  begin
    temp_sum.x := temp_sum.x + coefCoord[i] * coefA[i].x * IntPower(t, i + 3);
    temp_sum.y := temp_sum.y + coefCoord[i] * coefA[i].y * IntPower(t, i + 3);
    temp_sum.z := temp_sum.z + coefCoord[i] * coefA[i].z * IntPower(t, i + 3);
  end;

  result.x := x[0].x + dif_x[0].x * t + 0.5 * F[0].x * IntPower(t, 2) +
    temp_sum.x;
  result.y := x[0].y + dif_x[0].y * t + 0.5 * F[0].y * IntPower(t, 2) +
    temp_sum.y;
  result.z := x[0].z + dif_x[0].z * t + 0.5 * F[0].z * IntPower(t, 2) +
    temp_sum.z;

end;

{ Вычисление скорости в заданный момент времени с учётом предыдущих
  уточнений (индексация приведена из оригинальной формулы):
  x'(t) = x1' + F1 * t + 1/2 * A[1] * t^2 + 1/3 * A[2] * t^3 +
  + 1/4 * A[3] * t^4 + 1/5 * A[4] * t^5 + 1/6 * A[5] * t^6 +
  + 1/7 * A[6] * t^7 + 1/8 * A[7] * t^8 }

function TEverhart.ClcVeloc(t: double): coordinates;
var
  i: byte;
  temp_sum: coordinates;
begin

  temp_sum := ResetCoord;

  { IntPower(X, Y) - возведение числа X в целочисленную степень Y }
  for i := Low(coefA) to High(coefA) do
  begin
    temp_sum.x := temp_sum.x + coefVeloc[i] * coefA[i].x * IntPower(t, i + 2);
    temp_sum.y := temp_sum.y + coefVeloc[i] * coefA[i].y * IntPower(t, i + 2);
    temp_sum.z := temp_sum.z + coefVeloc[i] * coefA[i].z * IntPower(t, i + 2);
  end;

  result.x := dif_x[0].x + F[0].x * t + temp_sum.x;
  result.y := dif_x[0].y + F[0].y * t + temp_sum.y;
  result.z := dif_x[0].z + F[0].z * t + temp_sum.z;

end;

{ Вычисление всех необходимы коэффициентов. Разбиение шага T (подшаги)
  вычисляется вместе с коэффициентом c[i, j] }

procedure TEverhart.ClcC(step: double);
var
  i, j: byte;
begin

  for i := 0 to num do
  begin
    t[i] := h[i] * step;

    c[i, i] := 1;
    if i > 0 then
    begin
      c[i, 0] := -t[i] * c[i - 1, 0];
      if i > 1 then
        for j := 1 to i - 1 do
          c[i, j] := c[i - 1, j - 1] - t[i] * c[i - 1, j];
    end;
  end;

end;

procedure TEverhart.ClcAlpha(i: byte);
var
  j: byte;
begin

  { Последовательный расчёт коэффициентов Альфа, присоединением новых
    вычислительных частей }
  { Вычисление основной части }
  coefAlpha[i].x := (F[i + 1].x - F[0].x) / t[i + 1];
  coefAlpha[i].y := (F[i + 1].y - F[0].y) / t[i + 1];
  coefAlpha[i].z := (F[i + 1].z - F[0].z) / t[i + 1];
  if i > 0 then
  begin
    coefAlpha[i].x := coefAlpha[i].x - coefAlpha[0].x;
    coefAlpha[i].y := coefAlpha[i].y - coefAlpha[0].y;
    coefAlpha[i].z := coefAlpha[i].z - coefAlpha[0].z;
    { Вычисление дополнительных частей ("задних", на которые делится основная) }
    for j := Low(coefAlpha) + 1 to i do
    begin
      coefAlpha[i].x := coefAlpha[i].x / (t[i + 1] - t[j]);
      coefAlpha[i].y := coefAlpha[i].y / (t[i + 1] - t[j]);
      coefAlpha[i].z := coefAlpha[i].z / (t[i + 1] - t[j]);
      if j < i then
      begin
        coefAlpha[i].x := coefAlpha[i].x - coefAlpha[j].x;
        coefAlpha[i].y := coefAlpha[i].y - coefAlpha[j].y;
        coefAlpha[i].z := coefAlpha[i].z - coefAlpha[j].z;
      end;
    end;
  end;

end;

procedure TEverhart.ClcA(n: byte);
var
  i, j: byte;
begin

  for i := Low(coefA) to n do
    for j := i to High(coefAlpha) do
    begin
      coefA[i].x := coefA[i].x + coefAlpha[j].x * c[j, i];
      coefA[i].y := coefA[i].y + coefAlpha[j].y * c[j, i];
      coefA[i].z := coefA[i].z + coefAlpha[j].z * c[j, i];
    end;
  { c[i, i] = 1, поэтому мы смело начинаем с первого шага }

end;

{ Сама функция интегратора }

function TEverhart.Integrate(time: double; x0, dif_x0: coordinates;
  step: double; Func: TFunc): TResult;
var
  i: byte;
begin

  // Здесь я прибавляю текущее время только при вычислении функции

  x[0] := x0;
  dif_x[0] := dif_x0;
  F[0] := Func(t[0] + time, x[0], dif_x[0]);

  ClcC(step);

  for i := Low(t) to High(t) - 1 do
  begin

    x[i + 1] := ClcCoord(t[i + 1]);
    dif_x[i + 1] := ClcVeloc(t[i + 1]);
    F[i + 1] := Func(t[i + 1] + time, x[i + 1], dif_x[i + 1]);

    if NOT memoAlpha then
    begin
      ClcAlpha(i);
      memoAlpha := true;
    end;

    ClcA(i);

  end;

  x[High(x)] := ClcCoord(t[High(t)]);
  dif_x[High(dif_x)] := ClcVeloc(t[High(t)]);

  result.x := x[High(x)];
  result.dif_x := dif_x[High(dif_x)];

end;

end.
