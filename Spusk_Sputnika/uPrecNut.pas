unit uPrecNut;

{
	TO-DO:
  	* Доработать поворот вокруг осей в модуле uMatrix_Operations
    * Вычислять степени t изначально и подставлять это значение в места вызова
}

interface

{ Алгоритмы вычисления матрицы прецессии и матрицы нутации

  Время используется в Юлианских столетиях. Выражение (5.2) для их вычисления
  дано на стр. 45 документа IERS Conversation (2010), tn36:

    t = (TT - 2000 January 1d 12h TT) in days / 36525
    2000 January 1.5 TT = Julian Date 2451545.0 TT
  }

uses
  uConstants, uMatrix_Operations, uFunctions, uTypes,
   uPrecNut_InitialParam; // здесь  хранятся массивы множителей для ARGUMENT

type

	TCIP_Tranform_Matrix = class  // Матрица Q(t)
  private

  	X, Y, { Координаты CIP в GCRS }
    x2, y2, // квадраты координат полюса

    s     { s being a quantity, named "CIO locator", which provides the position
    				of the CIO on the equator of the CIP corresponding to the kinematical
            defnition of the NRO in the GCRS when the CIP is moving with respect
            to the GCRS, between the reference epoch and the date t due to
            precession and nutation }
     : MType;


  	{* * * The fundamental arguments of nutation theory * * *}

    {*	The arguments of lunisolar nutation (0..4)
    	+ the arguments for the planetary nutation (5..13) *}

  	Fa: array[0..FA_SIZE] of MType; // t is measured in Julian centuries of TDB

    { Инициализация данных }
    procedure FaInit(t: MType);

    { Вычисление X и Y }
    function getX(t: MType): MType;
    function getY(t: MType): MType;

    function get_s(t: MType): MType;

    function get_a: MType;

  public

  	function getQ_Matrix(t: MType): TMatrix;

  	constructor Create;
    destructor Destroy; override;

  end;


implementation


{ TCIP_Tranform_Matrix }

constructor TCIP_Tranform_Matrix.Create;
begin

end;

