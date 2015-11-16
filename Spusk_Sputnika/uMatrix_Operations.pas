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
  cos_t, sin_t: MType;
  R: TMatrix;
begin

  { Также, опционально, изменить формат обращения: сразу перемножать
    исходную матрицу и матрицу поворота }

  cos_t := cos(t);
  sin_t := sin(t);

  case axis of
    1:
      begin
        // Матрица поворота на ОХ

        R[0, 0] := 1;   R[0, 1] := 0;       R[0, 2] := 0;

        R[1, 0] := 0;   R[1, 1] := cos_t;   R[1, 2] := sin_t;

        R[2, 0] := 0;   R[2, 1] := -sin_t;  R[2, 2] := cos_t;
      end;

    2:
      begin
        // Матрица поворота на ОY

        R[0, 0] := cos_t;   R[0, 1] := 0;     R[0, 2] := -sin_t;

        R[1, 0] := 0;       R[1, 1] := 1;     R[1, 2] := 0;

        R[2, 0] := sin_t;   R[2, 1] := 0;     R[2, 2] := cos_t;
      end;

    3:
      begin
        // Матрица поворота на ОZ

        R[0, 0] := cos_t;   R[0, 1] := sin_t;   R[0, 2] := 0;

        R[1, 0] := -sin_t;  R[1, 1] := cos_t;   R[1, 2] := 0;

        R[2, 0] := 0;       R[2, 1] := 0;       R[2, 2] := 1;
      end

  else
    begin
      { здесь нужен throw exeption }
    end;
  end;

  result := R;

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
