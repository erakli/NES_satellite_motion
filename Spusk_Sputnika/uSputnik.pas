unit uSputnik;

interface

uses
  System.Classes, uTypes, uConstants, uModel, uAtmosphericDrag,
  uGEO_Potential_new,
  uSunPressure, uMatrix, Math, uMatrix_Operations;

type
  TSputnik = class(TModel)
  private
  	ForcesResult: TextFile;
  	GEO_force: coordinates;
  public
//    position: coordinates;
    mass, Cb_coeff, // баллистический коэффициент
    CrossSecArea,
    // площадь поперечного сечения (в нашей задаче они равны со _space)
    _space // s - площадь эффективного/поперечного сечения
      : MType;

//    modellingNum, initParam: string; // для SQL

		Forces: TBoolVec;  // вектор флагов о наличии возмущений

    function getRight(X: PDVector; t: MType): TDVector; override;
    function Stop_Calculation(t, Step: MType; PrevStep, CurStep: PDVector)
      : boolean; override;
    procedure addResult(X: PDVector; t: MType); override;

    procedure CreateResult; override;
    procedure CloseResult; override;

    constructor Create; overload;
    constructor Create(newmass, newCb_coeff, newCrossSecArea, new_space: MType); overload;
    destructor Destroy; override;
  end;

function VecToDVec(Mas: TVector): TDVector;

var
  Sputnik: TSputnik;

implementation // --------------------------------------------------------------

uses SysUtils, uFunctions;

function VecToDVec(Mas: TVector): TDVector;
var
  i: Integer;
  H: TDVector;
begin
  H := TDVector.Create(high(Mas) + 1);
  for i := 0 to high(Mas) do
    H[i] := Mas[i];
  result := H;
end;

{ TSputnik }

constructor TSputnik.Create;
var
	i: byte;
begin
  inherited Create;

  Interval := 1;

  for i := 0 to ForcesNum do
  	Forces[i] := false;

//  StartValues := TDVector.Create(6);

  mass := 417289;
  Cb_coeff := 2.2;
  CrossSecArea := 3;
  _space := 3;

  GEO_force := NullVec;
end;

constructor TSputnik.Create(newmass, newCb_coeff, newCrossSecArea,
  new_space: MType);
var
	i: byte;
begin
  inherited Create;

  Interval := 1;

  for i := 0 to ForcesNum do
  	Forces[i] := false;

  StartValues := TDVector.Create(6);

  mass := newmass;
  Cb_coeff := newCb_coeff;
  CrossSecArea := newCrossSecArea;
  _space := new_space;

  GEO_force := NullVec;
end;

function TSputnik.getRight(X: PDVector; t: MType): TDVector;
var
  Y: TDVector;
  i: Integer;

  radius3: MType;

  coord, speed
//  , res1, res2
  	: TVector;

  Mas1, Mas2, Mas3: coordinates;
  Summ1: TVector;

  Summ2,
  standMotion
  	: TDVector;
begin

  Y := TDVector.Create(X.getsize);

  for i := 0 to 2 do
  begin
    coord[i] := X^[i];
    speed[i] := X^[i + 3]; // ускорение за пред. шаг
  end;

  radius3 := pow3(module(coord));

  // далее идут костыльные костыли по скрещиванию динамического и константного векторов
//  Mas1 := NullVec;
	Mas2 := NullVec;
//  Mas3 := NullVec;

	if Forces[0] then
  	Mas1 := SunPressure.RightPart(t / SecsPerDay, coord, speed, _space);

  if Forces[1] then
  	Mas2 := GEO_Potential_new.RightPart(t / SecsPerDay, coord, speed);

  GEO_force := Mas2;

  if Forces[2] then
  	Mas3 := AtmosphericDrag.RightPart(t / SecsPerDay, coord, speed, Cb_coeff, CrossSecArea);

//  res1 := ConstProduct(1 / mass, Mas1);
//  res2 := ConstProduct(1 / mass, Mas3);

//  Summ1 := VecSum(res1, res2);
//  Summ2 := Perevod(VecSum(Mas2, Summ1)); // ускорение за этот шаг

//	Summ2 := Perevod(Mas1);
	Summ2 := VecToDVec(Mas2);
//	Summ2 := Perevod(Mas3);
//	Summ2 := Perevod(VecSum(mas1, Mas3));

	standMotion := TDVector.Create(3);

	// вычисление невозмущённого движения + возмущённое
	for i := 0 to 2 do
  begin
  	standMotion[i] := -fM * coord[i] / radius3 + Summ2[i];
  end;

  Summ2.Destroy;

  for i := 0 to 2 do
  begin
    Y[i] := speed[i];
    Y[i + 3] := standMotion[i];
  end;

  standMotion.Destroy;

  result := Y; // заглушка
end;

function TSputnik.Stop_Calculation(t: Double; Step: Double; PrevStep: PDVector;
  CurStep: PDVector): boolean;
var
  i: byte;
  coord: TDVector;
  CurVisota: MType;
begin
  coord := TDVector.Create(3);
  for i := 0 to 2 do
    coord[i] := PrevStep^[i];
  CurVisota := coord.getLength;
//	writeln(self.Result, 'h = ', FloatToStr(CurVisota - Earth.eq_rad));
  if CurVisota - Earth.eq_rad <= 0 then
    result := true
  else
  	result := false;

  coord.Destroy;
end;

procedure TSputnik.addResult(X: PDVector; t: MType);
var
  i: byte;

//  ADDcoordAndSpeed, coordAndSpeed, ADDresult: string;
begin
  write(Result, FloatToStr(t - t0), '	');
  write(ForcesResult, FloatToStr(t - t0), '	');

  for i := 0 to 2 do
  begin
    write(Result, X^[i], '	');
    write(ForcesResult, GEO_force[i], '	');
  end;

  for i := 3 to 5 do
    write(Result, X^[i], '	');

  write(Result, sqrt(sqr(X^[0]) + sqr(X^[1]) + sqr(X^[2])) );

  writeln(Result);
  writeln(ForcesResult);

  // дополнительно пишем в БД
//  with Main_Window.ADOQuery1 do
//  begin
//    SQL.Clear;
//    ADDcoordAndSpeed :=
//    			'INSERT into [Coordinates and Speed](X, Y, Z, Vx, Vy, Vz) values('
//            + FloatToStr(X^[0]) + ' , ' + FloatToStr(X^[1]) + ', ' + FloatToStr(X^[2]) + ', '
//            + FloatToStr(X^[3]) + ', ' + FloatToStr(X^[4]) + ', ' + FloatToStr(X^[5])  + ') ';
//
//    SQL.Add(ADDcoordAndSpeed);
//    SQL.Add('SELECT scope_identity() from [Coordinates and Speed]');
//    Open;
//    coordAndSpeed := Fields[0].AsString;
//
//    SQL.Clear;
//    ADDresult :=
//    			'INSERT into Result(Modelling, CoordinatesAndSpeed) values('
//            + modellingNum + ' , ' + coordAndSpeed + ') ';
//
//    SQL.Add(ADDresult);
//    ExecSQL;
//  end;

end;

procedure TSputnik.CreateResult;
const
  output_forces = 'output_forces.txt';
begin
  inherited;
  AssignFile(ForcesResult, 'C:\' + output_forces);
  ReWrite(ForcesResult);
end;

procedure TSputnik.CloseResult;
begin
	inherited;
  CloseFile(ForcesResult);
end;

destructor TSputnik.Destroy;
begin

//	// проверить очистку данного вектора
//  StartValues.Destroy;

  inherited;
end;

end.
