unit uSunPressure;

{ ������ �������� ��������, ����������� ������.

  ��� ����� ������� ������� ����� �������� ���������, ��� ���� ������������
  ����� ������� }

interface

uses
  uConstants, uFunctions, Math, uEpheremides, uTime, uSputnik;

type

  { TO-DO:
    * ���������� ���������� ������� ������������ �������
    (���� ���������� ��������, ���� �������� �� ������� ��������)
    * ����� ������ ������ ������ k' � k"
  }

  TSunPressure = class
  private

    Sun: TSun; { ������ � ������� � ��������� ������ (.pos),
      ��� ���������� ���������� ��������� }

    ISZ: coordinates; // ���������� ��������

    cos_psi // ��� ��������� ����
    // : coordinates;
      : double;

    beta, { [����] ����� �������� ����� ��� (� ��������� ����)
      ��� ������� ��������� ��������� �����������
      ��������� ��������� ������� �� ������� }

    Earth_Sun, Sun_ISZ, // ���������� ����� ��������� � �������
    Earth_ISZ, // ���������� �� �������� �� ������ �����
    fi, // ����, �� ������� ������������ ������ � ������� ����
    psi { ��� ����, ������ ����� ��������, �� ������� �������
      ������� �����, ����������� ������ � ����� }
      : double;

    k: array [0 .. 2] of real; { ������������:
      * k - ������������� �������� ���,
      k = 1 - �������, k = 1.44 - ���������;
      * k' � k", ������������ ��� ����������
      �������� �� ����� ���������� �� �����,
      0.2 <= k' <= 0.3, 0.37 <= k" <= 0.57 }

    procedure SunPressureInit(t: double; coord: coordinates);

    { ������� ��� ����� ���������� ��� � ���� }
    function Shadow(psi: double; isSunLight: boolean): byte;

    { ������������ ����, ��������� �������� �� ��� }
    function SunP: coordinates; // ���� �� ������
    function EarthP: coordinates; // ��������� ���� �� �����
  public
    function RightPart(t: double; coord, veloc: coordinates): coordinates;

    constructor Create;
    destructor Destroy; override;
  end;

var
  SunPressure: TSunPressure;

implementation
// ---------------------------------------------------------------

{ TSunPressure }

constructor TSunPressure.Create;
begin
  inherited;

  beta := 90;
  k[0] := 1.44;
  k[1] := 0.25;
  k[2] := 0.47;
end;

destructor TSunPressure.Destroy;
begin

  inherited;
end;

procedure TSunPressure.SunPressureInit(t: double; coord: coordinates);
var
  temp_vect: coordinates;
  scal_inc: double; // ��� ���������� ���������� ������������
  TDB: double; // ���������������� ������������ ����� � MJD
begin

  { ���� ������� ������� ������������� k[1] � k[2] (����) }

  TDB := TT_time(t) - (au / c) / SecInDay;
  // ��������� �������� �� ������� ��-�� ���������� ����� ������� � �����

  { ����� �������� ��� �������� ��������� ������ ������������ �����,
    �������� ������� }
  Sun.Pos := Epheremides.GetEpheremides(TDB);

  ISZ := coord;
  Earth_ISZ := module(ISZ);
  Earth_Sun := module(Sun.Pos);

  { � ��������� ��������� ���������� ���������� ���������� �� ������ �� ���.

    ����� ������ �������� �������� ��� �������� �� ���, ����������� ������
    ������ � �����.

    ��� ����� ���������� ������, ����� ������� ��������� ��� ����������,
    �� ����� ���� ������ ������ �������� ������� �� ������ ������� ������.

    ������ }
  with Sun do // �� ���������� ������������
    { ����������� ��� ���������� ������������ ��������, �������� � ����������
      �� }
    scal_inc := ISZ.x * Pos.x + ISZ.y * Pos.y + ISZ.z * Pos.z;

  cos_psi := -scal_inc / (Earth_ISZ * Earth_Sun);

  psi := arccos(cos_psi);

  { ��� �� �������� ������ ���������� �� ������ �� ��������.

    ���������� �������� ������������ ���������� ���������� ����� ������� �
    ��������� }
  with temp_vect, Sun do
  begin
    x := Pos.x - ISZ.x;
    y := Pos.y - ISZ.y;
    z := Pos.z - ISZ.z;
  end;

  Sun_ISZ := module(temp_vect);
  // Sun_ISZ := Earth_Sun;  { ��������� ���������� �� ������ ��
  // �������� ������ 1 ����. ��. }

  { ����� ���������� ������ ��, ��� ��� ����������� ������ � ������� �������,
    �� ���� �������, ��� Sun_ISZ > Earth_Sun }
  fi := arcsin(Earth.eq_rad / Earth_ISZ);

end;

function TSunPressure.Shadow(psi: double; isSunLight: boolean): byte;
begin

  result := 0;

  { ����� �� ����� ������� �� ��, ��� ���� �� ��������� � ������� �������,
    �� �� ��������� ������� �������, ����� � �� ��������� }
  if Earth_Sun < Sun_ISZ then
    if isSunLight then
      if psi > abs(fi) then
        result := 1
      else if cos(psi) >= cos(beta) then
        result := 1;

end;

function TSunPressure.SunP: coordinates;
var
  temp_part: double;
begin

  temp_part := k[0] * Sun.q * Sputnik._space * Shadow(psi, true) *
    sqr(Earth.big_a / Sun_ISZ);

  with result, Sun do
  begin
    x := temp_part * (Pos.x - ISZ.x) / Sun_ISZ;
    y := temp_part * (Pos.y - ISZ.y) / Sun_ISZ;
    z := temp_part * (Pos.z - ISZ.z) / Sun_ISZ;
  end;

end;

function TSunPressure.EarthP: coordinates;
var
  temp_part: double;
begin

  temp_part := Sun.q * Sputnik._space * (Earth.big_a / Sun_ISZ) *
    (Earth.eq_rad / Earth_ISZ) * (k[1] * sqr(cos(fi)) + k[2] * Shadow(psi,
    false) * sin(beta - psi));

  with result do
  begin
    x := temp_part * ISZ.x / Earth_ISZ;
    y := temp_part * ISZ.y / Earth_ISZ;
    z := temp_part * ISZ.z / Earth_ISZ;
  end;

end;

function TSunPressure.RightPart(t: double; coord, veloc: coordinates)
  : coordinates;
var
  temp: array [0 .. 1] of coordinates;
begin

  // _space := s; // �������������� ������� ����������� ������� ���

  SunPressureInit(t, coord);

  temp[0] := SunP;
  temp[1] := EarthP;

  with result do
  begin
    x := temp[0].x + temp[1].x;
    y := temp[0].y + temp[1].y;
    z := temp[0].z + temp[1].z;
  end;

end;

end.
