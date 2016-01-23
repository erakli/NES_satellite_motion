unit uControl;

interface

{ Управляющий модуль

  Здесь идёт управление алгоритмом }

uses
  uSputnik, uKepler_conversation, uTLE_conversation, uConstants, uTime, Math,
  {uIntegrator, uAtmosphericDrag, uSunPressure, uGEO_Potential, uPrecNut,} uTypes,
  {uMatrix_conversation, uMatrix_operations,} uMatrix, uDormanPrince;

type

  TControl = class
  private
    start_time, end_time: MType;
  public
    procedure Prepare(t0, t_end: TDate; TLE: TLE_lines; coord, speed: TVector;
      mass, s, Сb_coeff, CrossSecArea: MType; lines: boolean = true);
    procedure Modeling;
  end;

var
  Control: TControl;

implementation

{ TControl }

procedure TControl.Prepare(t0, t_end: TDate; TLE: TLE_lines; coord, speed: TVector;
  mass, s, Сb_coeff, CrossSecArea: MType; lines: boolean = true);
var
  input_values: TDVector;
  i: Integer;
  TLE_output: TTLE_output;
  Kepler_Elements: TElements;
  parameters: param;
  Dubosh: boolean;
begin
	input_values := TDVector.Create(6);

	if lines then
	begin

    TLE_output := ReadTLE(TLE);
    Kepler_Elements := TLE_output.Elements;
    parameters := Kepler_to_Decart(Kepler_Elements, mass, Dubosh);

    for i := 0 to 2 do
    begin
      input_values[i] := parameters.coord[i];
      input_values[i + 3] := parameters.speed[i];
    end;

  end
  else  // lines = false
  begin

  	for i := 0 to 2 do
    begin
      input_values[i] := coord[i];
      input_values[i + 3] := speed[i];
    end;

  end; // end of if

  Sputnik := TSputnik.Create(mass, Сb_coeff, CrossSecArea, s);

  // Приводим время к UTC в модифицированных юлианских днях (JD)
  start_time := TT_time(FromDateToJD(t0));
  end_time := TT_time(FromDateToJD(t_end));

  Sputnik.t0 := start_time;
  Sputnik.t1 := end_time;

  Sputnik.setStart(@input_values);

end;

procedure TControl.Modeling;
begin

  // Доперевести все размерности в метры
  Integrator.Run(Sputnik);

  Sputnik.Destroy;

end;

end.
