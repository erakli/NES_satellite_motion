unit uControl;

interface

{ ����������� ������

  ����� ��� ���������� ���������� }

uses
  uSputnik, uKepler_conversation, uTLE_conversation, uConstants, uTime, Math,
  uIntegrator, uAtmosphericDrag, uSunPressure, uGEO_Potential, uPrecNut, uTypes,
  uMatrix_conversation, uMatrix_operations;

const
  log_file = 'log.txt';

type

  { TO-DO:
    * ��������� ���������� ������ ������� � ��������� � ���� ������ - ���� ���
    �� ��� ������� - ok
    * �������� ������������ ��������
    * ������� ����� � ���� ������������� �����������
    * ����������, ����� ������� ���������� �������������� }

  TControl = class
  private
    start_time, end_time, // ����� ������ � ����� ���������
    cur_time, Ever_step: MType;
  public
    procedure Prepare(t0, t_end: TDate; step: MType; TLE: TLE_lines;
      mass, s, Sb_coeff: MType; lines: boolean = true);
    procedure Modeling;
  end;

var
  Control: TControl;

implementation

{ TControl }

procedure TControl.Prepare(t0, t_end: TDate; step: MType; TLE: TLE_lines;
  mass, s, Sb_coeff: MType; lines: boolean = true);
var
  TDB: MType;
  Elements: TElements;
  // Mpc // ������� ��������: �� �������� �������������� � ��������
  // : TMatrix;
  temp_param: param;
begin

  // �������� ����� � UTC � ���������������� ��������� ���� (JD)
  start_time := FromDateToJD(t0);
  cur_time := start_time;
  end_time := FromDateToJD(t_end);

  Ever_step := step; // ��� � �������� ��� JD?

  // ������ TLE
  if lines then
  begin
    Elements := ReadTLE(TLE).Elements;
    // Elements[0] := Elements[0] * Power(mass, Third); // �������� �����������
  end;

  TDB := TT_time(cur_time);
  // _P := ClcPrecMatr(cur_time);
  // _N := ClcNutMatr(cur_time);

  // Mpc := FromTrueToFixM(start_time); // ��������� ������� �������� � �������� ��
  // Mpc := FromTerraToFixM(start_time);  // ������� �� ������

  temp_param := Kepler_to_Decart(Elements, mass);
  // �������� ������ ��������� � �������� �������������� ��

  // �������������� �������
  with Sputnik do
  begin
    // state.coord := MultMatrVec(Mpc, temp_param.coord);
    // state.speed := MultMatrVec(Mpc, temp_param.speed);
    state.coord := temp_param.coord;
    state.speed := temp_param.speed;
    _space := s;
  end;
  Sputnik.mass := mass;
  Sputnik.Sb_coeff := Sb_coeff;

end;

procedure TControl.Modeling;
var
  TDB: MType;
  _coord, _speed: coordinates;
  temp_force, Force: TResult;
  f: textfile;
  i: byte;

  function CoordSum(one, two: coordinates): coordinates;
  begin
    result.x := one.x + two.x;
    result.y := one.y + two.y;
    result.z := one.z + two.z;
  end;

begin

  Assign(f, log_file);
  ReWrite(f);

  while cur_time < end_time do
  begin

    Force.x := ResetCoord;
    Force.dif_x := ResetCoord;

    with Sputnik.state do
    begin

      with _coord do
      begin
        x := coord[0];
        y := coord[1];
        z := coord[2];
      end;

      with _speed do
      begin
        x := speed[0];
        y := speed[1];
        z := speed[2];
      end;

    end;

    with Everhart do
    begin
      Force := Integrate(cur_time, _coord, _speed, Ever_step,
        GEO_potential.RightPart);
      // temp_force := Integrate(cur_time, _coord, _speed, Ever_step,
      // AtmosphericDrag.RightPart);

      Force.x := CoordSum(Force.x, temp_force.x);
      Force.dif_x := CoordSum(Force.dif_x, temp_force.dif_x);

      temp_force := Integrate(cur_time, _coord, _speed, Ever_step,
        SunPressure.RightPart);

      Force.x := CoordSum(Force.x, temp_force.x);
      Force.dif_x := CoordSum(Force.dif_x, temp_force.dif_x);
    end;

    with Sputnik.state do
    begin

      coord[0] := Force.x.x;
      coord[1] := Force.x.y;
      coord[2] := Force.x.z;

      speed[0] := Force.dif_x.x;
      speed[1] := Force.dif_x.y;
      speed[2] := Force.dif_x.z;

      writeln(f, 'Current time = ', cur_time:5:6);
      for i := 0 to 2 do
        writeln(f, deletimer, coord[i], deletimer, speed[i]);

    end;

    cur_time := cur_time + Ever_step;

    TDB := TT_time(cur_time);
    // ������� � ����� �����, ��� ��� � ������ ��� ��������� � Prepare
    // _P := ClcPrecMatr(TDB);
    // // ��������� ������� ������� � ���������. �� ������ ���
    // _N := ClcNutMatr(TDB);

  end;

  Close(f);

end;

end.
