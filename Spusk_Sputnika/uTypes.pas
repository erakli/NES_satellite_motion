unit uTypes;

{ � ������ ������ ������� ������������ ���� }

interface

const

  m_size = 2; // ������ ������

type

  MType = extended;

  TMatrix = array [0 .. m_size, 0 .. m_size] of MType;
  TVector = array [0 .. m_size] of MType;

  TMassive = record
    x, y, z: TMatrix;
  end;

  coordinates = record
    x, y, z: MType;
  end;

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
  TSun = record
    alpha, // ������ �����������
    beta, // � ��������� ������
    q { ��������� ���������� (��� �������� �����),
      q = 4.65e+5 [���/��^2] }
      : MType;
    pos: coordinates; // ��������� � ��������������� ��
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

  output = record // ���������� ��� TLE ������ - ����� ������� ReadTLE
    time: MType; // � JD
    Elements: TElements;
  end;

implementation

end.
