unit uControl;

interface

{ ����������� ������

  ����� ��� ���������� ���������� }

uses
  uSputnik, uKepler_conversation, uTLE_conversation, uConstants, uTime, Math,
  {uIntegrator, uAtmosphericDrag, uSunPressure, uGEO_Potential, uPrecNut,} uTypes,
  {uMatrix_conversation, uMatrix_operations,} uMatrix, uDormanPrince;

type

  TControl = class
  private
    start_time, end_time: MType;
  public
    procedure Prepare(t0, t_end: TDate; step: MType; TLE: TLE_lines;
      mass, s, �b_coeff, CrossSecArea: MType; lines: boolean = true);
    procedure Modeling;
  end;

var
  Control: TControl;

implementation

{ TControl }

procedure TControl.Prepare(t0, t_end: TDate; step: MType; TLE: TLE_lines;
  mass, s, �b_coeff, CrossSecArea: MType; lines: boolean = true);
var
  input_values: TDVector;
  i: Integer;
  TLE_output: TTLE_output;
  Kepler_Elements: TElements;
  parameters: param;
  Dubosh: boolean;
begin
  TLE_output := ReadTLE(TLE);
  Kepler_Elements := TLE_output.Elements;
  parameters := Kepler_to_Decart(Kepler_Elements, mass, Dubosh);

  input_values := TDVector.Create(6);

  for i := 0 to 2 do
  begin
    input_values[i] := parameters.coord[i];
    input_values[i + 3] := parameters.speed[i];
  end;

  Sputnik := TSputnik.Create(mass, �b_coeff, CrossSecArea, s);

  // �������� ����� � UTC � ���������������� ��������� ���� (JD)
  start_time := TT_time(FromDateToJD(t0));
  end_time := TT_time(FromDateToJD(t_end));

  Sputnik.t0 := start_time;
  Sputnik.t1 := end_time;

  Sputnik.setStart(@input_values);

end;

procedure TControl.Modeling;
begin

  Integrator.Run(Sputnik);

  Sputnik.Destroy;

end;

end.
