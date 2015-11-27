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
  uConstants, uTypes, uFunctions,
  uMatrix_Operations, uTime, uTLE_conversation, uKepler_Conversation,
  uEpheremides_new, uPrecNut, uMatrix_Conversation,
  uAtmosphericDrag,
  uEpheremides,
  uGauss;

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

function test_uFunctions: boolean;
function test_uMatrix_Operations: boolean;
function test_uTime: boolean;
function test_uTLE_conversation: boolean;
function test_uKepler_Conversation: boolean;
function test_uEpheremides_new: boolean;
function test_uPrecNut: boolean;
function test_uMatrix_Conversation: boolean;

function test_uAtmosphericDrag: boolean;
function test_uGEO_Potential: boolean;

//var
//  i: byte;
//  a: MType;
//  r: array [0 .. 5] of MType;
//  not_load: shortint;

 // JD, Sb_coeff, dist1, dist2, interval: MType;
//  coord, v: TVector;

//  TLE: TLE_lines;
//  TLE_output: TTLE_output;

//  Kepler_Elements: TElements;
//  Dubosh: boolean;

//  Transform: TMatrix;

  // ------------------------------------------- для dll
//  Elements: tObjectElem;
//  Details: tObjectDetails;
//
//  Elliptical: EllipticalHandle;

  // функция из dll
//function EllipticalCalculate(handle: EllipticalHandle; JD: MType;
//  Elements: tObjectElem; bHighPrecision: boolean = false)
//  : tObjectDetails; stdcall;
// ------------------------------------------- /для dll

////////////////////////////////////////////////////////////////////////////////
implementation

//const
//  DLLName = 'AA.dll';

//function EllipticalCalculate; external DLLName; // реализация в другом месте

const
	TLE: TLE_lines =
  	('1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0  3477',
		 '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.66622191302881');

  JD: MType = 2453044.381; // 2004 70 day

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
function test_uFunctions: boolean;
const
  coordinates: TVector = ( 4, -7, 1 );
  angle: MType = 60;
  amin: MType = 30;
  asec: MType = 15;

  BigAngle: MType = 270;

  arg = 5;
var
  radians, module_res, pow_res: MType;
begin

	result := false;  // если не выйдем из этой функции, то будем иметь false

  writeln(' * * * * * * * * test_uFunctions * * * * * * * * ');
  writeln;

  module_res := module(coordinates);
  writeln('module ', FloatToStr(module_res));
  writeln;

  radians := deg2rad(angle);
  writeln('deg2rad ', FloatToStr(radians));
  writeln;

  radians := amin2rad(amin);
  writeln('amin2rad ', FloatToStr(radians));
  writeln;

  radians := asec2rad(asec);
  writeln('asec2rad ', FloatToStr(radians));
  writeln;

  radians := AngleNormalize(deg2rad(BigAngle));
  writeln('AngleNormalize ', FloatToStr(radians));
  writeln;

  writeln('pow2 = ', FloatToStr(pow2(arg)), '; pow3 = ', FloatToStr(pow3(arg)));
  writeln('pow4 = ', FloatToStr(pow4(arg)), '; pow5 = ', FloatToStr(pow5(arg)));
  writeln;

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;

end;

function test_uMatrix_Operations: boolean;
const
	testMatrix1: TMatrix = ((1, 2, 3),
  											  (4, 5, 6),
                          (7, 8, 9));

  testMatrix2: TMatrix = ((4, 1, 7),
  												(0, 3, 1),
                          (3, 3, 4));

  testGauss: TMatrix = ((1, 0, -1),
  											(0, 4, 5),
                        (-1, 4, 14));

  testVector1: TVector = (4, 2, 6);

  testVector2: TVector = (1, -4, 5);

  testNum: MType = 14;

var
	Matrix1, Matrix2,
  R1, R2, R3
  	: TMatrix;
  Vector1, Vector2: TVector;

  x,
  phi, theta, psi: MType;
