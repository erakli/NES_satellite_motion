unit uDormanPrince;

interface

{ Модуль реализации метода Дормана-Принса 4(5) порядка }

uses
  uTypes, uModel, uMatrix, Math;

const
  SIZE = 7;

type

  koef_vec = array[0..SIZE - 1] of MType;
  koef_matr = array[0..SIZE - 1, 0..SIZE - 1] of MType;

  PModel = ^TModel;

  TIntegrator = class(TObject)
  protected
    _Step, t: MType;
    CurModel: ^TModel;

    procedure setStep(const arg: MType);
  public
    constructor Create;

    property Step: MType read _Step write setStep;

    procedure Run(Model: PModel); virtual; abstract; // pure virtual function
  end;

  TDormanPrince = class(TIntegrator)
  private
    c,  // вектор-столбец слева от таблицы
    b,  // вектор-строка снизу таблицы
    b1  // вектор-строка ниже b
      : koef_vec;
    A: koef_matr;   // так называемая нижне тругольная матрица Бутчера
    k: array[0..SIZE] of TDVector;  // вспомогательные коэффициенты

    _Eps, // Относительная вычислительная ошибка (локальная погрешность)
    _Eps_Max, // максимальная относительная вычислительная ошибка
    _Eps_Global
      : MType;

    x0, // начальные значения
    x1, _x1 // конечные для шага (4 и 5 порядка)
      : TDVector;

    x_size: integer; // длина вектора начальных значений

    _iter: integer; // счётчик количества итераций

    procedure StepCorrection; // управление длиной шага интегрирования
    procedure getEps;

    procedure setEps(const arg: MType);
    procedure setEps_Max(const arg: MType);

    function RoundingError: MType;

    procedure set_k(_size: integer);

    function thick_extradition(Teta, Step: MType): TDVector; // плотная выдача

    procedure set_c;
    procedure setA;
    procedure set_b;
    procedure set_b1;

  public

    constructor Create;
    procedure Run(Model: PModel);

    property Eps: MType read _Eps write setEps;
    property Eps_Max: MType read _Eps_Max write setEps_Max;
    property Eps_Global: MType read _Eps_Global;
    property iter: integer read _iter;

  end;

//function SetValues(values: array of MType): TDVector;

implementation

//function SetValues(values: array of MType): TDVector;
//var
//  Res: TDVector;
//  i: byte;
//begin
//	Res := TDVector.Create(SIZE);
//
//	for i := 0 to SIZE do
//	begin
//		Res[i] = values[i];
//	end;
//
//	result := Res;
//end;

{* * * * * * * * * * TIntegrator * * * * * * * * * *}
constructor TIntegrator.Create;
begin
  inherited;
	_Step := 1;
end;

procedure TIntegrator.setStep(const arg: MType);
begin
	_Step := arg;
end;

{* * * * * * * * * * TDormanPrince * * * * * * * * * *}
constructor TDormanPrince.Create;
var
  i: integer;
begin

	// инициализируем все коэффициенты
//	c := TDVector.Create(SIZE);
//	b := TDVector.Create(SIZE);
//	b1 := TDVector.Create(SIZE);

  for i := 0 to SIZE do
    k[i] := TDVector.Create;

	// заполняем
	set_c();
	set_b();
	set_b1();
	setA();

	_Step := 1.0e-3;
	_Eps := 1.0e-5;
	_Eps_Max := 1.0e-17;
	_Eps_Global := 0;

	_iter := 0; // количество итераций

end;

{
------------- основная функция
}
procedure TDormanPrince.Run(Model: PModel);
var
  i, j: integer;

  tout,
  PrevStep,
  Teta
    : MType;

  sum, sum_1,
  Xout
    : TDVector;
