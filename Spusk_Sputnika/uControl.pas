unit uControl;

interface

{ Управляющий модуль

  Здесь идёт управление алгоритмом }

uses
  uSputnik, uKepler_conversation, uTLE_conversation, uConstants, uTime, Math,
  uIntegrator, uAtmosphericDrag, uSunPressure, uGEO_Potential, uPrecNut, uTypes,
  uMatrix_conversation, uMatrix_operations;

const
  log_file = 'log.txt';

type

  { TO-DO:
    * Перенести вычисление матриц нутации и прецессии в этот модуль - один раз
    на шаг времени - ok
    * Написать моделирующий алгоритм
    * Сделать вывод в файл промежуточных результатов
    * Определить, каким образом происходит интегрирование }

  TControl = class
  private
    start_time, end_time, // время начала и конца алгоритма
    cur_time, Ever_step: MType;
  public
    procedure Prepare(t0, t_end: TDate; step: MType; TLE: TLE_lines;
      mass, s, Сb_coeff, CrossSecArea: MType; lines: boolean = true);
    procedure Modeling;
  end;

var
  Control: TControl;

implementation

{ TControl }

procedure TControl.Prepare(t0, t_end: TDate; step: MType; TLE: TLE_lines;
  mass, s, Сb_coeff, CrossSecArea: MType; lines: boolean = true);
var
  TDB: MType;
  Elements: TElements;
  // Mpc // Матрицы перехода: от истинной экваториальной к небесной
  // : TMatrix;
  temp_param: param;
begin

  // Приводим время к UTC в модифицированных юлианских днях (JD)
  start_time := FromDateToJD(t0);
  cur_time := start_time;
  end_time := FromDateToJD(t_end);

  Ever_step := step; // шаг в секундах или JD?

  // Читаем TLE
  if lines then
  begin
    Elements := ReadTLE(TLE).Elements;
    // Elements[0] := Elements[0] * Power(mass, Third); // странная конструкция
  end;

  TDB := TT_time(cur_time);
  // _P := ClcPrecMatr(cur_time);
  // _N := ClcNutMatr(cur_time);

  // Mpc := FromTrueToFixM(start_time); // Вычислили матрицу перехода к небесной СК
  // Mpc := FromTerraToFixM(start_time);  // пробуем из земной

  temp_param := Kepler_to_Decart(Elements, mass);
  // Получили вектор состояния в истинной экваториальной СК

  // Инициализируем спутник
  with Sputnik do
  begin
    // state.coord := MultMatrVec(Mpc, temp_param.coord);
    // state.speed := MultMatrVec(Mpc, temp_param.speed);
    state.coord := temp_param.coord;
    state.speed := temp_param.speed;
    _space := s;
  end;
  Sputnik.mass := mass;
  Sputnik.Cb_coeff := Сb_coeff;
  Sputnik.CrossSecArea := CrossSecArea;

end;

procedure TControl.Modeling;
var
  TDB: MType;
  _coord, _speed: coordinates;
  temp_force, Force: TResult;
  f: textfile;
  i: byte;

begin

  Assign(f, log_file);
  ReWrite(f);

  while cur_time < end_time do
  begin

    Force.x := NullVec;
    Force.dif_x := NullVec;

    with Sputnik.state do
    begin

      _coord := coord;

      _speed := speed;

    end;

    with Everhart do
    begin
      Force := Integrate(cur_time, _coord, _speed, Ever_step,
        GEO_potential.RightPart);
      // temp_force := Integrate(cur_time, _coord, _speed, Ever_step,
      // AtmosphericDrag.RightPart);

      Force.x := VecSum(Force.x, temp_force.x);
      Force.dif_x := VecSum(Force.dif_x, temp_force.dif_x);

//      temp_force := Integrate(cur_time, _coord, _speed, Ever_step,
//        SunPressure.RightPart);

      Force.x := VecSum(Force.x, temp_force.x);
      Force.dif_x := VecSum(Force.dif_x, temp_force.dif_x);
    end;

    with Sputnik.state do
    begin

      coord := Force.x;

      speed := Force.dif_x;

      writeln(f, 'Current time = ', cur_time:5:6);
      for i := 0 to 2 do
        writeln(f, deletimer, coord[i], deletimer, speed[i]);

    end;

    cur_time := cur_time + Ever_step;

    TDB := TT_time(cur_time);
    // считаем в конце цикла, так как в первый раз посчитали в Prepare
    // _P := ClcPrecMatr(TDB);
    // // Высчитали матрицы нутации и прецессии. На каждый шаг
    // _N := ClcNutMatr(TDB);

  end;

  Close(f);

end;

end.
