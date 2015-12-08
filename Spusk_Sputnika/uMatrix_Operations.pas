unit uMatrix_Operations;

{ Модуль с алгоритмами операций над матрицами и векторами }

interface

uses
  uTypes, uConstants;

function ChangeRS(original: TVector): TVector;
function VecSum(first, second: TVector): TVector;
function VecDec(first, second: TVector): TVector;
function ConstProduct(num: MType; vector: TVector): TVector;
function DotProduct(first, second: TVector): MType;
function CrossProduct(first, second: TVector): TVector;

function MultMatrVec(matrx: TMatrix; vec: TVector): TVector;
function MultMatr(m, q: TMatrix): TMatrix;
function TranspMatr(m: TMatrix): TMatrix;
function RotMatr(axis: byte; t: MType): TMatrix;

implementation

{ Параллельный перенос центра СК в точку

	(изменение знака всех координат на противоположные) }
function ChangeRS(original: TVector): TVector;
var
	i: byte;
begin

	for i := Low(original) to High(original) do
    result[i] := - original[i];

end;

{ Сложение (покоординатная) двух векторов }
function VecSum(first, second: TVector): TVector;
var
	i: byte;
begin

	for i := Low(first) to High(first) do
    result[i] := first[i] + second[i];

end;

{ Вычитание второго вектора из первого }
function VecDec(first, second: TVector): TVector;
var
	i: byte;
begin

	for i := Low(first) to High(first) do
    result[i] := first[i] - second[i];

end;

{ Умножение вектора на число }
function ConstProduct(num: MType; vector: TVector): TVector;
var
	i: byte;
begin

	for i := Low(vector) to High(vector) do
    result[i] := vector[i] * num;

end;

{ Скалярное произведение векторов }
function DotProduct(first, second: TVector): MType;
var
	i: byte;
begin

  result := 0;
  for i := Low(first) to High(first) do
    result := result + first[i] * second[i];

end;

{ Векторное произведение векторов }
function CrossProduct(first, second: TVector): TVector;
begin

  result[0] := first[1] * second[2] - first[2] * second[1];
  result[1] := first[2] * second[0] - first[0] * second[2];
  result[2] := first[0] * second[1] - first[1] * second[0];

end;

{ Умножение матрицы на вектор }
function MultMatrVec(matrx: TMatrix; vec: TVector): TVector;
var
  i, j: byte;
begin

  result := NullVec;

  for i := Low(matrx[i]) to High(matrx[i]) do
    for j := Low(vec) to High(vec) do
      result[i] := result[i] + vec[j] * matrx[i, j];

end;

{ Умножение матрицы на матрицу }
function MultMatr(m, q: TMatrix): TMatrix;
var
  i, j, k: byte;
begin

  result := NullMatr;

  for i := Low(result) to High(result) do
    for j := Low(result) to High(result) do
    	for k := Low(result) to High(result) do
      	result[i, j] := result[i, j] + m[i, k] * q[k, j];

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

{ Вращение матрицы вокруг осей }
function RotMatr(axis: byte; t: MType): TMatrix;
var
  cos_t, sin_t: MType;
  R: TMatrix;
begin

	{ t - угол в радианах }

  { Также, опционально, изменить формат обращения: сразу перемножать
    исходную матрицу и матрицу поворота }

  cos_t := cos(t);
  sin_t := sin(t);

  case axis of
    1:
      begin
        // Матрица поворота вокруг ОХ

        R[0, 0] := 1;   R[0, 1] := 0;       R[0, 2] := 0;

        R[1, 0] := 0;   R[1, 1] := cos_t;   R[1, 2] := sin_t;

        R[2, 0] := 0;   R[2, 1] := -sin_t;  R[2, 2] := cos_t;
      end;

    2:
      begin
        // Матрица поворота вокруг ОY

        R[0, 0] := cos_t;   R[0, 1] := 0;     R[0, 2] := -sin_t;

        R[1, 0] := 0;       R[1, 1] := 1;     R[1, 2] := 0;

        R[2, 0] := sin_t;   R[2, 1] := 0;     R[2, 2] := cos_t;
      end;

    3:
      begin
        // Матрица поворота вокруг ОZ

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

end.