begin

	CurModel := Model; // Храним адрес модели для внутренних нужд

	// инициализируем время начальным его значением из модели
	t := CurModel.t0;
	x0 := CurModel.getStart;

	// вычисляем размер фазового вектора
	x_size := x0.getSize;

	tout := t; // Для плотной выдачи
	PrevStep := 0; // храним знание о предыдущем шаге

  Xout := TDVector.Create; // сюда записываются значения с учётом коэф. плотной выдачи

	{
		основной цикл вычисления
	}
	while t < CurModel.t1 do
	begin
		// необходим контроль количества итераций
		if iter < 50000 then inc(_iter)
		else
			break;

		set_k(x_size);

		sum := TDVector.Create(x_size);
    sum_1 := TDVector.Create(sum);

		for i := 0 to x_size do // проходим по элементам вектора Х
		begin
			for j := 0 to SIZE - 1 do // собираем воедино все k
			begin
				sum[i] := sum[i] + b[j] * k[j][i];
				sum_1[i] := sum_1[i] + b1[j] * k[j][i];
			end;
		end;

		{
			прибавляем к вектору начальных условий
			вектор результатов интегрирования.
			для 4 и 5 порядка
		}
		x1 := x0 + sum * Step;
		_x1 := x0 + sum_1 * Step;

		PrevStep := Step; // Запомнили шаг до конца этой итерации
		getEps();
		StepCorrection();

		// если мы не довольны ошибкой, уточняем шаг с текущим t
		if Eps > Eps_Max then	continue; // ------------------- основной перевалочный пункт

		Eps_Global := Eps_Global + Eps; // считаем глобальную погрешность как сумму локальных

		// если приращение координаты менее заданного условия прерываем процесс
		if CurModel.Stop_Calculation(t, PrevStep, x0, x1) then break;

		{
			Плотная выдача. Результаты уходят в матрицу
			результатов модели
		}

		while (tout < t + PrevStep) AND (tout < CurModel.t1) do
		begin
			Teta := (tout - t) / PrevStep;
			Xout := thick_extradition(Teta, PrevStep);
			CurModel.addResult(Xout, tout);
			tout := tout + CurModel.Interval;
		end;

		x0 := x1; // на выход отдаём результат 4 порядка (принимая его основным)
		t := t + PrevStep;
	end;
end;

{*
------------- Вычисление k-элементов
*}
procedure TDormanPrince.set_k(_size: integer);
var
  s, i, j: integer;

  sum: TDVector;
begin

	k[0] = CurModel.getRight(x0, t);

	for s := 1 to SIZE - 1 do // двигаемся по вектору вниз (по строкам)
	begin
		// инициализируем элементы-векторы вектора вспомогательных коэфф.
		k[s].setSize(_size);

		sum := TDVector.Create(_size);

		for i := 0 to s do // проходим по строкам A, складывая их
		begin
			{
				гуляем по вектор функциям.
				sum - сумма (та, что в скобках) произведений коэффициентов для каждой
				вектор-функции (которые вычисляются под k)
			}
			for j := 0 to _size do
			begin
				sum[j] := sum[j] + A[s][i] * k[i][j];
			end;
		end;

		k[s] = CurModel.getRight(x0 + sum * Step, t + c[s] * Step);
	end;
end;

{*
------------- Плотная выдача.
	Необходима для записи результатов на подшагах.
*}
function TDormanPrince.thick_extradition(Teta, Step: MType): TDVector;
const
  b_size = 6;
var
  sqrTeta: MType;

  b, sum: TDVector;

  i, j: integer;
begin
	sqrTeta = sqr(Teta); // квадрат от тета

	b := TDVector.Create(b_size);

	b[0] := Teta *
		(1.0 + Teta *
		(-1337.0 / 480 + Teta * (1039.0 / 360 + Teta * (-1163.0 / 1152))));

	b[1] := 0;

	b[2] := 100.0 * sqrTeta *
		(1054.0 / 9275 + Teta * (-4682.0 / 27825 + Teta * (379.0 / 5565))) / 3;

	b[3] := -5.0 * sqrTeta * (27.0 / 40 + Teta * (-9.0 / 5 + Teta * (83.0 / 96))) / 2;

	b[4] := 18225.0 * sqrTeta *
		(-3.0 / 250 + Teta * (22.0 / 375 + Teta * (-37.0 / 600))) / 848;

	b[5] := -22.0 * sqrTeta *
		(-3.0 / 10 + Teta * (29.0 / 30 + Teta * (-17.0 / 24))) / 7;


	sum := TDVector.Create(x_size);
	for i := 0 to x_size do
	begin
		for j := 0 to b_size do
		begin
			sum[i] := sum[i] + b[j] * k[j][i];
		end;
	end;

	result := x0 + sum * Step;

