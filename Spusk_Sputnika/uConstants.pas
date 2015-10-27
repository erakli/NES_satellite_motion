unit uConstants;

interface

uses
  System.SysUtils;

const
  fm = 3.986004418E+5; // [km] �������������� ����������
  m_size = 2; // ������ ������

  au = 1.49597870700E+8; // [km] Astronomical unit - ��������������� �������
  c = 299792.458; // [km/s] �������� �����

  SecInDay = 86400; // ������ � ���

  MJDCorrection = 2400000.5; // �������� �� JD

  // // ��� ���������� ���������
  // Earth_eq_rad = 6378.14; // [km] �������������� ������ �����
  // Earth_alpha_0 = 0.0033528131778969; // 1 / 298.257 - ������ �����

  // // ��� ��������
  // Num_of_harm = 70;
  // CS_harmonics = 'CS.txt';

  deletimer = '	';

  asecInTurn = 360 * 60 * 60;

type

  TMatrix = array [0 .. m_size, 0 .. m_size] of double;
  TVector = array [0 .. m_size] of double;

  TMassive = record
    x, y, z: TMatrix;
  end;

  coordinates = record
    x, y, z: double;
  end;

  { ��������� ����� }
  TEarth = record
    eq_rad, // [km] �������������� ������ �����
    alpha_0, // ������ �����
    omega, // [���/�] ������� �������� �������� �����
    density_120, // [��/�^3] ��������� ������ ��������� �� ������ 120 ��
    big_a { [��] ������� ������� ������ �����,
      �������� 1 ��������������� �������� }
      : double;
  end;

  { ��������� ������ }
  TSun = record
    alpha, // ������ �����������
    beta, // � ��������� ������
    q { ��������� ���������� (��� �������� �����),
      q = 4.65e+5 [���/��^2] }
      : double;
    pos: coordinates; // ��������� � ��������������� ��
  end;

  // coord_diff = record
  // x, y, z: double;
  // end;

  param = record // ���������� ��� �������������� ������������ ���������
    coord, speed: TVector;
  end;

  { a, s_e, i, b_Omega, s_omega, M0, n - ������������ �������� ������ (7) }
  TElements = array [0 .. 6] of double;

  TLE_lines = array [0 .. 1] of string;

  output = record // ���������� ��� TLE ������ - ����� ������� ReadTLE
    time: double; // � MJD
    Elements: TElements;
  end;

  // procedure Get_Harmonics(FileName: string);

const
  ResetCoord: coordinates = (x: 0; y: 0; z: 0);

var
  // harmonics : array [0 .. Num_of_harm - 1, 0 .. 1] of double;
  Earth: TEarth;
  Sun: TSun;
  file_dir: string;

  CurYear: shortint;
  Third: double;

  _P, _N: TMatrix; { ������� ��������� � �������. ����� ��� ���������, ����
    ��� ����������� � TDB (TT). ����� ��� ���������� � uControl � ����������� �
    uMatrix_conversation }

implementation

// procedure Get_Harmonics(FileName: string);
// var
// f: TextFile;
// i: integer;
// temp_text: string;
// begin
//
// AssignFile(f, FileName);
// Reset(f);
// for i := 0 to Num_of_harm - 1 do
// begin
// ReadLn(f, temp_text);
// harmonics[i, 0] :=
// StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1));
// harmonics[i, 1] := StrToFloat(Copy(temp_text, pos(deletimer, temp_text) + 1,
// length(temp_text)));
// end;
// CloseFile(f);
//
// end;

initialization

{ ���� � ����� � ����������. ����� ��� �������� ������ �  ��������������,
  ������� ������ ������ ����� � ���. }
file_dir := ExtractFileDir(ParamStr(0)) + '\';

with Earth do
begin
  eq_rad := 6378.1366;
  alpha_0 := 1 / 298.25642;
  omega := 7.292115E-5;
  density_120 := 1.58868E-8;
  // big_a := 149.597868E+6;
  big_a := au;
end;

with Sun do
begin
  q := 4.65E+5;
end;

CurYear := 15;
Third := 1 / 3;

// Get_Harmonics(file_dir + CS_harmonics);

end.