destructor TCIP_Tranform_Matrix.Destroy;
begin

	{ уточнить про очистку динамического массива (в интернете указано, что
  	"you don't need to free the memory at all, since this is done automatically
     when the identifier goes out of scope") }
  inherited;
end;


{ Формирование преобразующей матрицы }

function TCIP_Tranform_Matrix.getQ_Matrix(t: MType): TMatrix;
var
  Q, R3: TMatrix;
  a: MType;
begin

  FaInit(t);
  X := getX(t);
  Y := getY(t);
  s := get_s(t);

  x2 := sqr(X);
  y2 := sqr(Y);

  a := get_a;

  Q[0, 0] := 1 - a * x2;    Q[0, 1] := -a * X * Y;    Q[0, 2] := X;

  Q[1, 0] := -a * X * Y;    Q[1, 1] := 1 - a * y2;    Q[1, 2] := Y;

  Q[2, 0] := -X;            Q[2, 1] := -Y;            Q[2, 2] := 1 - a * (x2 + y2);

  R3 := RotMatr(3, s);
  result := MultMatr(Q, R3);

end;


{ Начальная инициализация параметров для заданного времени }

procedure TCIP_Tranform_Matrix.FaInit(t: MType);   // t is measured in Julian centuries
var
	l, l_, F, D, Om: MType;
begin

	// придумать оптимизацию, написать описания

  // сразу переводим в радианы
	l :=  deg2rad(134.96340251) + asec2rad(1717915923.2178 * t + 31.8792 * pow2(t)
  			+ 0.051635 * pow3(t) - 0.0002447 * pow4(t));

  l_ := deg2rad(357.52910918) + asec2rad(129596581.0481 * t - 0.5532 * pow2(t)
  			+ 0.000136 * pow3(t) - 0.00001149 * pow4(t));

  F := deg2rad(93.27209062) + asec2rad(1739527262.8478 * t - 12.7512 * pow2(t)
  		 - 0.001037 * pow3(t) + 0.00000417 * pow4(t));

  D := deg2rad(297.85019547) + asec2rad(1602961601.209 * t - 6.3706 * pow2(t)
			 + 0.006593 * pow3(t) - 0.00003169 * pow4(t));

  Om := deg2rad(125.04455501) - asec2rad(6962890.5431 * t + 7.4722 * pow2(t)
			  + 0.007702 * pow3(t) - 0.00005939 * pow4(t));

  Fa[0] := l;
  Fa[1] := l_;
  Fa[2] := F;
  Fa[3] := D;
  Fa[4] := Om;

  // в радианах
  Fa[5] := 4.402608842 + 2608.7903141574 * t;
  Fa[6] := 3.176146697 + 1021.3285546211 * t;
  Fa[7] := 1.753470314 + 628.3075849991 * t;
  Fa[8] := 6.203480913 + 334.0612426700 * t;
  Fa[9] := 0.599546497 + 52.9690962641 * t;
	Fa[10] := 0.874016757 + 21.3299104960 * t;
	Fa[11] := 5.481293872 + 7.4781598567 * t;
	Fa[12] := 5.311886287 + 3.8133035638 * t;
	Fa[13] := 0.02438175 * t + 0.00000538691 * pow2(t);

end;


{
  Коэффициент, используемый, при вычислении матрицы Q

  Важно: должен считаться после X и Y (считается на их основе) }

function TCIP_Tranform_Matrix.get_a: MType;
var
  d: MType; // в теории, расстояние до полюса
begin

  d := arctan( sqrt( (x2 + y2)/(1 - x2 - y2) ) );

  result := 1 / ( 1 + cos(d) );

end;


{ Вычисление координаты X CIO }

function TCIP_Tranform_Matrix.getX(t: MType): MType;
var
  arg,   // Аргумент синуса и косинуса в не-полиномиальной части
  pol, non_pol, // Polinomial and non-polinamial parts of X
  sum
  : MType;

  i, f_ind: integer;
begin

  { Можно оптимизировать введя J }

  // в МИКРОарксекундах
  pol := -16617 + 2004191898 * t - 429782.9 * pow2(t) - 198618.34 * pow3(t)
         + 7.578 * pow4(t) + 5.9285 * pow5(t);

  { Идём по периодам в обратном порядке (j = 4..0) }
  non_pol := 0; // результат вычисления - МИКРОарксекунды (надо переводить к арксекундам)


  // ----- j = 4
  arg := 0;
  for f_ind := 0 to FA_SIZE - 1 do
    arg := arg + Fa[f_ind] * aX4[0, f_ind + 4];

  non_pol := (aX4[0, 1] * sin(arg) + aX4[0, 2] * cos(arg)) * pow4(t);


  // ----- j = 3

  for i := ind_aX[3] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aX3[0, f_ind + 4];

    sum := (aX3[0, 1] * sin(arg) + aX3[0, 2] * cos(arg)) * pow3(t);
    non_pol := non_pol + sum;

  end;


  // ----- j = 2

  for i := ind_aX[2] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aX2[0, f_ind + 4];

    sum := (aX2[0, 1] * sin(arg) + aX2[0, 2] * cos(arg)) * pow2(t);
    non_pol := non_pol + sum;

  end;


  // ----- j = 1

  for i := ind_aX[1] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aX1[0, f_ind + 4];

    sum := (aX1[0, 1] * sin(arg) + aX1[0, 2] * cos(arg)) * t;
    non_pol := non_pol + sum;

  end;


  // ----- j = 0

  for i := ind_aX[0] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aX0[0, f_ind + 4];

    sum := aX0[0, 1] * sin(arg) + aX0[0, 2] * cos(arg);
    non_pol := non_pol + sum;

  end;


  // Собираем результат
  result := asec2rad((pol + non_pol) * MICRO); { так как non_pol вычисляется в
    МИКРОарксекундах - надо привести к арксекундам домножив на 1.0e-6 }

end;



{ Вычисление координаты Y CIO }

function TCIP_Tranform_Matrix.getY(t: MType): MType;
var
  arg,   // Аргумент синуса и косинуса в не-полиномиальной части
  pol, non_pol, // Polinomial and non-polinamial parts of Y
  sum
  : MType;

  i, f_ind: integer;
begin

  { Можно оптимизировать введя j }

  // в МИКРОарксекундах
  pol := -6951 - 25896 * t - 22407274.7 * pow2(t) + 1900.59 * pow3(t)
         + 1112.526 * pow4(t) + 0.1358 * pow5(t);

  { Идём по периодам в обратном порядке (j = 4..0) }
  non_pol := 0; // результат вычисления - МИКРОарксекунды (надо переводить к арксекундам)


  // ----- j = 4
  arg := 0;
  for f_ind := 0 to FA_SIZE - 1 do
    arg := arg + Fa[f_ind] * aY4[0, f_ind + 4];

  non_pol := (aY4[0, 1] * cos(arg) + aY4[0, 2] * sin(arg)) * pow4(t);


  // ----- j = 3

  for i := ind_aY[3] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aY3[0, f_ind + 4];

    sum := (aY3[0, 1] * cos(arg) + aY3[0, 2] * sin(arg)) * pow3(t);
    non_pol := non_pol + sum;

  end;


  // ----- j = 2

  for i := ind_aY[2] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aY2[0, f_ind + 4];

    sum := (aY2[0, 1] * cos(arg) + aY2[0, 2] * sin(arg)) * pow2(t);
    non_pol := non_pol + sum;

  end;


  // ----- j = 1

  for i := ind_aY[1] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aY1[0, f_ind + 4];

    sum := (aY1[0, 1] * cos(arg) + aY1[0, 2] * sin(arg)) * t;
    non_pol := non_pol + sum;

  end;


  // ----- j = 0

  for i := ind_aY[0] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * aY0[0, f_ind + 4];

    sum := aY0[0, 1] * cos(arg) + aY0[0, 2] * sin(arg);
    non_pol := non_pol + sum;

  end;


  // Собираем результат
  result := asec2rad((pol + non_pol) * MICRO); { так как non_pol вычисляется в
    МИКРОарксекундах - надо привести к арксекундам домножив на 1.0e-6 }
end;



{ На основе полученных X и Y вычисляется s }

function TCIP_Tranform_Matrix.get_s(t: MType): MType;
var
  arg,   // Аргумент синуса и косинуса в не-полиномиальной части
  pol, non_pol, // Polinomial and non-polinamial parts of s
  sum
  : MType;

  i, f_ind: integer;
begin

  { Можно оптимизировать введя j }

  // в МИКРОарксекундах
  pol := 94.0 + 3808.65 * t - 122.68 * pow2(t) - 72574.11 * pow3(t)
  			 + 27.98 * pow4(t) + 15.62 * pow5(t);

  { Идём по периодам в обратном порядке (j = 4..0) }
  non_pol := 0; // результат вычисления - МИКРОарксекунды (надо переводить к арксекундам)


  // ----- j = 4
  arg := 0;
  for f_ind := 0 to FA_SIZE - 1 do
    arg := arg + Fa[f_ind] * as_4[0, f_ind + 4];

  non_pol := (as_4[0, 1] * sin(arg) + as_4[0, 2] * cos(arg)) * pow4(t);


  // ----- j = 3

  for i := ind_as_[3] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * as_3[0, f_ind + 4];

    sum := (as_3[0, 1] * sin(arg) + as_3[0, 2] * cos(arg)) * pow3(t);
    non_pol := non_pol + sum;

  end;


  // ----- j = 2

  for i := ind_as_[2] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * as_2[0, f_ind + 4];

    sum := (as_2[0, 1] * sin(arg) + as_2[0, 2] * cos(arg)) * pow2(t);
    non_pol := non_pol + sum;

  end;


  // ----- j = 1

  for i := ind_as_[1] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * as_1[0, f_ind + 4];

    sum := (as_1[0, 1] * sin(arg) + as_1[0, 2] * cos(arg)) * t;
    non_pol := non_pol + sum;

  end;


  // ----- j = 0

  for i := ind_as_[0] - 1 downto 0 do
  begin

    arg := 0;
    for f_ind := 0 to FA_SIZE - 1 do
      arg := arg + Fa[f_ind] * as_0[0, f_ind + 4];

    sum := as_0[0, 1] * sin(arg) + as_0[0, 2] * cos(arg);
    non_pol := non_pol + sum;

  end;


  // Собираем результат
  result := asec2rad((pol + non_pol) * MICRO); { так как non_pol вычисляется в
    МИКРОарксекундах - надо привести к арксекундам домножив на 1.0e-6 }

end;

end.
