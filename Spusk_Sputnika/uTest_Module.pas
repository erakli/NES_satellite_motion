unit uTest_Module;

{
  TO-DO:
  * Ввести поиск необходимой TLE с последующим отсчётом от неё интервала
  (здесь принято за интервал). По факту, это время заданное пользователем
  минус время ближайшей TLE

  * Не забыть сделать перевод гелеоцентрических координат в ГЕО (которые выдаёт
  функция из DLL). Под 4 индексом массива elements имеется геоцентрическое
  расстояние объекта в AU - это надо учитывать.

  * Разобраться с JDEquinox
}

interface

uses
  uConstants, uTypes, uEpheremides, Dialogs, System.SysUtils, uAtmosphericDrag,
  uKepler_Conversation, uFunctions, uTLE_conversation, uMatrix_Conversation,
  uMatrix_Operations, uTime, uEpheremides_new;

type
  // ------------------------------------------- для dll
  EllipticalHandle = THandle;

  tObjectElem = record
    a, e, i, w, omega, JDEquinox, T: MType;
  end;

  tObjectDetails = record
    CoordinateEquatorial, CoordinateEcliptical: TVector;
    elments: array [0 .. 11] of MType;
  end;

const
  ElemInit: array [0 .. 6] of MType = (2.2091404, 0.8502196, 11.94524,
    334.75006, 186.23352, 2448192.5 + 0.54502, 2451544.5); // для примера из AA
  {
    a := ElemInit[0];
    e := ElemInit[1];
    i := ElemInit[2];
    omega := ElemInit[3];
    w := ElemInit[4];
    T := ElemInit[5];
    JDEquinox := ElemInit[6];
  }
  // ------------------------------------------- /для dll

var
  i: byte;
  a: MType;
  r: array [0 .. 5] of MType;
  not_load: shortint;

  JD, Sb_coeff, dist1, dist2, interval: MType;
  coord, v: TVector;

  TLE: TLE_lines;
  TLE_output: output;

  Kepler_Elements: TElements;
  Dubosh: boolean;

  Transform: TMatrix;

  // ------------------------------------------- для dll
  Elements: tObjectElem;
  Details: tObjectDetails;

  Elliptical: EllipticalHandle;

  // функция из dll
function EllipticalCalculate(handle: EllipticalHandle; JD: MType;
  Elements: tObjectElem; bHighPrecision: boolean = false)
  : tObjectDetails; stdcall;
// ------------------------------------------- /для dll

function test_uMatrix_Operations: boolean;

////////////////////////////////////////////////////////////////////////////////
implementation

const
  DLLName = 'AA.dll';

function EllipticalCalculate; external DLLName; // реализация в другом месте

function test_uMatrix_Operations: boolean;
const
	testMatrix1: TMatrix = ((1, 2, 3),
  											  (4, 5, 6),
                          (7, 8, 9));
  testMatrix2: TMatrix = ((4, 1, 7),
  												(0, 3, 1),
                          (3, 3, 4));
  StartVector: TVector = (4, 2, 6);
var
	Matrix1, Matrix2: TMatrix;
  Vector1, Vector2: TVector;
begin

	Vector1 := MultMatrVec(testMatrix1, StartVector);
  Matrix1 := MultMatr(testMatrix1, testMatrix2);

end;

////////////////////////////////////////////////////////////////////////////////
initialization

test_uMatrix_Operations;

JD := 2415284.191;
Creation(3);
coord := Earth_Moon.Get(JD);

// MJD := 57258;

interval := 0;
// интервал, на который считаются координаты. необходимо для JDEquinox

TLE[0] := '1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0  3477';
TLE[1] := '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.66622191302881';

TLE_output := ReadTLE(TLE);
//MJD := TLE_output.time;
JD := TLE_output.time;

{ a, s_e, i, b_Omega, s_omega, M, n - Кеплеровские элементы орбиты (7) }
with Elements do
begin
  a := TLE_output.Elements[0];
  e := TLE_output.Elements[1];
  i := TLE_output.Elements[2];
  omega := TLE_output.Elements[3];
  w := TLE_output.Elements[4];
  JDEquinox := JD + interval; // как я понял, на этот момент получаем координаты
  T := JDEquinox - TLE_output.Elements[5] / TLE_output.Elements[6];
  // уточнить справедливость вычитания
end;

Details := EllipticalCalculate(Elliptical, JD, Elements);

Kepler_Elements := TLE_output.Elements;
// метод из Дубошина
coord := Kepler_to_Decart(Kepler_Elements, 0, Dubosh).coord;
v := Kepler_to_Decart(Kepler_Elements, 0, Dubosh).speed;

//coord := Kepler_to_Decart(Kepler_Elements, 0).coord; // метод из comalg.pdf

coord := MultMatrVec(ITRS2GCRS(TT_time(JD)), coord);

dist1 := module(v) - 6378.1366;
dist2 := module(coord) - 6378.1366;

{ //---------------------------------------- для случая из учебника AA (с. 232)
  JD := 2448170.5;
  MJD := JD - MJDCorrection;

  with Elements do
  begin
  a := ElemInit[0];
  e := ElemInit[1];
  i := ElemInit[2];
  omega := ElemInit[3];
  w := ElemInit[4];
  T := ElemInit[5];
  JDEquinox := ElemInit[6];
  end;

  Details := EllipticalCalculate(Elliptical, Jd, Elements); // вычисляем геоцентричискую позицию спутника

  dist1 := 0;
  dist2 := 0;

  with Details do
  begin
  for i := 0 to 2 do
  begin
  dist1 := dist1 + sqr(CoordinateEquatorial[i]);
  dist2 := dist2 + sqr(CoordinateEcliptical[i]);
  end;

  dist1 := sqrt(dist1);
  dist2 := sqrt(dist2);
  end;
}

// for i := 0 to 5 do Elements[i] := ElemInit[i];
//
// coord := Kepler_to_Decart(Elements, 0).coord;


// AtmosphericDrag.RightPart(MJD, coord, v, Sb_coeff);  // Необходимы параметры

// a := 2457198.5;
// not_load := 0;

end.
