unit uMatrix_Operations;

{ Модуль с алгоритмами операций над матрицами и векторами }

interface

uses
  uTypes;

function MultMatrVec(matrx: TMatrix; vec: TVector): TVector;
function RotMatr(axis: byte; t: MType): TMatrix;
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
function RotMatr(axis: byte; t: MType): TMatrix;
var
  Matrix: TMatrix;
begin

	{ Разбить на отдельные функции, чтобы не считать лишнего,
  	посчитать sin и cos изначально, и потом подставлять значения
    в матрицу.

    Также, опционально, изменить формат обращения: сразу перемножать
    исходную матрицу и матрицу поворота }

  case axis of
    1:
    begin
      // Матрица поворота на ОХ

      Matrix[0, 0] := 1;		Matrix[0, 1] := 0;					Matrix[0, 2] := 0;

      Matrix[1, 0] := 0;		Matrix[1, 1] := cos(t);		  Matrix[1, 2] := sin(t);

      Matrix[2, 0] := 0;		Matrix[2, 1] := -sin(t);		Matrix[2, 2] := cos(t);
    end;

    2:
    begin
       // Матрица поворота на ОY

      Matrix[0, 0] := cos(t);		Matrix[0, 1] := 0;		Matrix[0, 2] := -sin(t);

      Matrix[1, 0] := 0;				Matrix[1, 1] := 1;		Matrix[1, 2] := 0;

      Matrix[2, 0] := sin(t);		Matrix[2, 1] := 0;		Matrix[2, 2] := cos(t);
    end;

    3:
    begin
      // Матрица поворота на ОZ

      Matrix[0, 0] := cos(t);		Matrix[0, 1] := sin(t);		Matrix[0, 2] := 0;

      Matrix[1, 0] := -sin(t);	Matrix[1, 1] := cos(t);		Matrix[1, 2] := 0;

      Matrix[2, 0] := 0;				Matrix[2, 1] := 0;				Matrix[2, 2] := 1;
    end;

  else
    begin
      // здесь нужен проброс exeption'а
    end;

  end; // end of case

  result := Matrix;

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
