unit uGEO_Potential;

interface

{ Модуль для вычисление ускорения, вызываемое действием геопотенциала в земной
  СК }

uses
  uConstants, uFunctions, uMatrix_Conversation, uMatrix_Operations,
  System.SysUtils, uTypes, Math;

const
  n = 12; // Количество гармоник ?

  // Для гармоник
  // Num_of_harm = 12;
  CS_harmonics = 'pz90_to36.ascii.txt';

type

  TFullForm = record
    main, diff: MType;
  end;

  TParts = record
    x, y, z: MType;
  end;

  TFullForm_Q = record
    main: MType;
    diff: TParts;
  end;

  vec_n = array [2 .. n] of TFullForm; // Вектор для n (с прооизводными)
  vec_k = array [0 .. n] of TFullForm_Q; // Вектор для k (с прооизводными)
  matrx = array [2 .. n, 0 .. n] of TFullForm_Q; { Матрица для слагаемых u и
    Q (ниже) }
  matrx_f = array [1 .. n, 0 .. n] of TFullForm; // Матрица для слагаемых F

  harmonics = array [2 .. n, 0 .. n] of MType;

  { TO-DO:
    * Переработать чтение и формирование гармоник - Done
    * Разобраться с рекуррентной функцией R
    * Проверить правильность всех формул
  }

  TGEO_Potential = class
  private

    _F, // Трёхкомпонентный вектор ускорения в земной СК
    Rt, // Вектор положения объекта в земной СК (преобразованный)
    _r, // Вектор частных производных
    _x, _y, _z // (1/r, x/r, y/r, z/r, где r - радиус вектор)
      : TVector;

    Mct: TMatrix; // Матрица перехода из небесную в земной

    u: matrx; // Суммируемые элементы, входят в U1

    { Слагаемые, составляющие u }
    R: vec_n;
    z: matrx_f;
    Q: matrx;

    { Слагаемые, составляющие Q }
    Xk: vec_k;
    Yk: vec_k;

    { Нормированные коэффициенты разложения гравитационного потенциала Земли
      в ряд по сферическим функциям }
    C, S: harmonics;

    radius: MType; // модуль радиус-вектора от (x, y, z)

    procedure InitStep(t: MType; coord: coordinates);
    procedure MainStep;
  public

    function RightPart(t: MType; coord, veloc: coordinates): coordinates;

    constructor Create;
    destructor Destroy; override;

  end;

var
  GEO_Potential: TGEO_Potential;

implementation

// ---------------------------------------------------------------

{ TGEO_Potential }

constructor TGEO_Potential.Create;
var
  f: TextFile;
  i, j: integer;
  temp_text, FileName: string;
begin

  inherited;

  { Чтение с файла и занесение в массив гармоник

    Переработать }
  FileName := file_dir + CS_harmonics;

  AssignFile(f, FileName);
  Reset(f);

  for i := 2 to n do
  begin
    for j := 0 to i do
    begin
      ReadLn(f, temp_text);
      C[i, j] := StrToFloat(Copy(temp_text, 10, 19));
      S[i, j] := StrToFloat(Copy(temp_text, 30, 19));
    end;
  end;

  CloseFile(f);

end;

destructor TGEO_Potential.Destroy;
begin

  inherited;
end;

{ Начальный шаг алгоритма }
procedure TGEO_Potential.InitStep(t: MType; coord: coordinates);
var
  Rс // Вектор положения объекта в небесной СК
    : TVector;

  temp_r: MType;

  i, j: byte;
  min: array [0 .. 1] of byte; // Флаг на минимально известный элемент массива

  { Дополнительные процедуры для данного шага }

  procedure derivates(var R, x, y, z: TVector);
  var
    i: byte;
  begin
    for i := 0 to m_size do
    begin
      R[i] := -Rt[i] / temp_r;
    end;

    x[0] := 1 / radius - sqr(Rt[0]) / temp_r;
    x[1] := -Rt[0] * Rt[1] / temp_r;
    x[2] := -Rt[0] * Rt[2] / temp_r;

    y[0] := x[1];
    y[1] := 1 / radius - sqr(Rt[1]) / temp_r;
    y[2] := -Rt[1] * Rt[2] / temp_r;

    z[0] := x[2];
    z[1] := y[2];
    z[2] := 1 / radius - sqr(Rt[2]) / temp_r;
  end;

