unit uPrecNut;

interface

{ Алгоритмы вычисления матрицы прецессии и матрицы нутации

  }

uses
  uConstants, uMatrix_Operations, uFunctions,
   uPrecNut_InitialParam; // здесь

type

	TCIP_Tranform_Matrix = class  // Матрица Q(t)
  private

  	X, Y, { Координаты CIP в GCRS }

    s     { s being a quantity, named "CIO locator", which provides the position
    				of the CIO on the equator of the CIP corresponding to the kinematical
            defnition of the NRO in the GCRS when the CIP is moving with respect
            to the GCRS, between the reference epoch and the date t due to
            precession and nutation }
     : double;


  	{* * * The fundamental arguments of nutation theory * * *}

    {*	The arguments of lunisolar nutation (0..4)
    	+ the arguments for the planetary nutation (5..13) *}

  	Fa: array[0..FA_SIZE] of double; // t is measured in Julian centuries of TDB

    { Инициализация данных }
    procedure FaInit(t: double);

    { Вычисление X и Y }
    function getX(t: double): double;
    function getY(t: double): double;

  public

  	function getQ_Matrix(t: double): TMatrix;

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

procedure TCIP_Tranform_Matrix.FaInit(t: double);   // t is measured in Julian centuries
var
	l, l_, F, D, Om: double;
begin

	// придумать оптимизацию, написать описания

	l :=  asec2rad(134.96340251 * 3600 + 1717915923.2178 * t + 31.8792 * pow2(t)
  			+ 0.051635 * pow3(t) - 0.0002447 * pow4(t));

  l_ := asec2rad(357.52910918 * 3600 + 129596581.0481 * t - 0.5532 * pow2(t)
  			+ 0.000136 * pow3(t) - 0.00001149 * pow4(t));

  F := asec2rad(93.27209062 * 3600 + 1739527262.8478 * t - 12.7512 * pow2(t)
  		 - 0.001037 * pow3(t) + 0.00000417 * pow4(t));

  D := asec2rad(297.85019547 * 3600 + 1602961601.209 * t - 6.3706 * pow2(t)
			 + 0.006593 * pow3(t) - 0.00003169 * pow4(t));

  Om := asec2rad(125.04455501 * 3600 - 6962890.5431 * t + 7.4722 * pow2(t)
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

function TCIP_Tranform_Matrix.getQ_Matrix(t: double): TMatrix;
begin

end;

function TCIP_Tranform_Matrix.getX(t: double): double;
begin

end;

function TCIP_Tranform_Matrix.getY(t: double): double;
begin

end;

end.
