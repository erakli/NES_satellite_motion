unit uSunPressure;

{ Модуль рассчёта давления, вызываемого светом.

  Для учёта теневой стороны Земли делается допущение, что тень представляет
  собой цилиндр }

interface

uses
  uConstants, uTypes, uFunctions, Math, uEpheremides_new, {uEpheremides,}
  uTime, uSputnik, uMatrix_Operations;

type

  { TO-DO:
    * Необходимо рассчитать площадь эффективного сечения
    (либо передавать напрямую, либо забирать из объекта спутника)
    * Нужно понять логику выбора k' и k"
  }

  TSunPressure = class
  private

    Sun: TSun; { Запись с данными о положении Солнца (.pos),
      для вычисления необходимы эферимиды }

    ISZ: coordinates; // Координаты спутника

    cos_psi // для рассчётов тени
    // : coordinates;
      : MType;

    beta, { [град] такое значение усгла пси (в рассчётах тени)
      при котором диффузное отражение практически
      перестает оказывать влияние на спутник }

    Earth_Sun, Sun_ISZ, // Расстояние между спутником и Солнцем
    Earth_ISZ, // расстояние от спутника до центра Земли
    fi, // угол, на котором пересекается орбита и граница тени
    psi { Это угол, скорее всего аномалия, на который спутник
      отстоит линии, соединяющей Солнце и Землю }
      : MType;

    k: array [0 .. 2] of real; { Коэффициенты:
      * k - отражательные свойства ИСЗ,
      k = 1 - зеркало, k = 1.44 - диффузное;
      * k' и k", используются для вычисления
      давления от света отражённого от Земли,
      0.2 <= k' <= 0.3, 0.37 <= k" <= 0.57 }

    procedure SunPressureInit(t: MType; coord: coordinates);

    { Функция для учёта нахождения ИСЗ в тени }
    function Shadow(psi: MType; isSunLight: boolean): byte;

    { Составляющие силы, создающей давление на ИСЗ }
    function SunP: coordinates; // Свет от Солнца
    function EarthP: coordinates; // Отражённый свет от Земли
  public
    function RightPart(t: MType; coord, veloc: coordinates): coordinates;

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

procedure TSunPressure.SunPressureInit(t: MType; coord: coordinates);
var
  temp_vect: coordinates;
  scal_inc: MType; // Для вычисления скалярного произведения
  TDB: MType; // Барицентрическое динамическое время в MJD
begin

  { Надо сделать задание коэффициентов k[1] и k[2] (Выше) }

  TDB := TT_time(t) - (au / c) / SecInDay;
  // учитываем задержку во времени из-за расстояния между Солнцем и Землёй

  { Вызов эферимид для рассчёта положения Солнца относительно Земли,
    возможно функция }
  //Sun.Pos := Epheremides.GetEpheremides(TDB);
  Sun.Pos := ChangeRS(Earth_Moon.Get(TDB));

  ISZ := coord;
  Earth_ISZ := module(ISZ);
  Earth_Sun := module(Sun.Pos);

  { В следующем выражении необходимо рассчитать расстояние от Солнца до ИСЗ.

    Нужно узнать аргумент косинуса для проекции на ось, соединяющую центры
    Солнца и Земли.

    Для этого необходимо понять, каким образом вычислять это расстояние,
    на какой угол радиус вектор спутника отстоит от радиус вектора Солнца.

    Узнали }
    { Справедливо для скалярного произведения векторов, заданных в декартовой
      СК }
  scal_inc := DotProduct(ISZ, Sun.pos); // Из скалярного произведения

  cos_psi := -scal_inc / (Earth_ISZ * Earth_Sun);

  psi := arccos(cos_psi);

  { Это мы пытаемся узнать расстояние от Солнца до спутника.

    Необходимо уточнить правильность вычисления расстояния между Солнцем и
    спутником }
  temp_vect := VecDec(Sun.pos, ISZ);

  Sun_ISZ := module(temp_vect);
  // Sun_ISZ := Earth_Sun;  { Принимаем расстояние от Солнца до
  // спутника равным 1 астр. ед. }

  { Здесь необходимо учесть то, что это справедливо только с теневой стороны,
    то есть условие, что Sun_ISZ > Earth_Sun }
  fi := arcsin(Earth.eq_rad / Earth_ISZ);

end;

function TSunPressure.Shadow(psi: MType; isSunLight: boolean): byte;
begin

  result := 0;

  { Здесь мы ввели условие на то, что если мы находимся с теневой стороны,
    то мы вычисляем функцию темноты, иначе её не учитываем }
  if Earth_Sun < Sun_ISZ then
    if isSunLight then
      if psi > abs(fi) then
        result := 1
      else if cos(psi) >= cos(beta) then
        result := 1;

end;

function TSunPressure.SunP: coordinates;
var
  temp_part: MType;
begin

  temp_part := k[0] * Sun.q * Sputnik._space * Shadow(psi, true) *
    sqr(Earth.big_a / Sun_ISZ);

  result := ConstProduct(temp_part / Sun_ISZ, VecDec(Sun.pos, ISZ));

end;

function TSunPressure.EarthP: coordinates;
var
  temp_part: MType;
begin

  temp_part := Sun.q * Sputnik._space * (Earth.big_a / Sun_ISZ) *
    (Earth.eq_rad / Earth_ISZ) * (k[1] * sqr(cos(fi)) + k[2] * Shadow(psi,
    false) * sin(beta - psi));

  result := ConstProduct(temp_part / Earth_ISZ, ISZ);

end;

function TSunPressure.RightPart(t: MType; coord, veloc: coordinates)
  : coordinates;
var
  temp: array [0 .. 1] of coordinates;
begin

  // _space := s; // инициализируем площадь поперечного сечения ИСЗ

  SunPressureInit(t, coord);

  temp[0] := SunP;
  temp[1] := EarthP;

  result := VecSum(temp[0], temp[1]);

end;

end.
