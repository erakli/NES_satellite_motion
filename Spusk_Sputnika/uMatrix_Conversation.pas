unit uMatrix_Conversation;

{ Модуль с алгоритмами вычисления матриц преобразования }

interface

uses
  uMatrix_Operations, uConstants, uTypes, uPrecNut, uStarTime, uTime,
  uEpheremides, uFunctions;

function FromFixToTrueM(t: MType): TMatrix;
function FromTrueToFixM(t: MType): TMatrix;

function FromFixToTerraM(t: MType): TMatrix;
function FromTerraToFixM(t: MType): TMatrix;

// -----------------------------------------------------------------------------
function ITRS2GCRS(t: MType): TMatrix;
function W(t, xp, yp: MType): TMatrix;
function R(t: MType): TMatrix;
function ERA(JD_ut1: MType): MType;

implementation

{ Перевод между Земной (ITRS) в Небесную инерциальную (GCRS) СК на основе
  IERS Conversation(2010) с помощью CIO

  Считаем, что на вход подаётся время в ТТ, для чего надо реализовать
  перевод TT_UTC }
function ITRS2GCRS(t: MType): TMatrix;
var
  TT_centuries, UT1: MType;
  xpyp_vec: TVector;
  Q: TCIP_Tranform_Matrix;

  transform: TMatrix;
begin

  Q := TCIP_Tranform_Matrix.Create;
  delta_got := false;

  TT_centuries := (t - J2000_Day) / 36525;
  xpyp_vec := GetDeltaUT(TT2UTC(t)); // здесь нужно UTC на вход

  UT1 := UT1_time(TT2UTC(t)); // и здесь

  transform := MultMatr(R(UT1), W(TT_centuries, xpyp_vec[1], xpyp_vec[2]));
  result := MultMatr(Q.getQ_Matrix(TT_centuries), transform);
  // здесь тоже centuries?
end;

{ Transformation matrix for polar motion }
function W(t, xp, yp: MType): TMatrix;
var
  _s, x, y: MType;
  res_matrix: TMatrix;
begin

  _s := asec2rad(-0.000047) * t;
  x := asec2rad(xp);
  y := asec2rad(yp);

  res_matrix := MultMatr(RotMatr(3, -_s), RotMatr(2, x));
  result := MultMatr(res_matrix, RotMatr(1, y));

end;

{ CIO based transformation matrix for Earth rotation

  Время на входе в UT1 }
function R(t: MType): TMatrix;
begin

  result := RotMatr(3, -ERA(t));

end;

{ Earth Rotation Angle }
function ERA(JD_ut1: MType): MType;
var
  Tu: MType; // = JD_ut1 - 2451545.0
begin

  Tu := JD_ut1 - 2451545.0;
  result := 2 * pi * (0.7790572732640 + 1.00273781191135448 * Tu);

end;

{ ------------------------------------------------------------------------------ }

{ От небесной к истинной экваториальной системе координат

  Матрица перехода между небесной системой координат и истинной эквато-
  риальной системой является произведением матрицы нутации N(t) на матрицу
  прецессии P(t). }
function FromFixToTrueM(t: MType): TMatrix;
// var
// P, N: TMatrix; // Матрицы прецессии и нутации
begin

  // Время для матриц в какой системе?

  // P := ClcPrecMatr(t);
  // N := ClcNutMatr(t);

  result := MultMatr(_N, _P);

end;

{ От истинной экваториальной системы координат к небесной

  !!! Проверить правильность данной операции !!!

  Матрица перехода от истинной экваториальной системы координат к небесной
  системе координат является транспонированной по отношению к матрице перехо-
  да от небесной системы координат к истинной экваториальной. }
function FromTrueToFixM(t: MType): TMatrix;
var
  Mcp: TMatrix; // от небесной к истинной экваториальной
begin

  Mcp := FromFixToTrueM(t);
  result := TranspMatr(Mcp);

end;

{ Преобразование из небесной системы координат в земную

  Матрицы перехода от небесной к земной системе координат вычисляется как
  произведение матрицы вращения Земли, матрицы нутации, матрицы прецессии }
function FromFixToTerraM(t: MType): TMatrix;
var
  R: array [1 .. 3] of TMatrix;
  { Вспомогательные матрицы:
    R[3] = R - матрица вращения Земли
    R[1] = R1(−yp) – матрица поворота вокруг оси абсцисс против часовой
    стрелки на эмпирическое значение координаты полюса Земли yp
    R[2] = R2(−xp) – матрица поворота вокруг оси ординат против часовой
    стрелки на эмпирическое значение координаты полюса Земли xp }

  temp_M: TMatrix;
  S: MType; // Гринвичское истинное звёздное время
  UT1 { , // Всемирное время (для координат полюса)
    TDB } : MType; // Барицентрическое динамическое время в MJD
begin

  UT1 := UT1_time(t);
  S := ToGetGASTime(UT1);

  // TDB := TT_time(t);
  { Перевод полученного времени в барицентрическое. Получение
    матриц прецессии и нутации вычисляется в нём }

  R[1] := RotMatr(1, -GetDeltaUT(UT1)[2]); // Аргументом yp вокруг OX
  R[2] := RotMatr(2, -GetDeltaUT(UT1)[1]); // Аргументом xp вокруг OY

  temp_M := MultMatr(R[2], R[1]);
  // temp_M := MultMatr(temp_M, EarthRotMatr(S));

  // R[3] := MultMatr(ClcNutMatr(TDB), ClcPrecMatr(TDB));
  R[3] := MultMatr(_N, _P);

  result := MultMatr(temp_M, R[3]); // R2(−xp) * R1(−yp) * R * N * P

end;

{ Преобразование из земной системы координат в небесную

  Матрица преобразования между земной и небесной системами координат необходима
  при вычислении компонентов ускорения, обусловленного гравитационным полем
  Земли }
function FromTerraToFixM(t: MType): TMatrix;
var
  Mpc: TMatrix;
begin

  Mpc := FromFixToTerraM(t);
  result := TranspMatr(Mpc); { Для вычисления надо воспользоваться алгоритмом
    транспонирования матрицы }

end;

end.
