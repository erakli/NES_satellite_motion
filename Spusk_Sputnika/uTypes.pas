unit uTypes;

{ В данном модуле описаны используемые типы }

interface

const

  m_size = 2; // Размер матриц

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

  { Параметры Земли }
  TEarth = record
    eq_rad, // [km] Экваториальный радиус Земли
    alpha_0, // сжатие Земли
    omega, // [рад/с] угловая скорость вращения Земли
    density_120, // [кг/м^3] плотность ночной атмосферы на высоте 120 км
    big_a { [км] большая полуось орбиты Земли,
      является 1 астрономической единицей }
      : MType;
  end;

  { Параметры Солнца }
  TSun = class(TObject)
  private
    _alpha, // прямое восхождение (рад)
    _beta,  // и склонение Солнца (рад)
    _q { солнечная постоянная (для давления света),
      	 q = 4.65e+5 [дин/см^2] }
      : MType;
    _pos: coordinates; // положение в Геоцентрической СК

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

  param = record // необходима для преобразования кеплеровских элементов
    coord, speed: TVector;
  end;

  { a, s_e, i, b_Omega, s_omega, M0, n - Кеплеровские элементы орбиты (7) }
  TElements = array [0 .. 6] of MType;

  TLE_lines = array [0 .. 1] of string;

  TTLE_output = record // специально для TLE модуля - вывод функции ReadTLE
    time: MType; // в JD
    Elements: TElements;
  end;

implementation

uses
	uTime, uFunctions;

const
	DegInDay: MType = 360 / 365; // кол-во градусов, которое в среднем проходит Земля в день (!костыль!)


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
	Days: word; // Дней с начала года
begin

	{ !низкая точность! }

	Days := DayNumber(JD);
  _alpha := Days * DegInDay;
  _alpha := deg2rad(_alpha);

  _beta := deg2rad(23.45) * sin( deg2rad(DegInDay * (Days - 81)) );

end;

end.
