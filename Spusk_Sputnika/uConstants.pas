unit uConstants;

interface

uses
  System.SysUtils, uTypes;

const
  fm = 3.986004418E+5; // [km] �������������� ����������
//  m_size = 2; // ������ ������

  au = 1.49597870700E+8; // [km] Astronomical unit - ��������������� �������
  c = 299792.458; // [km/s] �������� �����

  SecInDay = 86400; // ������ � ���

  MJDCorrection = 2400000.5; // �������� �� JD
  J2000_Day = 2451545.0; // 2000 January 1.5 TT

  deletimer = '	';

  asecInTurn = 360 * 60 * 60;
  MICRO = 1.0e-6;

const
  ResetCoord: coordinates = (x: 0; y: 0; z: 0);

var
  Earth: TEarth;
  Sun: TSun;
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


end.
