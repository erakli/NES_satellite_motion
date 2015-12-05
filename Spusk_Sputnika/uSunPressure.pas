unit uSunPressure;

{ ������ �������� ��������, ����������� ������.

  ��� ����� ������� ������� ����� �������� ���������, ��� ���� ������������
  ����� ������� }

interface

uses
  uConstants, uTypes, uFunctions, Math, uEpheremides_new, {uEpheremides,}
  uTime, uMatrix_Operations;

type

  { TO-DO:
    * ���������� ���������� ������� ������������ �������
    (���� ���������� ��������, ���� �������� �� ������� ��������)
    * ����� ������ ������ ������ k' � k"
  }

  TSunPressure = class(TObject)
  private

    //Sun: TSun; { ������ � ������� � ��������� ������ (.pos),
    //  ��� ���������� ���������� ��������� }

    ISZ: coordinates; // ���������� ��������

    _space, // ����������� ������� ����������� ������� ���

    cos_psi, // ��� ��������� ����
    // : coordinates;

    beta, { [����] ����� �������� ����� ��� (� ��������� ����)
      ��� ������� ��������� ��������� �����������
      ��������� ��������� ������� �� ������� }

    Earth_Sun, Sun_ISZ, // ���������� ����� ��������� � �������
    Earth_ISZ, // ���������� �� �������� �� ������ �����

    fi, // ����, �� ������� ������������ ������ � ������� ����
    psi // ����, �� ������� ������� ������� �����, ����������� ������ � �����
      : MType;

    k: array [0 .. 2] of real; { ������������:
                                  * k - ������������� �������� ���,
                                    k = 1 - �������, k = 1.44 - ���������;

                                  * k' � k", ������������ ��� ����������
                                    �������� �� ����� ���������� �� �����,
                                    0.2 <= k' <= 0.3, 0.37 <= k" <= 0.57 }

    procedure SunPressureInit(t: MType; coord: coordinates);

    { ������� ��� ����� ���������� ��� � ���� }
    function Shadow(isSunLight: boolean): byte;

    { ������������ ����, ��������� �������� �� ��� }
    function SunP: coordinates; // ���� �� ������
    function EarthP: coordinates; // ��������� ���� �� �����
  public
    function RightPart(t: MType; coord, veloc: coordinates; space: MType): coordinates;

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

  beta := deg2rad(90);

  k[0] := 1.44;
  k[1] := 0.25;
  k[2] := 0.47;
end;

destructor TSunPressure.Destroy;
begin

  inherited;
end;

procedure TSunPressure.SunPressureInit(t: MType; coord: coordinates);
var
  temp_vect: coordinates;
  scal_inc: MType; // ��� ���������� ���������� ������������
  TDB: MType; // ���������������� ������������ ����� � MJD
begin

  { ���� ������� ������� ������������� k[1] � k[2] (����) }

  TDB := TT_time(t) - (au / c) / SecInDay;
  // ��������� �������� �� ������� ��-�� ���������� ����� ������� � �����

  { ����� �������� ��� �������� ��������� ������ ������������ ����� }
  //Sun.Pos := Epheremides.GetEpheremides(TDB);
  Sun.Pos := ChangeRS(Earth_Moon.Get(TDB));

  ISZ := coord;
  Earth_ISZ := module(ISZ);
  Earth_Sun := module(Sun.Pos);

  { ����� ������� ��������� ����� ������������ ������ �
    ��������� ��� ������������ �����
    ���� ������ ��������� ��� ������������ ������ }
  temp_vect := VecSum(ChangeRS(Sun.pos), ISZ);

  Sun_ISZ := module(temp_vect); // ������ ������� ��������� ��� ������������ ������

  { ����������� ��� ���������� ������������ ��������, �������� � ���������� �� }
  scal_inc := DotProduct(ISZ, Sun.pos); // �� ���������� ������������

  cos_psi := -scal_inc / (Earth_ISZ * Earth_Sun);

  psi := arccos(cos_psi);

  { ����� ���������� ������ ��, ��� ��� ����������� ������ � ������� �������,
    �� ���� �������, ��� Sun_ISZ > Earth_Sun }
  fi := arcsin(Earth.eq_rad / Earth_ISZ);

end;

function TSunPressure.Shadow(isSunLight: boolean): byte;
begin

  result := 1;

  { ����� �� ����� ������� �� ��, ��� ���� �� ��������� � ������� �������,
    �� �� ��������� ������� �������, ����� � �� ��������� }
  if Earth_Sun < Sun_ISZ then

    if isSunLight then
    begin
      if abs(psi) <= abs(fi) then
        result := 0
    end

    else
    // ����� ���� ��������� ���� ��������, ��� ��� � ������ �� ������������ �������� �� ��������
    if cos(psi) > cos(beta) then
      result := 0;

end;

{ �������� �� ������� ������ }
function TSunPressure.SunP: coordinates;
var
  temp_part: MType;
begin

  temp_part := k[0] *
               Sun.q *
               _space *
               Shadow(true) *
               sqr(Earth.big_a / Sun_ISZ);

  result := ConstProduct( temp_part / Sun_ISZ, VecDec(Sun.pos, ISZ) );

end;


{ ��������� ���� �� ����� }
function TSunPressure.EarthP: coordinates;
var
  temp_part: MType;
begin

  temp_part := Sun.q *
               _space *
               (Earth.big_a / Sun_ISZ) *
               (Earth.eq_rad / Earth_ISZ) *
               (  k[1] * sqr(cos(fi)) +
                  k[2] * Shadow(false) * sin(beta - psi) );

  result := ConstProduct(temp_part / Earth_ISZ, ISZ);

end;

function TSunPressure.RightPart(t: MType; coord, veloc: coordinates; space: MType)
  : coordinates;
var
  temp: array [0 .. 1] of coordinates;
begin

   _space := space; // �������������� ������� ����������� ������� ���

  SunPressureInit(t, coord);

  temp[0] := SunP;
  temp[1] := EarthP;

  result := VecSum(temp[0], temp[1]);

end;

end.
