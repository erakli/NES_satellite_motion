unit uTypes;

{ � ������ ������ ������� ������������ ���� }

interface

const

  m_size = 2; // ������ ������

type

  MType = double;

  TMatrix = array [0 .. m_size, 0 .. m_size] of MType;
  TVector = array [0 .. m_size] of MType;

  TMassive = record
    x, y, z: TMatrix;
  end;

//  coordinates = record
//    x, y, z: MType;
//  end;

	coordinates = TVector;

  { ��������� ����� }
  TEarth = record
    eq_rad, // [km] �������������� ������ �����
    alpha_0, // ������ �����
    omega, // [���/�] ������� �������� �������� �����
    density_120, // [��/�^3] ��������� ������ ��������� �� ������ 120 ��
    big_a { [��] ������� ������� ������ �����,
      �������� 1 ��������������� �������� }
      : MType;
  end;

  { ��������� ������ }
  TSun = class(TObject)
  private
    _alpha, // ������ ����������� (���)
    _beta,  // � ��������� ������ (���)
    _q { ��������� ���������� (��� �������� �����),
      	 q = 4.65e+5 [���/��^2] }
      : MType;
    _pos: coordinates; // ��������� � ��������������� ��

    procedure SetPos(cur_pos: coordinates);

  public
  	property alpha: MType read _alpha;
    property beta: MType read _beta;
    property q: MType read _q;
    property pos: coordinates read _pos write SetPos;

    procedure SetParams(JD: MType);

    constructor Create;
  end;

  // coord_diff = record
  // x, y, z: MType;
  // end;

  param = record // ���������� ��� �������������� ������������ ���������
    coord, speed: TVector;
  end;

  { a, s_e, i, b_Omega, s_omega, M0, n - ������������ �������� ������ (7) }
  TElements = array [0 .. 6] of MType;

  TLE_lines = array [0 .. 1] of string;

  TTLE_output = record // ���������� ��� TLE ������ - ����� ������� ReadTLE
    time: MType; // � JD
    Elements: TElements;
  end;

implementation

uses
	uTime, uFunctions;

const
	DegInDay: MType = 360 / 365; // ���-�� ��������, ������� � ������� �������� ����� � ���� (!�������!)


{ TSun }

constructor TSun.Create;
begin
	inherited;

  _q := 4.65E+5;
end;

procedure TSun.SetPos(cur_pos: coordinates);
begin
  pos := cur_pos;
end;

procedure TSun.SetParams(JD: MType);
var
	Days: word; // ���� � ������ ����
begin

	{ !������ ��������! }

	Days := DayNumber(JD);
  _alpha := Days * DegInDay;
  _alpha := deg2rad(_alpha);

  _beta := deg2rad(23.45) * sin( deg2rad(DegInDay * (Days - 81)) );

end;

end.
