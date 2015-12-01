unit uMatrix;

interface

{ Реализация линейной алгебры }

uses
  uTypes, Math;

//class TMatrix;
//class TSymmetricMatrix;

type

  // класс для вектора ----------------------------------
  TDVector = class(TObject)
  private
    Elements: array of MType;

    function getElement(Index: integer): MType;
    procedure setElement(Index: integer; value: MType);
  public
    // constructor пустой
    constructor Create; overload;

    // создаём вектор заданной длины
    constructor Create(n: integer); overload;

    // конструктор копии вектора arg
//    function Create(const arg: ^TDVector): TDVector; overload;

    function getSize: integer;
    function getLength: MType;

    procedure setSize(i: integer);

    function Add(SecVec: TDVector): TDVector;
    function ConstProduct(num: MType): TDVector;

    property Element[Index: integer]: MType read getElement write setElement; default;

    destructor Destroy; override;

  end;

  PDVector = ^TDVector;

implementation

{* * * * * * * * вектор * * * * * * * *}

constructor TDVector.Create;
begin
  inherited;

  SetLength(Elements, 1);
end;

constructor TDVector.Create(n: integer);
begin

  SetLength(Elements, n);
end;

destructor TDVector.Destroy;
begin

  setSize(0);

  inherited;
end;

function TDVector.getElement(Index: integer): MType;
begin
	result := Elements[Index];
end;

procedure TDVector.setElement(Index: integer; value: MType);
begin
	Elements[Index] := value;
end;

function TDVector.getSize: integer;
begin
	result := High(Elements) + 1;  // Нужно ли здесь прибавление 1
end;

function TDVector.getLength: MType;
var
  res: MType;
  i: integer;
begin
	res := 0;

	for i := 0 to getSize - 1 do
		res := res + sqr(Elements[i]);

	result :=  sqrt(res);
end;

procedure TDVector.setSize(i: integer);
begin
	SetLength(Elements, i); // новые элементы заполняются 0
end;

function TDVector.Add(SecVec: TDVector): TDVector;
var
	i: integer;

  res_vec: TDVector;
begin

  res_vec := TDVector.Create(getSize);

	for i := 0 to getSize - 1 do
    res_vec[i] := Elements[i] + SecVec[i];

  Result := res_vec;

end;

function TDVector.ConstProduct(num: MType): TDVector;
var
	i: integer;

  res_vec: TDVector;
begin

  res_vec := TDVector.Create(getSize);

	for i := 0 to getSize - 1 do
    res_vec[i] := Elements[i] * num;

  Result := res_vec;

end;

end.