{ Реккуретные формулы }
  function Recur_R(n: integer): TFullForm;
  begin
    with result do
      if (n = 2) and (n > min[0]) then
      begin
        { Стартовые условия для реккуретного процесса (при k = 0 и n = 2) }
        main := fm / radius * sqr((Earth.eq_rad / radius));
        diff := 3 * R[2].main / radius;
      end
      else if n = min[0] then
        result := R[n] // Сюда мы скорее всего не зайдём
      else
      begin
        // main := Earth.eq_rad / radius * Recur_R(n - 1);
        main := Earth.eq_rad / radius * R[n - 1].main;
        diff := (n + 1) * fm * IntPower((Earth.eq_rad / radius), n);
      end;
  end; // End of Recur_R

  function Recur_Z0(n: integer): TFullForm;
  begin
    with result do

      case n of
        1:
          begin
            main := Rt[2] / radius; // Z / r
            diff := 1;
          end;
        2:
          begin
            main := 3 / 2 * sqr(z[1, 0].main) - 1 / 2; // берём посчитанное
            diff := 3 * z[1, 0].main; // ранее
          end;

      else

        if min[1] = n then
          result := z[n, 0] // Сюда мы скорее всего не зайдём
        else
        begin
          main := ((2 * n) * z[1, 0].main * z[n - 1, 0].main - (n - 1) *
            z[n - 2, 0].main) / n;
          diff := n * z[n - 1, 0].main + z[1, 0].main * z[n - 1, 0].diff;
        end;

      end; // End of case

  end; // End of Recur_Z0

begin // ---------------------------- Начало алгоритма начального шага

  Rс[0] := coord.x;
  Rс[1] := coord.y;
  Rс[2] := coord.z;

  Mct := FromFixToTerraM(t); // Вычисление матрицы перехода из небесной в земную

  Rt := MultMatrVec(Mct, Rс); // Умножение матрицы на вектор

  radius := module(coord);
  temp_r := IntPower(radius, 3);

  derivates(_r, _x, _y, _z); // Вычисление частных производных

  { Вычисление с помощью реккурентных функций значений слагаемых -
    составляющих геопотенциал для индекса k = 0 }

  { Страртовые условия для Xk и Yk при k = 0 }
  Xk[0].main := 1;
  Xk[0].diff.x := 0;
  Xk[0].diff.y := 0;

  Yk[0].main := 0;
  Yk[0].diff.x := 0;
  Yk[0].diff.y := 0;

  { Расставление начальных флагов на номер последнего посчитанного элемента }
  min[0] := 1; // Для Rn
  min[1] := 1; // Для Z,

  z[1, 0] := Recur_Z0(1);

  for i := 2 to n do
  begin

    R[i] := Recur_R(i);
    z[i, 0] := Recur_Z0(i);

    Q[i, 0].main := C[i, 0]; // Это коэффициент из гармоник Cn0
    Q[i, 0].diff.x := 0;
    Q[i, 0].diff.y := 0;

    for j := 0 to 1 do
      inc(min[j]);

    { Вычисление частных производных u[n, 0] }
    with u[i, 0] do
    begin
      diff.x := Q[i, 0].main * (R[i].diff * _r[0] * z[i, 0].main + R[i].main *
        z[i, 0].diff * _z[0]);
      diff.y := Q[i, 0].main * (R[i].diff * _r[1] * z[i, 0].main + R[i].main *
        z[i, 0].diff * _z[1]);
      diff.z := Q[i, 0].main * (R[i].diff * _r[2] * z[i, 0].main + R[i].main *
        z[i, 0].diff * _z[2]);
    end;

  end; // End for

  { Компонентам ускорения F′ в земной системе следует придать начальные
    значения }
  for i := Low(_F) to High(_F) do
    _F[i] := -fm * Rt[i] / temp_r;

  for i := 2 to n do
  begin
    _F[0] := _F[0] + u[i, 0].diff.x;
    _F[1] := _F[1] + u[i, 0].diff.y;
    _F[2] := _F[2] + u[i, 0].diff.z;
  end;

