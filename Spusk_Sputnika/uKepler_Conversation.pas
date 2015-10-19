unit uKepler_Conversation;

interface

{ Алгоритмы для преобразования Кеплеровских элементов }

uses uConstants, Math;

const
  Num_of_iter = 4;

function Newton_Iter_Method(s_e, M: double): double;
function Kepler_to_Decart(Elements: TElements; mass: double): param;

implementation

// ---------------------------------------------------------------

function Newton_Iter_Method(s_e, M: double): double;
var
  iter: integer;
  E: double;
  cur, dif: double;
begin
//   E := M;
//   for iter := 1 to Num_of_iter do
//   E := E - ((E - s_e * sin(DegToRad(E)) - M) / (1 - s_e * cos(DegToRad(E))));
//   result := E;

  cur := M + s_e * Sin(DegToRad(M));
  E := cur;
  dif := 1;
  iter := 0;

  While ((dif > 1.0E-15) AND (iter < 241)) Do
  Begin
    E := cur - (cur - s_e * Sin(DegToRad(cur)) - M) / (1 - s_e * Cos(DegToRad(cur)));
    dif := Abs(cur - E);
    cur := E;
    iter := iter + 1;
  End;

  result := E;

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
function Kepler_to_Decart(Elements: TElements; mass: double): param;
type
  vec = record
    Sin, Cos: double;
  end;
var
  a, s_e, i, b_Omega, s_omega, M, // Кеплеровы элементы орбиты
  b_E, r, p, rad_speed, tang_speed: double;
  v, u: vec;
  // temp_result: param;
begin

  a := Elements[0];
  s_e := Elements[1];
  i := Elements[2];
  b_Omega := Elements[3];
  s_omega := Elements[4];
  M := Elements[5];

  // E - эксцентрическая аномалия
  b_E := Newton_Iter_Method(s_e, M);

  // v - истинная аномалия
  v.sin := (sqrt(1 - sqr(s_e)) * Sin(DegToRad(b_E))) /
    (1 - s_e * Cos(DegToRad(b_E)));
  v.cos := (Cos(DegToRad(b_E)) - s_e) / (1 - s_e * Cos(DegToRad(b_E)));

  // u - аргумент перицентра
  u.sin := v.sin * Cos(DegToRad(s_omega)) + v.cos * Sin(DegToRad(s_omega));
  u.cos := v.cos * Cos(DegToRad(s_omega)) + v.sin * Sin(DegToRad(s_omega));

  r := a * (1 - s_e * Cos(DegToRad(b_E))); // [km] - радиус-вектор
  p := a * (1 - sqr(s_e)); // параметр орбиты

  with result do
  begin
    rad_speed := sqrt(fm * mass / p) * s_e * v.sin;
    tang_speed := sqrt(fm * mass / p) * (1 + s_e * v.sin);

    // coordinates
    coord[0] := r * (u.cos * Cos(DegToRad(b_Omega)) - u.sin *
      Sin(DegToRad(b_Omega)) * Cos(DegToRad(i)));
    coord[1] := r * (u.cos * Sin(DegToRad(b_Omega)) + u.sin *
      Cos(DegToRad(b_Omega)) * Cos(DegToRad(i)));
    coord[2] := r * u.sin * Sin(DegToRad(i));

    // speed
    speed[0] := coord[0] / r * rad_speed +
      (-1 * u.sin * Cos(DegToRad(b_Omega)) - u.cos * Sin(DegToRad(b_Omega)) *
      Cos(DegToRad(i))) * tang_speed;
    speed[1] := coord[1] / r * rad_speed +
      (-1 * u.sin * Sin(DegToRad(b_Omega)) + u.cos * Cos(DegToRad(b_Omega)) *
      Cos(DegToRad(i))) * tang_speed;
    speed[2] := coord[2] / r * rad_speed + u.cos * Sin(DegToRad(i)) *
      tang_speed;

    // // combination
    // temp_result.coord := coord;
    // temp_result.speed := speed;
  end;

  // result := temp_result;

end;

end.
