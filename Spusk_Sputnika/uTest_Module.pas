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
  Windows, Dialogs, System.SysUtils,
  uConstants, uTypes,
  uMatrix_Operations, uTime, uKepler_Conversation, uTLE_conversation,
  uEpheremides,
  uAtmosphericDrag, uFunctions,
  uMatrix_Conversation, uEpheremides_new;

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

procedure console_output(Vector: array of MType); overload;
procedure console_output(Matrix: TMatrix); overload;
procedure console_output(Date: TDate); overload;

function test_uMatrix_Operations: boolean;
function test_uTime: boolean;
function test_uTLE_conversation: boolean;
function test_uKepler_Conversation: boolean;

var
  i: byte;
  a: MType;
  r: array [0 .. 5] of MType;
  not_load: shortint;

  JD, Sb_coeff, dist1, dist2, interval: MType;
  coord, v: TVector;

  TLE: TLE_lines;
  TLE_output: TTLE_output;

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

////////////////////////////////////////////////////////////////////////////////
implementation

const
  DLLName = 'AA.dll';

function EllipticalCalculate; external DLLName; // реализация в другом месте


procedure console_output(Vector: array of MType);
var
  j: byte;
begin

  for j := 0 to High(Vector) do
    write(FloatToStrF(Vector[j], ffGeneral, 8, 4), '	');
  writeln;
  writeln;

end;

procedure console_output(Matrix: TMatrix);
var
  i, j: byte;
begin

	for i := 0 to m_size do
  begin

  	for j := 0 to m_size do
			write(FloatToStrF(Matrix[i][j], ffGeneral, 8, 4), '	');
    writeln;

  end;
  writeln;
  writeln;

end;

procedure console_output(Date: TDate); overload;
begin

	writeln(Date.Year, '	',  Date.Month, '	', FloatToStr(Date.Day));
  writeln;

end;

{ Тестирование модулей }
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
	Matrix1, Matrix2,
  R1, R2, R3
  	: TMatrix;
  Vector: TVector;

  phi, theta, psi: MType;
begin

	result := false;  // если не выйдем из этой функции, то будем иметь false

  writeln(' * * * * * * * * test_uMatrix_Operations * * * * * * * * ');
  writeln;

	Vector := MultMatrVec(testMatrix1, StartVector);
  Matrix1 := MultMatr(testMatrix1, testMatrix2);
  Matrix2 := TranspMatr(testMatrix1);

  phi := deg2rad(30); 	// 0,523599
  theta := deg2rad(45);	// 0,785398
  psi := deg2rad(60);		// 1,0472

  R1 := MultMatr(RotMatr(1, phi), testMatrix1);
  R2 := MultMatr(RotMatr(2, theta), testMatrix1);
  R3 := MultMatr(RotMatr(3, psi), testMatrix1);

  writeln('MultMatrVec'); console_output(Vector);
  writeln('MultMatr'); console_output(Matrix1);
  writeln('TranspMatr'); console_output(Matrix2);

  writeln('RotMatr');
  writeln('R1:'); console_output(R1);
  writeln('R2:'); console_output(R2);
  writeln('R3:'); console_output(R3);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;
end;

function test_uTime: boolean;
const
	testDate: TDate = ( Year: 2001; Month: 11; Day: 13.5 );
var
	Date: TDate;
  time, delta, UT1, TT, UTC
  	: MType;
  vec: TVector;
begin

	result := false;

  writeln(' * * * * * * * * test_uTime * * * * * * * * ');
  writeln;

  time := FromDateToJD(testDate);
  writeln('FromDateToJD	', FloatToStr(time));
  writeln;

  Date := FromJDToDate(time);
  console_output(Date);

  delta := GetDeltaTAI(Date);
  writeln('GetDeltaTAI	', FloatToStr(delta));
  writeln;

  vec := GetDeltaUT(time); 	// проверить
  writeln('GetDeltaUT');
  writeln('DUT1, xp, yp:');
  console_output(vec);

  UT1 := UT1_time(time);  	// проверить
  writeln('UT1_time	', FloatToStr(UT1));
  writeln;

  TT := TT_time(time);     	// проверить
  writeln('TT_time	', FloatToStr(TT));
  writeln;

  UTC := TT2UTC(TT);
  writeln('TT2UTC	', FloatToStr(UTC));
	writeln;

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;

end;

function test_uTLE_conversation: boolean;
const
	TLE: TLE_lines =
  	('1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0  3477',
		 '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.66622191302881');
var
	TLE_output: TTLE_output;
begin

	result := false;

  writeln(' * * * * * * * * test_uTLE_conversation * * * * * * * * ');
  writeln;

  TLE_output := ReadTLE(TLE);
  writeln('TLE_output.time	', FloatToStr(TLE_output.time));
  writeln;
  writeln('a, s_e, i, b_Omega, s_omega, M0, n');
  console_output(TLE_output.Elements);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;

end;

function test_uKepler_Conversation: boolean;
begin

	result := false;

  writeln(' * * * * * * * * test_uKepler_Conversation * * * * * * * * ');
  writeln;



  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;

end;

////////////////////////////////////////////////////////////////////////////////
initialization

AllocConsole;							// создаём консольное окно
SetConsoleCP(1251);				// устанавливаем принятие кириллицы
SetConsoleOutputCP(1251);

{ Вызов тестов модулей }
test_uMatrix_Operations;
test_uTime;
test_uTLE_conversation;
test_uKepler_Conversation;

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

FreeConsole;  // убираем консоль
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
