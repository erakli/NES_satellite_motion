unit uGEO_Potential_new;

interface

{ ������ ��� ���������� ���������, ���������� ��������� ������������� � ������
  ��. ����� ������ �� ������ ��-90 }

uses
	uTypes, uConstants, uMatrix_Conversation, uMatrix_Operations, uTime, Classes,
  System.SysUtils, Math;

const
	fM: MType = 398600.44E+9; // m^3 s^-2
  ae: MType = 6378136; // m

  HARMONICS_DEC = 24; // ���������� �������������� ��������
  NUM_OF_HARMONICS = 36 - HARMONICS_DEC;

type

	harmonics = array [0 .. NUM_OF_HARMONICS, 0 .. NUM_OF_HARMONICS + 1] of MType;
  	// +1 ��� ������������� ����������� ����������� �� ������������� ������� ��������

 	TGEO_Potential_new = class(TObject)
  private

    _delta_g, // ��������������� ������ ��������� � ����������� ��
    SpherCoord // ������ ��������� ������� � ����������� (��������������) �� (���������������)
      : coordinates;

    P, _P: harmonics; // ������������� ������� �������� � �� ����������� �� ������

    { ������������� ������������ ���������� ��������������� ���������� �����
      � ��� �� ����������� �������� }
    C, S: harmonics;

    procedure Prepare_P(fi: MType);
    procedure MainStep;

    function OnFixProject(coord: coordinates): TMatrix;
  public

    function RightPart(t: MType; coord, veloc: coordinates): coordinates;

    constructor Create;
    destructor Destroy; override;

  end;

var
  GEO_Potential_new: TGEO_Potential_new;


implementation // --------------------------------------------------------------

{ TGEO_Potential }

constructor TGEO_Potential_new.Create;
const
	CS_harmonics = 'pz90_to36.ascii.txt';

var
  f: TextFile;
  n, m: byte;
  temp_text, FileName: string;

begin

  inherited;

  { ������ � ����� � ��������� � ������ ��������

    ������������ }
  FileName := file_dir + CS_harmonics;

  AssignFile(f, FileName);
  Reset(f);

  for n := 2 to NUM_OF_HARMONICS do

    for m := 0 to n do
    begin

			{
      	���� �� �����������:

        	������ ������������ �������
      }

      ReadLn(f, temp_text);
      C[n, m] := StrToFloat(Copy(temp_text, 10, 19));
      S[n, m] := StrToFloat(Copy(temp_text, 30, 19));
    end;

  CloseFile(f);

  _delta_g := NullVec;

end;

destructor TGEO_Potential_new .Destroy;
begin

  inherited;
end;


{ ���������� ��������� ���������, ��������� ������������
	� �������������� ���� ����� }

procedure TGEO_Potential_new.MainStep;
var
	n, m: byte;

  ro, fi, lambda,

  cos_m, sin_m,  // ������� ����������� �������� cos � sin �� ���
  ae_ro,         // ������� ��������� ������� (ae / ro)^n+1
  fM_ae          // ������� ����������� �������� ( fM / (ae * ro) )
  	: MType;

  sum_inner, sum_outter: TVector; // ����� �� ������ ��������� ����������� ����������

begin

	sum_inner := NullVec;
  sum_outter := NullVec;

  ro := SpherCoord[0];
  fi := SpherCoord[1];
  lambda := SpherCoord[2];

  ae_ro := sqr(ae / ro);

	for n := 2 to NUM_OF_HARMONICS do
  begin

    for m := 0 to n do
    begin

    	{ ����� ��������������
       ��������� ������ cos � sin ������� }

    	sin_m := sin( m * lambda );
      cos_m := cos( m * lambda );

			// "����������" ����� - �������� �� m
    	sum_inner[0] := sum_inner[0] + (C[n, m] * cos_m + S[n, m] * sin_m) * P[n, m];

      // ����� ��������� - �����������. � ��� ����� ����� ���� �������������� ��������� �� cos
      sum_inner[1] := sum_inner[1] + (C[n, m] * cos_m + S[n, m] * sin_m) * _P[n, m];

      sum_inner[2] := sum_inner[2] + (-C[n, m] * sin_m + S[n, m] * cos_m) * m * P[n, m];

    end;

    ae_ro := ae_ro * (ae / ro); // ������� n + 1

    // "�������" ����� - �������� �� n
    sum_outter[0] := sum_outter[0] + (n + 1) * ae_ro * sum_inner[0];

    sum_outter[1] := sum_outter[1] + ae_ro * sum_inner[1];

    sum_outter[2] := sum_outter[2] + ae_ro * sum_inner[2];

  end;

  fM_ae := fM / ( ae * ro );

  _delta_g[0] := - fM_ae * sum_outter[0];   // g_ro

  _delta_g[1] := fM_ae * sum_outter[1];     // g_fi

  _delta_g[2] := fM_ae / cos(fi) * sum_outter[2];     // g_lambda

