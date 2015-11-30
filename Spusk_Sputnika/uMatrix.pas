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

    property Element[Index: integer]: MType read getElement write setElement; default;

  end;

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

	for i := 0 to getSize do
		res := res + sqr(Elements[i]);

	result :=  sqrt(res);
end;

procedure TDVector.setSize(i: integer);
begin
	SetLength(Elements, i); // новые элементы заполняются 0
end;

end.
