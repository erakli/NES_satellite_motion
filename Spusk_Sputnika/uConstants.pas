unit uConstants;

interface

uses
  System.SysUtils, uTypes;

const

	PI2: MType = 2 * Pi;

  fm: MType = 3.986004418E+14; // [m] �������������� ����������
  // m_size = 2; // ������ ������

  au: MType = 1.49597870700E+11; // [m] Astronomical unit - ��������������� �������
  c: MType = 299792458; // [m/s] �������� �����

  SecInDay = 86400; // ������ � ���

  MJDCorrection: MType = 2400000.5; // �������� �� JD
  J2000_Day: MType = 2451545.0; // 2000 January 1.5 TT
  JCentury = 36525; // ���� � ��������� ��������

  deletimer = '	';

  asecInTurn = 360 * 60 * 60;
  MICRO: MType = 1.0E-6;

  NullVec: TVector = (0, 0, 0);
  NullMatr: TMatrix = ((0, 0, 0), (0, 0, 0), (0, 0, 0));

var
  Earth: TEarth;
  file_dir: string;

  CurYear: shortint;
  Third: MType;

  _P, _N: TMatrix; { ������� ��������� � �������. ����� ��� ���������, ����
    ��� ����������� � TDB (TT). ����� ��� ���������� � uControl � ����������� �
    uMatrix_conversation }

implementation

initialization

{ ���� � ����� � ����������. ����� ��� �������� ������ �  ��������������,
  ������� ������ ������ ����� � ���. }
file_dir := ExtractFileDir(ParamStr(0)) + '\';

with Earth do
begin
  eq_rad := 6378136.6;
  alpha_0 := 1 / 298.25642;
  omega := 7.292115E-5;
  density_120 := 1.58868E-8;
  // big_a := 149.597868E+6;
  big_a := au;
end;

CurYear := 15;
Third := 1 / 3;

end.
