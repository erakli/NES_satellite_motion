unit uSputnik;

interface

uses
  System.Classes, uTypes, uConstants, uModel, uAtmosphericDrag,
  uGEO_Potential_new,
  uSunPressure, uMatrix, Math, uMatrix_Operations;

type
  TSputnik = class(TModel)
  private
  public
//    position: coordinates;
    mass, Cb_coeff, // баллистический коэффициент
    CrossSecArea,
    // площадь поперечного сечения (в нашей задаче они равны со _space)
    _space // s - площадь эффективного/поперечного сечения
      : MType;

    function getRight(X: PDVector; t: MType): TDVector; override;
    function Stop_Calculation(t, Step: MType; PrevStep, CurStep: PDVector)
      : boolean; override;

    constructor Create(newmass, newCb_coeff, newCrossSecArea, new_space: MType);
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

constructor TSputnik.Create(newmass, newCb_coeff, newCrossSecArea,
  new_space: MType);
begin
  inherited Create;

  StartValues := TDVector.Create(6);

  mass := newmass;
  Cb_coeff := newCb_coeff;
  CrossSecArea := newCrossSecArea;
  _space := new_space;
end;

function TSputnik.getRight(X: PDVector; t: MType): TDVector;
var
  _X, Y: TDVector;
  i: Integer;

  radius3: MType;

  coord, uskor,
  res1, res2
  	: TVector;

  Mas1, Mas2, Mas3: coordinates;
  Summ1: TVector;

  Summ2, tempDVec,
  standMotion
  	: TDVector;
begin

  Y := TDVector.Create(X.getsize);

  _X := X^;

  for i := 0 to 2 do
  begin
    coord[i] := _X[i];
    uskor[i] := _X[i + 3]; // ускорение за пред. шаг
  end;

  radius3 := pow3(module(coord));

  // далее идут костыльные костыли по скрещиванию динамического и константного векторов
	Mas2 := NullVec;

//  Mas1 := SunPressure.RightPart(t, coord, uskor, _space);
//  Mas2 := GEO_Potential_new.RightPart(t, coord, uskor);
//  Mas3 := AtmosphericDrag.RightPart(t, coord, uskor, Cb_coeff, CrossSecArea);

//  res1 := ConstProduct(1 / mass, Mas1);
//  res2 := ConstProduct(1 / mass, Mas3);

//  Summ1 := VecSum(res1, res2);
//  Summ2 := Perevod(VecSum(Mas2, Summ1)); // ускорение за этот шаг

//	Summ2 := Perevod(Mas1);
	Summ2 := VecToDVec(Mas2);
//	Summ2 := Perevod(Mas3);
//	Summ2 := Perevod(VecSum(mas1, Mas3));

	tempDVec := TDVector.Create(3);

	// вычисление невозмущённого движения
	for i := 0 to 2 do
  begin
  	tempDVec[i] := -fm * coord[i] / radius3;
  end;

  // получение возмущённого движения
  standMotion := tempDVec.Add(Summ2);

  tempDVec.Destroy;

  for i := 0 to 2 do
  begin
    Y[i] := uskor[i];
    Y[i + 3] := standMotion[i];
  end;

  result := Y; // заглушка
end;

function TSputnik.Stop_Calculation(t: Double; Step: Double; PrevStep: PDVector;
  CurStep: PDVector): boolean;
var
  CurVisota: MType;
begin
  CurVisota := PrevStep.getLength;
//	writeln(self.Result, 'h = ', FloatToStr(CurVisota - Earth.eq_rad));
  if CurVisota - Earth.eq_rad <= 0 then
    result := true
  else
  	result := false;
end;

destructor TSputnik.Destroy;
begin

  StartValues.Destroy;

  inherited;
end;

end.
