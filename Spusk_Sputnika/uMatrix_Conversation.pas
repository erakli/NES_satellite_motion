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

// -----------------------------------------------------------------------------
function Fix2Spher(FixCoord: coordinates): coordinates;
function Spher2Fix(SpherCoord: coordinates): coordinates;

var
	Q: TCIP_Tranform_Matrix;

implementation

{ Перевод между Земной (ITRS) в Небесную инерциальную (GCRS) СК на основе
  IERS Conversation(2010) с помощью CIO

  Считаем, что на вход подаётся время в ТТ, для чего надо реализовать
  перевод TT_UTC }
function ITRS2GCRS(t: MType): TMatrix;
var
  TT_centuries, UT1: MType;
  xpyp_vec: TVector;

  transform: TMatrix;
begin

  delta_got := false;

  TT_centuries := (t - J2000_Day) / JCentury;
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

  Tu := JD_ut1 - J2000_Day;

  // уточнить на счёт первого слагаемого (IERS Conversations (2003), ch. 5.4.4, eq. 14)
  // нормализации угла
  result := AngleNormalize(PI2 * (Trunc(Tu) - 0.7790572732640 + 1.00273781191135448 * Tu));

end;

{ ------------------------------------------------------------------------------ }

{ Из земной связанной в сферическую (географическую)

	На выходе 1 - радиус вектор, 2-3 - углы в радианах }

function Fix2Spher(FixCoord: coordinates): coordinates;
var
	x, y, z, // геоцентрические декартовы координаты

  SqrSum, // сумма квадратов

	ro, 		// радиус-вектор, км
  fi, 		// широта (-Pi/2..+Pi/2), от Южн. полюса к Сев., радианы
  lambda // долгота (-Pi..+Pi), От Зап. полушария к Восточному, радианы
  	: MType;
begin

	ro := module(FixCoord);

  // входная проверка координат
  if ro = 0 then
  begin
    Result := NullVec;
    Exit;
  end

  else
  begin

  	x := FixCoord[0];
    y := FixCoord[1];
    z := FixCoord[2];

    SqrSum := pow2(x) + pow2(y);

    if SqrSum = 0 then
    begin
      Result := NullVec;
      Exit;
    end;

  end;

  fi :=  ArcTan(
                  z /
                  Sqrt( SqrSum )
                );

  lambda := ArcTan( y / x );

  if (x > 0) AND (y >= 0) then

  else
  if x <= 0 then
  	lambda := lambda + Pi

  else
  if (x >= 0) AND (y < 0) then
  	lambda := lambda + PI2
  else
  begin
      Result := NullVec;
      Exit;
  end;

  Result[0] := ro;
  Result[1] := fi;
  Result[2] := lambda;

end;


{ Из сферической в декартову СК }

function Spher2Fix(SpherCoord: coordinates): coordinates;
var
	ro, fi, lambda: MType; // сферические координаты
begin

	ro := SpherCoord[0];
  fi := SpherCoord[1];
  lambda := SpherCoord[2];

	Result[0] := ro * cos(fi) * cos(lambda);
  Result[1] := ro * cos(fi) * sin(lambda);
  Result[2] := ro * sin(fi);

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

initialization

Q := TCIP_Tranform_Matrix.Create;

finalization

Q.Destroy;

end.
