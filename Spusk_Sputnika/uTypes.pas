unit uTypes;

{ В данном модуле описаны используемые типы }

interface

const

  m_size = 2; // Размер матриц

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
  TSun = record
    alpha, // прямое восхождение
    beta, // и склонение Солнца
    q { солнечная постоянная (для давления света),
      q = 4.65e+5 [дин/см^2] }
      : MType;
    pos: coordinates; // положение в Геоцентрической СК
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

  output = record // специально для TLE модуля - вывод функции ReadTLE
    time: MType; // в JD
    Elements: TElements;
  end;

implementation

end.