begin

	result := false;  // если не выйдем из этой функции, то будем иметь false

  writeln(' * * * * * * * * test_uMatrix_Operations * * * * * * * * ');
  writeln;

  writeln(' ------------ Vector operations');
  writeln;

  Vector1 := ChangeRS(testVector1);
  writeln('ChangeRS'); console_output(Vector1);

  Vector2 := VecSum(testVector1, testVector2);
  writeln('VecSum'); console_output(Vector2);

  Vector2 := VecDec(testVector1, testVector2);
  writeln('VecDec'); console_output(Vector2);

  Vector1 := ConstProduct(testNum, testVector1);
  writeln('ConstProduct'); console_output(Vector1);

  x := DotProduct(testVector1, testVector2);
  writeln('DotProduct', FloatToStr(x));
  writeln;

  Vector1 := CrossProduct(testVector1, testVector2);
  writeln('CrossProduct'); console_output(Vector1);

  writeln(' ------------ Matrix operations');
  writeln;

	Vector1 := MultMatrVec(testMatrix1, testVector1);
  writeln('MultMatrVec'); console_output(Vector1);

  Matrix1 := MultMatr(testMatrix1, testMatrix2);
  writeln('MultMatr'); console_output(Matrix1);

  Matrix2 := TranspMatr(testMatrix1);
  writeln('TranspMatr'); console_output(Matrix2);


  phi := deg2rad(30); 	// 0,523599
  theta := deg2rad(45);	// 0,785398
  psi := deg2rad(60);		// 1,0472

  R1 := MultMatr(RotMatr(1, phi), testMatrix1);
  R2 := MultMatr(RotMatr(2, theta), testMatrix1);
  R3 := MultMatr(RotMatr(3, psi), testMatrix1);

  writeln('RotMatr');
  writeln('R1:'); console_output(R1);
  writeln('R2:'); console_output(R2);
  writeln('R3:'); console_output(R3);

  Matrix2 := inverse(testGauss);
  writeln('Gauss'); console_output(Matrix2);

  Matrix2 := MultMatr(Matrix2, testGauss);
  writeln('CheckGauss'); console_output(Matrix2);

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
  writeln('FromJDToDate'); console_output(Date);

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
const
  mass = 1;
var
	TLE_output: TTLE_output;
  Kepler_Elements: TElements;
  parameters: param;
  Dubosh: boolean;
begin

	result := false;

  writeln(' * * * * * * * * test_uKepler_Conversation * * * * * * * * ');
  writeln;

  TLE_output := ReadTLE(TLE);
  Kepler_Elements := TLE_output.Elements;
  parameters :=  Kepler_to_Decart(Kepler_Elements, mass, Dubosh);
  writeln('Kepler_to_Decart');
  writeln('Dubosh = ', Dubosh); writeln;
  writeln('coordinates'); console_output(parameters.coord);
  writeln('speed'); console_output(parameters.speed);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;

end;

function test_uEpheremides_new: boolean;
const
  EphType = 3; // Earth_Moon
var
  planet_coord: TVector;
  Date: TDate;
begin

  result := false;

  writeln(' * * * * * * * * test_uEpheremides_new * * * * * * * * ');
  writeln;

  Date := FromJDToDate(JD);
  writeln('FromJDToDate'); console_output(Date);


  EphCreation(EphType);
  planet_coord := Earth_Moon.Get(JD);
  writeln('Earth_Moon.Get (module = ', FloatToStr(module(planet_coord)), ')');
  console_output(planet_coord);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

	Earth_Moon.Destroy;
  result := true;

end;

function test_uPrecNut: boolean;
var
	CIP_Tranform: TCIP_Tranform_Matrix;
  Q: TMatrix;
begin

  result := false;

  writeln(' * * * * * * * * test_uPrecNut * * * * * * * * ');
  writeln;

  CIP_Tranform := TCIP_Tranform_Matrix.Create;
  Q := CIP_Tranform.getQ_Matrix((JD - J2000_Day) / JCentury);
  writeln('getQ_Matrix'); console_output(Q);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  CIP_Tranform.Destroy;
  
  result := true;

end;

function test_uMatrix_Conversation: boolean;
const
	coordinates: TVector = (-1432.9871, 6564.9368, -607.86027);
var
	UT1, TT, TT_centuries,
  ERA_angle
  	: MType;
  xpyp_vec, transformed_vec: TVector;
  R_matrix, W_matrix, transform_matrix: TMatrix;
