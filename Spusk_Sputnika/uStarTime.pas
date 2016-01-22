unit uStarTime;

interface

{ Алгоритмы вычисления звёздного времени

  (как минимум используется в uAtmosphericDrag.pas)

  Моменту всемирного координированного времени UTC соответствует модифи-
  цированная юлианская дата UTCmjd. Величина UTCmjd измеряется в юлианских днях.


  Всемирное время UT1 связано со всемирным координированным временем UTC
  формулой

  UT1 = UTC + ΔUT.

  Разность

  ΔUT = UT1 − UTC

  может быть определена только на основе наблюдений. Поправка всемирного времени
  ΔUT измеряется в секундах. }

uses
  uFunctions, uPrecNut, uConstants, uTypes, uTime;//, uEpheremides;

function GMSTime(UT1, TT: MType; theory2006: Boolean = true): MType;

function ToGetGMSTime(UT1_jd: MType; Midnight: boolean = true): MType;
// Гринвичское среднее звёздное время
function ToGetGASTime(UT1_mjd: MType): MType; { Гринвичское истинное
  звёздное время }

implementation
// ---------------------------------------------------------------

uses
  uMatrix_Conversation;

{ Greenwich mean sidereal time

	Реализация на основе алгоритмов iauGmst00 и iauGmst06 из библиотеки SOFA
  (должно удовлетворять резолюциям IERS) }
function GMSTime(UT1, TT: MType; theory2006: Boolean = true): MType;
var
	t_cent: MType;	// юлианские столетия
begin

	t_cent := (TT - J2000_Day) / JCentury;

  if theory2006 then
    result := AngleNormalize(deg2rad(ERA(UT1) +
                  (    0.014506     +
                  (  4612.156534    +
                  (     1.3915817   +
                  (    -0.00000044  +
                  (    -0.000029956 +
                  (    -0.0000000368 )
              * t_cent) * t_cent) * t_cent) * t_cent) * t_cent)))
  else
  	result := AngleNormalize(deg2rad(ERA(UT1) +
                  (    0.014506     +
                  (  4612.156534    +
                  (    1.39667721   +
                  (    -0.00009344  +
                  (      0.00001882 )
              * t_cent) * t_cent) * t_cent) * t_cent)));

end;


{ Гринвичское среднее звёздное время

  - это часовой угол средней точки весеннего равноденствия ♈сред на гринвичском
  меридиане.

  Гринвичское среднее звёздное время Sm является функцией всемирного вре-
  мени UT1. }
function ToGetGMSTime(UT1_jd: MType; Midnight: boolean = true): MType;
var
  // UT1, // содержит текущее значение всемирного времени в JD
  Tu, { время, отсчитываемое в юлианских столетиях по 36525 суток в системе
    всемирного времени UT1 от эпохи 2000, январь 1, 12h UT1 (MJD51544.5) }
  s0, // GMST в 0h UT1
  r: MType;
begin

  // UT1 := UT1_time(UTCmjd);
  Tu := (trunc(UT1_jd) - J2000_Day) / JCentury;

  s0 := 1.753368559233266 +
    (628.3319706888409 + (6.770713944903336E-06 - 4.508767234318685E-10 * Tu)
    * Tu) * Tu;

  r := 6.300388098984891 + (3.707456E-10 - 3.707E-14 * Tu) * Tu;

  if Midnight then
    result := s0
  else
    result := s0 + r * (UT1_jd - trunc(UT1_jd));
  { Промежуток звёездного времени от
    0h UT1 до момента, соответствующего
    моменту всемирного времени UT1 }

end;

{ Гринвичское истинное звёздное время

  - это часовой угол истинной точки весеннего равноденствия ♈ист на гринвичском
  меридиане.

  Гринвичское истинное звёездное время S есть угол от истинной точки весен-
  него равноденствия до гринвичского меридиана, отсчитываемый вдоль истинного
  экватора. }
function ToGetGASTime(UT1_mjd: MType): MType;
var
  s0, // Гринвичское среднее звёездное время
  eps, // Угол наклона мгновенной эклиптики к среднему подвижному экватору ε(t)
  long_nut // Параметр нутации Δψ(t) - нутация в долготе
    : MType;
begin

  s0 := ToGetGMSTime(UT1_mjd);

  // Угол наклона эклиптики и нутация в долготе так же определяется в UT1?
  // eps := GetEpsMean(UT1_mjd);
//  long_nut := Epheremides.GetEpheremides(UT1_mjd, true)[0];

  { Вычисление гринвичского истинного звёздного времени. Результат - угол }
  result := s0 + long_nut * cos(eps);

end;

(* Вариант для получения GMST

  LAMBDA - угол, на который смещён пункт наблюдателя относительно гринвича,
  восток +

  function LMST(MJD, LAMBDA: extended): extended;
  var
  MJD0, T, UT, GMST: extended;
  function FRAC(X: extended): extended;
  begin
  X := X - TRUNC(X);
  if (X < 0) then
  X := X + 1;
  FRAC := X
  end;

  begin
  MJD0:=TRUNC(MJD);     // Standard Pascal
  //    MJD0:=INT(MJD);     // TURBO Pascal
  //    MJD0 := LONG_TRUNC(MJD); // ST Pascal plus
  UT := (MJD - MJD0) * 24;
  T := (MJD0 - 51544.5) / 36525.0;
  GMST := 6.697374558 + 1.0027379093 * UT +
  (8640184.812866 + (0.093104 - 6.2E-6 * T) * T) * T / 3600.0;
  LMST := 24.0 * FRAC((GMST - LAMBDA / 15.0) / 24.0);
  end;
*)

end.
