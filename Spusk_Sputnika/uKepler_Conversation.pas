unit uKepler_Conversation;

interface

{ Алгоритмы для преобразования Кеплеровских элементов }

uses uTypes, uConstants, Math;

const
  Num_of_iter = 4;

function Iter_Method(s_e, M: MType; Newton: boolean = true): MType;
function Kepler_to_Decart(Elements: TElements; mass: MType): param; overload;
function Kepler_to_Decart(Elements: TElements; mass: MType; var Dubosh: boolean)
  : param; overload;

implementation

// ---------------------------------------------------------------

function Iter_Method(s_e, M: MType; Newton: boolean = true): MType;
const
  max_iter = 241;
var
  iter: integer;
  E: MType;
  cur, dif: MType;
begin
  // E := M;
  // for iter := 1 to Num_of_iter do
  // E := E - ((E - s_e * sin(DegToRad(E)) - M) / (1 - s_e * cos(DegToRad(E))));
  // result := E;

  cur := M + s_e * Sin(M); // в радианах
  dif := 1;
  iter := 0;

  if Newton then // используем для вычисления итерационный метод Ньютона
  begin

    While ((dif > 1.0E-15) AND (iter < max_iter)) Do
    Begin
      E := cur - (cur - s_e * Sin(cur) - M) / (1 - s_e * Cos(cur));
      dif := Abs(cur - E);
      cur := E;
      iter := iter + 1;
    End;

  end

  else // иначе используем метод "неподвижной точки" (Балк, Элементы динамики космического полёта, с. 114)

  begin

    While ((dif > 1.0E-15) AND (iter < max_iter)) Do
    Begin
      E := s_e * Sin(cur) + M;
      dif := Abs(cur - E);
      cur := E;
      iter := iter + 1;
    End;

  end; // if Newton

  result := E; // ответ в радианах

end;

{ Кеплеровские элементы орбиты

  Вектор состояния космического аппарата в форме оскулирующих кеплеровских
  элементов орбиты может быть задан на момент пересечения восходящего узла
  орбиты и включать в себя следующие компоненты:

  текущую дату и момент времени в шкале всемирного координированного вре-
  мени (UTC)
  a — величину большой полуоси орбиты в километрах,
  e — величину эксцентриситета орбиты,
  i — величину угла наклонения орбиты в градусах,
  Ω — величину долготы восходящего узла орбиты в градусах,
  ω — величину аргумента перигея орбиты в градусах,
  M — величину средней аномалии орбиты в градусах.

  Параметры i , Ω, ω даны в истинной экваториальной системе координат.

  При переходе от кеплеровских элементов к декартовым координатам и ско-
  ростям используют ещё три угловые переменные:

  эксцентрическую аномалию E ,
  истинную аномалию v
  аргумент широты u = v + ω.

  Средняя и эксцентрическая аномалии связаны между собой трансцедентным
  уравнением Кеплера

  M = E − e sinE.

  В формулах преобразования используется геоцентрическая гравитационная по-
  стоянная fm, измеряемая в км3/с2 ,

  размерность координат – километры, скоростей – километры в секунду.

  Полученные координаты находяться в истинной экваториальной СК.

  Примечание: s_ - означает "small" - далее идущая буква прописная, b_ - "big" -
  заглавная }
function Kepler_to_Decart(Elements: TElements; mass: MType): param;
type
  vec = record
    Sin, Cos: MType;
  end;
var
  a, s_e, i, b_Omega, s_omega, M, // Кеплеровы элементы орбиты
  b_E, r, p, rad_speed, tang_speed: MType;
  v, u: vec;
  // temp_result: param;
begin

  a := Elements[0];
  s_e := Elements[1];
  i := DegToRad(Elements[2]);
  // переводим в радианы, так как sin и cos считаются для радиан
  b_Omega := DegToRad(Elements[3]);
  s_omega := DegToRad(Elements[4]);
  M := DegToRad(Elements[5]);

  // E - эксцентрическая аномалия
  b_E := Iter_Method(s_e, M); // сразу считается в радианах

  // v - истинная аномалия
  v.sin := (sqrt(1 - sqr(s_e)) * Sin(b_E)) / (1 - s_e * Cos(b_E));
  v.cos := (Cos(b_E) - s_e) / (1 - s_e * Cos(b_E));

  // u - аргумент перицентра
  u.sin := v.sin * Cos(s_omega) + v.cos * Sin(s_omega);
  u.cos := v.cos * Cos(s_omega) + v.sin * Sin(s_omega);

  r := a * (1 - s_e * Cos(b_E)); // [km] - радиус-вектор
  p := a * (1 - sqr(s_e)); // параметр орбиты

  with result do
  begin
    rad_speed := sqrt(fm * mass / p) * s_e * v.sin;
    tang_speed := sqrt(fm * mass / p) * (1 + s_e * v.sin);

    // coordinates
    coord[0] := r * (u.cos * Cos(b_Omega) - u.sin * Sin(b_Omega) * Cos(i));
    coord[1] := r * (u.cos * Sin(b_Omega) + u.sin * Cos(b_Omega) * Cos(i));
    coord[2] := r * u.sin * Sin(i);

    // speed
    speed[0] := coord[0] / r * rad_speed +
      (-1 * u.sin * Cos(b_Omega) - u.cos * Sin(b_Omega) * Cos(i)) * tang_speed;

    speed[1] := coord[1] / r * rad_speed +
      (-1 * u.sin * Sin(b_Omega) + u.cos * Cos(b_Omega) * Cos(i)) * tang_speed;

    speed[2] := coord[2] / r * rad_speed + u.cos * Sin(i) * tang_speed;

    // // combination
    // temp_result.coord := coord;
    // temp_result.speed := speed;
  end;

  // result := temp_result;