begin

  result := false;

  writeln(' * * * * * * * * test_uMatrix_Conversation * * * * * * * * ');
  writeln;

  delta_got := false;

  xpyp_vec := GetDeltaUT(JD);
  TT := TT_time(JD);
  UT1 := UT1_time(JD);

  ERA_angle := ERA(UT1);
  writeln('ERA	', FloatToStr(ERA_angle));
  writeln;

  R_matrix := R(UT1);
  writeln('R'); console_output(R_matrix);

  TT_centuries := (TT - J2000_Day) / 36525;
  W_matrix := W(TT_centuries, xpyp_vec[1], xpyp_vec[2]);
  writeln('W'); console_output(W_matrix);

  transform_matrix := ITRS2GCRS(TT);
  writeln('ITRS2GCRS'); console_output(transform_matrix);

  transformed_vec := MultMatrVec(transform_matrix, coordinates);
  writeln('coordinates transformation'); console_output(transformed_vec);

  transformed_vec := MultMatrVec(TranspMatr(transform_matrix), transformed_vec);
  writeln('coordinates back transformation'); console_output(transformed_vec);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  result := true;

end;

{ Тест возмущений }
function test_uAtmosphericDrag: boolean;
const
  mass = 100;
  Sb_coeff = 2.2;
  A = 2;
var
	AtmospericDrag: TAtmosphericDrag;
  force: coordinates;

	TLE_output: TTLE_output;
  Kepler_Elements: TElements;
  parameters: param;
  Dubosh: boolean;
begin

	result := false;

  writeln(' * * * * * * * * test_uAtmosphericDrag * * * * * * * * ');
  writeln;

  { Временно неверно вычисляется }
  
  TLE_output := ReadTLE(TLE);
  Kepler_Elements := TLE_output.Elements;
  parameters :=  Kepler_to_Decart(Kepler_Elements, mass, Dubosh);
  
  AtmospericDrag := TAtmosphericDrag.Create;
  force := AtmospericDrag.RightPart(JD, parameters.coord, parameters.speed, Sb_coeff, A);
  writeln('AtmospericDrag.RightPart'); console_output(force);

  writeln(' * * * * * * * * done');
  writeln;
  writeln;

  AtmospericDrag.Destroy;
  
  result := true;

end;

function test_uGEO_Potential: boolean;
begin

	result := false;

  writeln(' * * * * * * * * test_uGEO_Potential * * * * * * * * ');
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
test_uFunctions;
test_uMatrix_Operations;
test_uTime;
test_uTLE_conversation;
test_uKepler_Conversation;
test_uEpheremides_new;
test_uPrecNut;
test_uMatrix_Conversation;
test_uAtmosphericDrag;

//JD := 2415284.191;

// MJD := 57258;

//interval := 0;
// интервал, на который считаются координаты. необходимо для JDEquinox

//TLE[0] := '1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0  3477';
//TLE[1] := '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.66622191302881';

//TLE_output := ReadTLE(TLE);
//MJD := TLE_output.time;
//JD := TLE_output.time;

{ a, s_e, i, b_Omega, s_omega, M, n - Кеплеровские элементы орбиты (7) }
//with Elements do
//begin
//  a := TLE_output.Elements[0];
//  e := TLE_output.Elements[1];
//  i := TLE_output.Elements[2];
//  omega := TLE_output.Elements[3];
//  w := TLE_output.Elements[4];
//  JDEquinox := JD + interval; // как я понял, на этот момент получаем координаты
//  T := JDEquinox - TLE_output.Elements[5] / TLE_output.Elements[6];
  // уточнить справедливость вычитания
//end;

//Details := EllipticalCalculate(Elliptical, JD, Elements);

//Kepler_Elements := TLE_output.Elements;
// метод из Дубошина
//coord := Kepler_to_Decart(Kepler_Elements, 0, Dubosh).coord;
//v := Kepler_to_Decart(Kepler_Elements, 0, Dubosh).speed;

//coord := Kepler_to_Decart(Kepler_Elements, 0).coord; // метод из comalg.pdf

//coord := MultMatrVec(ITRS2GCRS(TT_time(JD)), coord);

//dist1 := module(v) - 6378.1366;
//dist2 := module(coord) - 6378.1366;

readln;
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
