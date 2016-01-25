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

uses UI_unit, SysUtils;

{ TControl }

procedure TControl.Prepare(t0, t_end: TDate; TLE: TLE_lines; coord, speed: TVector;
  mass, s, Сb_coeff, CrossSecArea: MType; lines: boolean = true);
var
  input_values: TDVector;
  i: Integer;
  TLE_output: TTLE_output;
  Kepler_Elements: TElements;
  parameters: param;
  Dubosh, sameParam: boolean;

  ADDinitParam, coordAndSpeed, ADDcoordAndSpeed, ADDmodelling, s2: string;
begin
	input_values := TDVector.Create(6);

  // проверка на идентичность входных параметров уже заданным
  sameParam := false;

  if (Sputnik.mass = mass) AND (Sputnik.Cb_coeff = Сb_coeff)
  		AND (Sputnik.CrossSecArea = CrossSecArea) AND (Sputnik._space = s)
      AND  (Sputnik.t0 = TT_time(FromDateToJD(t0)))
      AND (Sputnik.t1 = TT_time(FromDateToJD(t_end))) then
  begin

  	for i := 0 to 2 do
    begin
      sameParam := sameParam AND (input_values[i] = parameters.coord[i])
      		AND (input_values[i + 3] = parameters.speed[i] * SecInDay);
    end;

  end;


	if lines then
	begin

    TLE_output := ReadTLE(TLE);
    Kepler_Elements := TLE_output.Elements;
    parameters := Kepler_to_Decart(Kepler_Elements, mass, Dubosh);

    for i := 0 to 2 do
    begin
      input_values[i] := parameters.coord[i];
      input_values[i + 3] := parameters.speed[i] * SecInDay; // домножаем, так как единица времени - Юлианский день
    end;

  end
  else  // lines = false
  begin

  	for i := 0 to 2 do
    begin
      input_values[i] := coord[i];
      input_values[i + 3] := speed[i] * SecInDay;
    end;

  end; // end of if

  Sputnik.mass := mass;
  Sputnik.Cb_coeff := Сb_coeff;
  Sputnik.CrossSecArea := CrossSecArea;
  Sputnik._space := s;
//  Sputnik := TSputnik.Create(mass, Сb_coeff, CrossSecArea, s);

  // Приводим время к UTC в модифицированных юлианских днях (JD)
  start_time := TT_time(FromDateToJD(t0));
  end_time := TT_time(FromDateToJD(t_end));

  Sputnik.t0 := start_time;
  Sputnik.t1 := end_time;

  Sputnik.setStart(@input_values);

  Sputnik.CreateResult;

  // работа с БД
  with Main_Window.ADOQuery1 do
  begin
    SQL.Clear;
    ADDcoordAndSpeed :=
    			'INSERT into [Coordinates and Speed](X, Y, Z, Vx, Vy, Vz) values('
            + FloatToStr(input_values[0]) + ' , ' + FloatToStr(input_values[1]) + ', ' + FloatToStr(input_values[2]) + ', '
            + FloatToStr(input_values[3] / SecsPerDay) + ', '
            + FloatToStr(input_values[4] / SecsPerDay) + ', '
            + FloatToStr(input_values[5] / SecsPerDay)  + ') ';

    SQL.Add(ADDcoordAndSpeed);
    SQL.Add('SELECT scope_identity() FROM [Coordinates and Speed]');
    Open;
    coordAndSpeed := Fields[0].AsString;

    if NOT sameParam then
    begin
      SQL.Clear;
      ADDinitParam :=
            'INSERT into [Initial Parametrs](t0, t_end, mass, Cb_coeff, space, CrossSecArea, CoordinatesAndSpeed) values('
              + FloatToStr(start_time) + ' , ' + FloatToStr(end_time) + ', ' + FloatToStr(mass) + ', '
              + FloatToStr(Сb_coeff) + ', ' + FloatToStr(s) + ', ' + FloatToStr(CrossSecArea) + ', '
              + coordAndSpeed + ') ';

      SQL.Add(ADDinitParam);
      SQL.Add('SELECT scope_identity() FROM [Initial Parametrs]');
      Open;
      Sputnik.initParam := Fields[0].AsString;
    end;

    SQL.Clear;
    ADDmodelling :=
    			'INSERT into Modelling(InitParametrs) values(' + Sputnik.initParam + ') ';

    SQL.Add(ADDmodelling);
    SQL.Add('SELECT scope_identity() FROM [Initial Parametrs]');
    Open;
    Sputnik.modellingNum := Fields[0].AsString;
  end;

end;

procedure TControl.Modeling;
begin

  // Доперевести все размерности в метры
  Integrator.Run(Sputnik);

  Sputnik.CloseResult;

//  Sputnik.Destroy;

end;

end.