end;

////////////////////////////////////////////////////////////////////////////////

{
  Реализация преобразования этих элементов из Дубошина (с. 223)
}
function Kepler_to_Decart(Elements: TElements; mass: MType;
  var Dubosh: boolean): param;
type
  vec = record
    Sin, Cos: MType;
  end;
var
  a, s_e, i, b_Omega, s_omega, M, // Кеплеровы элементы орбиты
  b_E, r, // радиус-вектор
  Ksi, Eta, // орбитальные координаты
  _p: MType;

  P, Q, PQ_check, coord: TVector;

  j: byte;

  rad_speed, tang_speed, _v, _u: MType;
  v, u: vec;
  speed: TVector;

  temp: double;
begin

  Dubosh := true;

  a := Elements[0];
  s_e := Elements[1];
  i := DegToRad(Elements[2]);
  b_Omega := DegToRad(Elements[3]);
  s_omega := DegToRad(Elements[4]);
  M := DegToRad(Elements[5]);

  P[0] := Cos(s_omega) * Cos(b_Omega) - Sin(s_omega) * Sin(b_Omega) * Cos(i);
  P[1] := Cos(s_omega) * Sin(b_Omega) + Sin(s_omega) * Cos(b_Omega) * Cos(i);
  P[2] := Sin(s_omega) * Sin(i);

  Q[0] := -Sin(s_omega) * Cos(b_Omega) - Cos(s_omega) * Sin(b_Omega) * Cos(i);
  Q[1] := -Sin(s_omega) * Sin(b_Omega) + Cos(s_omega) * Cos(b_Omega) * Cos(i);
  Q[2] := Cos(s_omega) * Sin(i);

  PQ_check[0] := 0; // сумма квадратов P
  PQ_check[1] := 0; // сумма квадратов Q
  PQ_check[2] := 0; // сумма попарного произведения координат P и Q

  for j := 0 to 2 do
  begin
    PQ_check[0] := PQ_check[0] + sqr(P[j]);
    PQ_check[1] := PQ_check[1] + sqr(Q[j]);
    PQ_check[2] := PQ_check[2] + P[j] * Q[j];
  end;

  // контроль вычислений
  if ((PQ_check[0] <> 1) OR (PQ_check[1] <> 1) OR (Abs(PQ_check[2]) > 1.0E-15)) then
  begin
    Dubosh := false; // мы не удовлетворяем условиям проверки P и Q
    result.coord := PQ_check;
    Exit; // закончили выполнение текущей функции. Снаружи нужен обработчик
  end;

  // E - эксцентрическая аномалия
  b_E := Iter_Method(s_e, M, false);
  // сразу считается в радианах. Булинь - для выбора метода (Ньютона или неподв. точек)

  r := a * (1 - s_e * Cos(b_E));
  Ksi := a * (Cos(b_E) - s_e);
  Eta := a * sqrt(1 - sqr(s_e)) * Sin(b_E);

  for j := 0 to 2 do
    coord[j] := P[j] * Ksi + Q[j] * Eta;

  result.coord := coord;

  { Вычисление скорости для эллиптического движения }
  _v := 2 * arctan(sqrt((1 + s_e) / (1 - s_e)) * Tan(b_E / 2));
  _u := _v + s_omega;

  // v - истинная аномалия
  v.sin := Sin(_v);
  v.cos := Cos(_v);

  // u - аргумент перицентра
  u.sin := Sin(_u);
  u.cos := Cos(_v);

  // r := a * ( 1 - sqr(s_e) ) / ( 1 + s_e * v.cos ); // [km] - радиус-вектор
  _p := a * (1 - sqr(s_e)); // параметр орбиты

  rad_speed := sqrt(fm * mass / _p) * s_e * v.sin; // радиальная скорость
  tang_speed := sqrt(fm * mass / _p) * (1 + s_e * v.sin);
  // трансверальная скорость

  // speed
  speed[0] := coord[0] / r * rad_speed +
    (-u.sin * Cos(b_Omega) - u.cos * Sin(b_Omega) * Cos(i)) * tang_speed;

  speed[1] := coord[1] / r * rad_speed +
    (-u.sin * Sin(b_Omega) + u.cos * Cos(b_Omega) * Cos(i)) * tang_speed;

  speed[2] := coord[2] / r * rad_speed + u.cos * Sin(i) * tang_speed;

  result.speed := speed;

end;

end.
