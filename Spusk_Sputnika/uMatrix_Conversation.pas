unit uMatrix_Conversation;

{ Модуль с алгоритмами вычисления матриц преобразования }

interface

uses
  uMatrix_Operations, uConstants, uTypes, uPrecNut, uStarTime, uTime,
  uEpheremides;

function FromFixToTrueM(t: MType): TMatrix;
function FromTrueToFixM(t: MType): TMatrix;

function FromFixToTerraM(t: MType): TMatrix;
function FromTerraToFixM(t: MType): TMatrix;

implementation

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
  temp_M := MultMatr(temp_M, EarthRotMatr(S));

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