end;


{ ���������� ������������� ������� �������� � �� ����������� �� ������ }

procedure TGEO_Potential_new.Prepare_P(fi: MType);
var
  n, m: byte;
  n2, m2: MType;

  function delta_m(m: ShortInt): real;
  begin
    result := ifthen(m = 0, 0.5, 1);
  end;

begin

	{ ������������� ������� � �������� ��� ��������?

  	����� �������������� - �� ��������� �� �� �����, � �� ������-�� ������� }

	for n := 0 to NUM_OF_HARMONICS do
  begin

    for m := 0 to n + 1 do // n + 1 - � ���������� ����������� ���� �������, ������� ���� �������� m +1 (������� ����� ������� ������ ����)
    begin

    	if n > m then
      begin
      	n2 := sqr(n);
        m2 := sqr(m);

				P[n, m] := P[n - 1, m] *
        					 sin(fi) *
                   sqrt( (4 * n2 - 1) / (n2 - m2) ) -

                   P[n - 2, m] *
                   sqrt( (( sqr(n - 1) - m2 ) * (2 * n + 1)) /
                   			 ((n2 - m2) * (2 * n - 3)) )
      end

      else
      if (n = m) AND (m <> 0) then
      	P[n, m] := P[n - 1, m - 1] *
        					 cos(fi) *
        					 sqrt( (2 * n + 1) / (2 * n) *
                   			  1 / delta_m(m - 1) )

      else
      if n < m then
      	P[n, m] := 0

      else
      if (n = m) AND (m = 0) then
      	P[n, m] := 1;

    end;

    { ����� ��������������:
    	���������� �������� delta_m = 0.5, ������ �� ������� ����� 1 �������� }
    for m := 0 to n do
      _P[n, m] := -( m * Tan(fi) * P[n, m] -

      							 sqrt(delta_m(m) * (n - m) * (n + m + 1)) *
                     P[n, m + 1] )

  end;


end;


{ ���������� ������� �������� �� ����������� ��������� � ������ ��������� }

function TGEO_Potential_new.OnFixProject(coord: coordinates): TMatrix;
var
	r_xy, // ������ � ��������� XoY
  ro,  // ��������������� ������������
  x, y, z: MType;  // ������� ���������� ������� � ��������� ��

  Msf: TMatrix; // ��������� ������� ��� ������������� �������� ���� ����. ���������� �� ��� ������ ��
begin

	x := coord[0];
  y := coord[1];
  z := coord[2];

  ro := SpherCoord[0];

	r_xy := sqrt( sqr(x) + sqr(y) );

  Msf[0, 0] := x / ro;		Msf[0, 1] := - x * z / (ro * r_xy);		Msf[0, 2] := - y / r_xy;

  Msf[1, 0] := y / ro;		Msf[1, 1] := - y * z / (ro * r_xy);		Msf[1, 2] := x / r_xy;

  Msf[2, 0] := z / ro;		Msf[2, 1] := r_xy / ro;								Msf[2, 2] := 0;

  Result := Msf;

end;


{ ��������� ������ ����� ���. ��������� }

function TGEO_Potential_new.RightPart(t: MType;
																	coord, veloc: coordinates): coordinates;
var
	FixCoord: TVector;

begin

	SpherCoord := Fix2Spher(coord);
  SpherCoord[0] := SpherCoord[0] * 1000; // ������� � ������
  Prepare_P(SpherCoord[1]);
  MainStep;

  // ������ �������������� ��������� (��������� - �� ������� ��������, �.39)
  _delta_g[0] := _delta_g[0] - fM / sqr(SpherCoord[0]);

  // ��������� ���������� ������� � ���������, � ������ ��
  FixCoord := MultMatrVec(OnFixProject(coord), _delta_g);

  // ����� ������� � �������� ������������, ������ ������������ � ��, �� ���� ��
  Result := ConstProduct(1/1000, MultMatrVec(ITRS2GCRS(t), FixCoord));

end;

end.
