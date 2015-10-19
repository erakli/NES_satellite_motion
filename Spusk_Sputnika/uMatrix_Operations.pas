unit uMatrix_Operations;

{ Модуль с алгоритмами операций над матрицами и векторами }

interface

uses
  uConstants;

function MultMatrVec(matrx: TMatrix; vec: TVector): TVector;
function RotMatr(t: double): TMassive;
function MultMatr(m, q: TMatrix): TMatrix;
function TranspMatr(m: TMatrix): TMatrix;

const
  NullVec: TVector = (0, 0, 0);
  NullMatr: TMatrix = ((0, 0, 0), (0, 0, 0), (0, 0, 0));

implementation

{ Умножение матрицы на вектор }
function MultMatrVec(matrx: TMatrix; vec: TVector): TVector;
var
  i, j: byte;
begin

  result := NullVec;

  for i := Low(vec) to High(vec) do
    for j := Low(matrx[i]) to High(matrx[i]) do
      result[i] := result[i] + vec[i] * matrx[i, j];

end;

{ Вращение матрицы вокруг осей }
function RotMatr(t: double): TMassive;
begin

  with result do
  begin

    // Матрица поворота на ОХ

    x[0, 0] := 1;
    x[0, 1] := 0;
    x[0, 2] := 0;

    x[1, 0] := 0;
    x[1, 1] := cos(t);
    x[1, 2] := -sin(t);

    x[2, 0] := 0;
    x[2, 1] := sin(t);
    x[2, 2] := cos(t);

    // Матрица поворота на ОY

    y[0, 0] := cos(t);
    y[0, 1] := 0;
    y[0, 2] := sin(t);

    y[1, 0] := 0;
    y[1, 1] := 1;
    y[1, 2] := 0;

    y[2, 0] := (-sin(t));
    y[2, 1] := 0;
    y[2, 2] := cos(t);

    // Матрица поворота на ОZ

    z[0, 0] := cos(t);
    z[0, 1] := -sin(t);
    z[0, 2] := 0;

    z[1, 0] := sin(t);
    z[1, 1] := cos(t);
    z[1, 2] := 0;

    z[2, 0] := 0;
    z[2, 1] := 0;
    z[2, 2] := 1;

  end;

end;

{ Умножение матрицы на матрицу }
function MultMatr(m, q: TMatrix): TMatrix;
var
  i, j: byte;
begin

  result := NullMatr;

  for i := Low(result) to High(result) do
    for j := Low(result) to High(result) do
      result[i, j] := result[i, j] + m[i, j] * q[i, j];

end;

{ Транспонирование матрицы }
function TranspMatr(m: TMatrix): TMatrix;
var
  i, j: byte;
begin

  for i := Low(result) to High(result) do
    for j := Low(result) to High(result) do
      result[j, i] := m[i, j];
end;

end.
