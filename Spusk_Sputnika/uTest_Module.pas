unit uTest_Module;

{
	TO-DO:
  	* ������ ����� ����������� TLE � ����������� �������� �� �� ���������
    (����� ������� �� ��������). �� �����, ��� ����� �������� �������������
    ����� ����� ��������� TLE

    * �� ������ ������� ������� ����������������� ��������� � ��� (������� �����
    ������� �� DLL). ��� 4 �������� ������� elements ������� ���������������
    ���������� ������� � AU - ��� ���� ���������.

    * ����������� � JDEquinox
}

interface

uses
  uConstants, uEpheremides, Dialogs, System.SysUtils, uAtmosphericDrag,
  uKepler_Conversation, uFunctions, uTLE_conversation;

type
// ------------------------------------------- ��� dll
	EllipticalHandle = THandle;

  tObjectElem = record
  	a, e, i, w, omega, JDEquinox, T: double;
  end;

  tObjectDetails = record
  	CoordinateEquatorial, CoordinateEcliptical: TVector;
    elments: array[0..11] of double;
  end;

const
	ElemInit: array[0..6] of double =
  	(2.2091404, 0.8502196, 11.94524, 334.75006, 186.23352, 2448192.5 + 0.54502, 2451544.5); // ��� ������� �� AA
{
	a := ElemInit[0];
  e := ElemInit[1];
  i := ElemInit[2];
  omega := ElemInit[3];
  w := ElemInit[4];
  T := ElemInit[5];
  JDEquinox := ElemInit[6];
}
// ------------------------------------------- /��� dll

var
  i: byte;
  a: double;
  r: array [0 .. 5] of double;
  not_load: shortint;

  JD, MJD, Sb_coeff, dist1, dist2, interval: double;
  coord, v: TVector;

  TLE: TLE_lines;
  TLE_output: output;

  Kepler_Elements: TElements;
  Dubosh: boolean;

// ------------------------------------------- ��� dll
  Elements: tObjectElem;
  Details: tObjectDetails;

  Elliptical: EllipticalHandle;

// ������� �� dll
function EllipticalCalculate(handle: EllipticalHandle; JD: double;
	elements: tObjectElem; bHighPrecision: boolean = false): tObjectDetails; stdcall;
// ------------------------------------------- /��� dll

////////////////////////////////////////////////////////////////////////////////
implementation

const
	DLLName = 'AA.dll';

function EllipticalCalculate; external DLLName; // ���������� � ������ �����

////////////////////////////////////////////////////////////////////////////////
initialization

//MJD := 57258;


interval := 0; // ��������, �� ������� ��������� ����������. ���������� ��� JDEquinox

TLE[0] := '1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0  3477';
TLE[1] := '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.66622191302881';

TLE_output := ReadTLE(TLE);
MJD := TLE_output.time;
JD := TLE_output.time + MJDCorrection;

{ a, s_e, i, b_Omega, s_omega, M, n - ������������ �������� ������ (7) }
with Elements do
begin
	a := TLE_output.Elements[0];
  e := TLE_output.Elements[1];
  i := TLE_output.Elements[2];
  omega := TLE_output.Elements[3];
  w := TLE_output.Elements[4];
  JDEquinox := JD + interval;   // ��� � �����, �� ���� ������ �������� ����������
  T := JDEquinox - TLE_output.Elements[5] / TLE_output.Elements[6]; // �������� �������������� ���������
end;

Details := EllipticalCalculate(Elliptical, JD, Elements);

Kepler_Elements := TLE_output.Elements;
coord := Kepler_to_Decart(Kepler_Elements, 0, Dubosh).coord; // ����� �� ��������
v := Kepler_to_Decart(Kepler_Elements, 0).coord; // ����� �� comalg.pdf

dist1 := module(v) - 6378.1366;
dist2 := module(coord) - 6378.1366;

{ //---------------------------------------- ��� ������ �� �������� AA (�. 232)
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

Details := EllipticalCalculate(Elliptical, Jd, Elements); // ��������� ��������������� ������� ��������

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

//for i := 0 to 5 do Elements[i] := ElemInit[i];
//
//coord := Kepler_to_Decart(Elements, 0).coord;


// AtmosphericDrag.RightPart(MJD, coord, v, Sb_coeff);  // ���������� ���������

// a := 2457198.5;
// not_load := 0;

end.
