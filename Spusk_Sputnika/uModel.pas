unit uModel;

interface

{ ћодуль с базовым классом модели

  Ќадо придумать с TDVector }

uses
  uTypes, Math, uMatrix, SysUtils;

type

  TModel = class(TObject)
  protected
    StartValues: TDVector;
    s_size: byte; // длина вектора StartValues

    _Interval, // должен ли быть интервал между знач. задан тут?
    _t0, _t1
      : MType;

    Result: TextFile;

    // ќстановка интегрировани€ при малых изменени€х приращени€ координаты
    stop_condition: MType;
    stop_count, stop_count_max: byte;
    stop_flag: boolean;

    procedure set_t0(const arg: MType);
    procedure set_t1(const arg: MType);
    procedure setInterval(const arg: MType);

  public
    constructor Create;

    function getRight(X: PDVector; t: MType): TDVector; virtual; abstract;

    procedure addResult(X: PDVector; t: MType);

    // инкапсул€ци€ в чистом виде
    procedure setStart(arg: PDVector);
    function getStart: TDVector;

    property t0: MType read _t0 write set_t0;
    property t1: MType read _t1 write set_t1;
    property Interval: MType read _Interval write setInterval;

//    function getResult: TMatrix;

    function Stop_Calculation(t, Step: MType; PrevStep, CurStep: PDVector): boolean; virtual; abstract;

    destructor Destroy; override;

  end;

  TArenstorfModel = class(TModel)
  private
    m, big_M: MType;

  public
    Period: MType;  // ѕериод обращени€ конкретной орбиты
    orbit: byte; // ¬ыбор орбиты (мала€/больша€)

    constructor Create(variant: byte);
    function getRight(X: PDVector; t: MType): TDVector; override;

    // заглушка
    function Stop_Calculation(t, Step: MType; PrevStep, CurStep: PDVector): boolean; override;
  end;

  PModel = TModel;

implementation

{* * * * * * * * * * TModel * * * * * * * * * *}

constructor TModel.Create;
const
  output_file = 'output.txt';
begin
	Interval := 0.1; // перенести на ручной ввод
	t0 := 0;
	t1 := 5;

	stop_count := 0;
	stop_count_max := 5;
	stop_flag := false;

  AssignFile(Result, 'C:\' + output_file);
  ReWrite(Result);
end;

destructor TModel.Destroy;
begin

  CloseFile(Result);
//  StartValues.Destroy;

  inherited;
end;

procedure TModel.addResult(X: PDVector; t: MType);
var
//  Row: integer;
//  compile: TDVector;

  i: byte;
begin
  write(Result, FloatToStr(t), '  ');

  for i := 0 to X.getSize - 1 do
    write(Result, X^[i], ' ');

  writeln(Result);

//	Row := Result.getRowCount;
//	compile(s_size + 1); // вектор результата + врем€
//
//	{
//		по хорошему, стоит ввести обработчик,
//		который будет добавл€ть строки в матрицу,
//		не переписыва€ еЄ с нул€
//	}
//	Result.setSize(Row + 1, s_size + 1);
//
//	compile[0] = t; // первым элементом идЄт врем€ - дл€ удобства выборки
//	for i := 1 to s_size do
//	begin
//		compile[i] := X[i - 1];
//	end;
//
//	Result[Row] := compile; // последней строке должен быть назначен итоговый вектор
end;

// ----- свойства
function TModel.getStart: TDVector;
begin
  result := StartValues;
end;

//function TModel.getResult: TMatrix;
//begin
//	result := Result;
//end;

procedure TModel.setStart(arg: PDVector);
begin
	StartValues := arg^;
end;

procedure TModel.setInterval(const arg: MType);
begin
	_Interval := arg;
end;

procedure TModel.set_t0(const arg: MType);
begin
	_t0 := arg;
end;

procedure TModel.set_t1(const arg: MType);
begin
	_t1 := arg;
end;
// ----- конец свойств


{* * * * * * * * * * TArenstorfModel * * * * * * * * * *}

constructor TArenstorfModel.Create(variant: byte);
begin

  inherited Create;

	StartValues := TDVector.Create(4);
	s_size := StartValues.getSize;

	m := 0.012277471;
	big_M := 1 - m;

	orbit := variant;

	StartValues[0] := 0.994; // y1
	StartValues[1] := 0;     // y2
	StartValues[2] := 0;     // y1'
	if orbit = 1 then // выбираем большую орбиту
	begin
		StartValues[3] := -2.00158510637908252240537862224; // y2'
		Period := 17.0652165601579625588917206249;
	end
	else // иначе малую
	begin
		StartValues[3] := -2.0317326295573368357302057924; // y2'
		Period := 11.124340337266085134999734047;
	end;
end;

function TArenstorfModel.getRight(X: PDVector; t: MType): TDVector;
var
  _X, Y: TDVector;
  R: array[0..1] of MType;
begin
	Y := TDVector.Create(s_size);

  _X := X^;

  R[0] := power(power(_X[0] + m, 2) + power(_X[1], 2), 1.5);
  R[1] := power(power(_X[0] - big_M, 2) + power(_X[1], 2), 1.5);

	Y[0] := _X[2]; // v1 = y1' - замена переменной. ѕосле интегрировани€ получим y1
	Y[1] := _X[3]; // v2 = y2'
	Y[2] := _X[0] + 2 * _X[3] - big_M * (_X[0] + m) / R[0] - m * (_X[0] - big_M) / R[1];
	Y[3] := _X[1] - 2 * _X[2] - big_M * _X[1] / R[0] - m * _X[1] / R[1];

	result := Y; // заглушка
end;

function TArenstorfModel.Stop_Calculation(t, Step: MType; PrevStep,
  CurStep: PDVector): boolean;
begin

  result := false;

end;

end.