end; // ---------------------------- Конец начального шага

{ Основная часть алгоритма }
procedure TGEO_Potential.MainStep;
var
  i, k: byte;
  xr, yr, zr: MType;
begin

  xr := Rt[0] / radius;
  yr := Rt[1] / radius;
  zr := Rt[2] / radius;

  for k := 1 to n do
  begin

    for i := 1 to n do
      z[i, k].main := z[i, k - 1].diff;

    for i := 1 to k do
      z[i, k].diff := 0;

    for i := k + 1 to n do
      z[i, k].diff := (2 * i - 1) * z[i - 1, k].main * zr + z[i - 2, k].diff;

    Xk[k].main := Xk[k - 1].main * xr - Yk[k - 1].main * yr;
    Yk[k].main := Yk[k - 1].main * xr + Xk[k - 1].main * yr;

    with Xk[k].diff do
    begin
      x := Xk[k - 1].diff.x * xr + Xk[k - 1].main - Yk[k - 1].diff.x * yr;
      y := Xk[k - 1].diff.y * xr - Yk[k - 1].diff.y * yr - Yk[k - 1].main;
    end;

    with Yk[k].diff do
    begin
      x := Yk[k - 1].diff.x * xr + Yk[k - 1].main + Xk[k - 1].diff.x * yr;
      y := Yk[k - 1].diff.y * xr + Xk[k - 1].diff.y * yr + Xk[k - 1].main;
    end;

    for i := k to n do
    begin
      Q[i, k].main := C[i, k] * Xk[k].main + S[i, k] * Yk[k].main;
      Q[i, k].diff.x := C[i, k] * Xk[k].diff.x + S[i, k] * Yk[k].diff.x;
      Q[i, k].diff.y := C[i, k] * Xk[k].diff.y + S[i, k] * Yk[k].diff.y;

      u[i, k].diff.x := R[i].diff * _r[0] * z[i, k].main * Q[i, k].main +
        R[i].main * z[i, k].diff * _z[0] * Q[i, k].main + R[i].main *
        z[i, k].main * (Q[i, k].diff.x * _x[0] + Q[i, k].diff.y * _y[0]);

      u[i, k].diff.y := R[i].diff * _r[1] * z[i, k].main * Q[i, k].main +
        R[i].main * z[i, k].diff * _z[1] * Q[i, k].main + R[i].main *
        z[i, k].main * (Q[i, k].diff.x * _x[1] + Q[i, k].diff.y * _y[1]);

      u[i, k].diff.z := R[i].diff * _r[2] * z[i, k].main * Q[i, k].main +
        R[i].main * z[i, k].diff * _z[2] * Q[i, k].main + R[i].main *
        z[i, k].main * (Q[i, k].diff.x * _x[2] + Q[i, k].diff.y * _y[2]);

      // Окончательно считаем ускорения
      _F[0] := _F[0] + u[i, k].diff.x;
      _F[1] := _F[1] + u[i, k].diff.y;
      _F[2] := _F[2] + u[i, k].diff.z;
    end;

  end; // End for k...

end; // ---------------------------- Конец Основной части

function TGEO_Potential.RightPart(t: MType; coord, veloc: coordinates)
  : coordinates;
var
  Mtc: TMatrix; // Матрица перехода из земной в небесную
  Fe: TVector; // Матрица ускорения в небесной СК
begin

  InitStep(t, coord); // Начальный шаг алгоритма
  MainStep;

  Mtc := FromTerraToFixM(t);
  Fe := MultMatrVec(Mtc, _F);

  result.x := Fe[0];
  result.y := Fe[1];
  result.z := Fe[2];

end;

end.
