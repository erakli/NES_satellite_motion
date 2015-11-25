unit uIntegrator;

interface

uses
  uConstants, uTypes, Math;

const
  num = 7;

type

  TFunc = function(t: MType; x, dif_x: coordinates): coordinates of object;

  TResult = record
    x, dif_x: coordinates;
  end;

  TCoefVect = array [0 .. num - 1] of MType;
  TCoordVect = array [0 .. num - 1] of coordinates;
  TVect = array [0 .. num] of MType;
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
    c: array [0 .. num, 0 .. num - 1] of MType;
    { Коэффициенты для вычисления A }

    coefA: TCoordVect;
    coefAlpha: TCoordVect;

    coefCoord: TCoefVect; // Численные коэффициенты при вычислении координаты
    coefVeloc: TCoefVect; // и скорости

    memoAlpha: boolean;
    // step : MType; // Шаг интегрирования T
  public
    function ClcCoord(t: MType): coordinates;
    function ClcVeloc(t: MType): coordinates;

    procedure ClcC(step: MType);
    procedure ClcA(n: byte);
    procedure ClcAlpha(i: byte);

    function Integrate(time: MType; x0, dif_x0: coordinates; step: MType;
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
    coefA[i] := NullVec;
    coefAlpha[i] := NullVec;
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

function TEverhart.ClcCoord(t: MType): coordinates;
var
  i: byte;
  temp_sum: coordinates;
begin

  temp_sum := NullVec;

  { IntPower(X, Y) - возведение числа X в целочисленную степень Y }
  for i := Low(coefA) to High(coefA) do
  begin
    temp_sum[0] := temp_sum[0] + coefCoord[i] * coefA[i][0] * IntPower(t, i + 3);
    temp_sum[1] := temp_sum[1] + coefCoord[i] * coefA[i][1] * IntPower(t, i + 3);
    temp_sum[2] := temp_sum[2] + coefCoord[i] * coefA[i][2] * IntPower(t, i + 3);
  end;

  result[0] := x[0][0] + dif_x[0][0] * t + 0.5 * F[0][0] * IntPower(t, 2) +
    temp_sum[0];
  result[1] := x[0][1] + dif_x[0][1] * t + 0.5 * F[0][1] * IntPower(t, 2) +
    temp_sum[1];
  result[2] := x[0][2] + dif_x[0][2] * t + 0.5 * F[0][2] * IntPower(t, 2) +
    temp_sum[2];

end;

{ Вычисление скорости в заданный момент времени с учётом предыдущих
  уточнений (индексация приведена из оригинальной формулы):
  x'(t) = x1' + F1 * t + 1/2 * A[1] * t^2 + 1/3 * A[2] * t^3 +
  + 1/4 * A[3] * t^4 + 1/5 * A[4] * t^5 + 1/6 * A[5] * t^6 +
  + 1/7 * A[6] * t^7 + 1/8 * A[7] * t^8 }

function TEverhart.ClcVeloc(t: MType): coordinates;
var
  i: byte;
  temp_sum: coordinates;
begin

  temp_sum := NuLlVec;

  { IntPower(X, Y) - возведение числа X в целочисленную степень Y }
  for i := Low(coefA) to High(coefA) do
  begin
    temp_sum[0] := temp_sum[0] + coefVeloc[i] * coefA[i][0] * IntPower(t, i + 2);
    temp_sum[1] := temp_sum[1] + coefVeloc[i] * coefA[i][1] * IntPower(t, i + 2);
    temp_sum[2] := temp_sum[2] + coefVeloc[i] * coefA[i][2] * IntPower(t, i + 2);
  end;

  result[0] := dif_x[0][0] + F[0][0] * t + temp_sum[0];
  result[1] := dif_x[0][1] + F[0][1] * t + temp_sum[1];
  result[2] := dif_x[0][2] + F[0][2] * t + temp_sum[2];

end;

{ Вычисление всех необходимы коэффициентов. Разбиение шага T (подшаги)
  вычисляется вместе с коэффициентом c[i, j] }

procedure TEverhart.ClcC(step: MType);
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
  coefAlpha[i][0] := (F[i + 1][0] - F[0][0]) / t[i + 1];
  coefAlpha[i][1] := (F[i + 1][1] - F[0][1]) / t[i + 1];
  coefAlpha[i][2] := (F[i + 1][2] - F[0][2]) / t[i + 1];
  if i > 0 then
  begin
    coefAlpha[i][0] := coefAlpha[i][0] - coefAlpha[0][0];
    coefAlpha[i][1] := coefAlpha[i][1] - coefAlpha[0][1];
    coefAlpha[i][2] := coefAlpha[i][2] - coefAlpha[0][2];
    { Вычисление дополнительных частей ("задних", на которые делится основная) }
    for j := Low(coefAlpha) + 1 to i do
    begin
      coefAlpha[i][0] := coefAlpha[i][0] / (t[i + 1] - t[j]);
      coefAlpha[i][1] := coefAlpha[i][1] / (t[i + 1] - t[j]);
      coefAlpha[i][2] := coefAlpha[i][2] / (t[i + 1] - t[j]);
      if j < i then
      begin
        coefAlpha[i][0] := coefAlpha[i][0] - coefAlpha[j][0];
        coefAlpha[i][1] := coefAlpha[i][1] - coefAlpha[j][1];
        coefAlpha[i][2] := coefAlpha[i][2] - coefAlpha[j][2];
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
      coefA[i][0] := coefA[i][0] + coefAlpha[j][0] * c[j, i];
      coefA[i][1] := coefA[i][1] + coefAlpha[j][1] * c[j, i];
      coefA[i][2] := coefA[i][2] + coefAlpha[j][2] * c[j, i];
    end;
  { c[i, i] = 1, поэтому мы смело начинаем с первого шага }

end;

{ Сама функция интегратора }

function TEverhart.Integrate(time: MType; x0, dif_x0: coordinates; step: MType;
  Func: TFunc): TResult;
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