end;

{*
------------- Коррекция текущего шага на основе погрешности
*}
procedure TDormanPrince.StepCorrection;
var
  min_part: MType;
begin
	min_part =
			min(5.0, power(Eps / Eps_Max, 0.2) / 0.9);

	Step := Step / max(0.1, min_part);
end;

{*
------------- Получение локальной погрешности
*}
procedure TDormanPrince.getEps;
var
  numerator, denominator, fraction
    : TDVector;

  u: MType;
  i: integer;
begin

	// числитель и знаменатель дроби под корнем
	numerator := TDVector.Create(x_size);
  denominator := TDVector.Create(x_size);
  fraction := TDVector.Create(x_size);

	u := RoundingError; // вычисление ошибки округления

	for i := 0 to x_size do
	begin
		numerator[i] := Step * (x1[i] - _x1[i]);
		denominator[i] :=
			max(
        max(1.0e-5, abs(x1[i])),
        max(abs(x0[i]), 2.0 * u / Eps_Max)
			);
		fraction[i] := numerator[i] / denominator[i];
	end;

	// воспользовались нахождением длины вектора
	Eps := fraction.getLength / sqrt(x_size);

end;

function TDormanPrince.RoundingError: MType;
var
  v, u: MType;
begin
	v := (1);

	while 1 + v > 1 do
	begin
		u := v;
		v := v / 2;
	end;

	result := u;
end;

// -------------- вспомогательные коэффициенты
procedure TDormanPrince.set_c;
const
  prep: koef_vec = (0, 0.2, 0.3, 0.8, 8.0 / 9, 1, 1);
begin
	c := prep;
end;

procedure TDormanPrince.setA;
const
  prep: koef_matr =
  (
    ( 0, 0, 0, 0, 0, 0, 0 ),
		( 0.2, 0, 0, 0, 0, 0, 0 ),
		( 3.0 / 40, 9.0 / 40, 0, 0, 0, 0, 0 ),
		( 44.0 / 45, -56.0 / 15, 32.0 / 9, 0, 0, 0, 0 ),
		( 19372.0 / 6561, -25360.0 / 2187, 64448.0 / 6561, -212.0 / 729, 0, 0, 0  ),
		( 9017.0 / 3168, -355.0 / 33, 46732.0 / 5247, 49.0 / 176, -5103.0 / 18656, 0, 0 ),
		( 35.0 / 384, 0, 500.0 / 1113, 125.0 / 192, -2187.0 / 6784, 11.0 / 84, 0, 0 )
  );
begin
  A := prep;
end;

procedure TDormanPrince.set_b;
const
  prep: koef_vec = ( 35.0 / 384, 0, 500.0 / 1113, 125.0 / 192, -2187.0 / 6784, 11.0 / 84, 0 );
begin
	b := prep;
end;

procedure TDormanPrince.set_b1;
const
  prep: koef_vec = ( 5179.0 / 57600, 0, 7571.0 / 16695, 393.0 / 640, -92097.0 / 339200, 187.0 / 2100, 1.0 / 40 );
begin
	b1 := prep;
end;


// ------------ инкапсуляция
procedure TDormanPrince.setEps_Max(const arg: MType);
begin
	_Eps_Max := arg;
end;

procedure TDormanPrince.setEps(const arg: MType);
begin
	_Eps := arg;
end;

end.
