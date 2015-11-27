unit uGauss;

interface

uses
	uTypes;

function inverse(Original: TMatrix): TMatrix;

implementation


{ Обращение матрицы методом Гаусса

	Данная реализация предназначена только для матриц 3х3 }
function inverse(Original: TMatrix): TMatrix;
const
	InitialEd: TMatrix =
  	((1, 0, 0),
     (0, 1, 0),
     (0, 0, 1));
  Error: TMatrix =
  	((-1, 0, 0),
     (0, -1, 0),
     (0, 0, -1));
var
	Ed, Matr: TMatrix;
  i, j, k, p: byte;
  divider, // делитель, равный не-единичному диаг. элементу
  left_side, right_side, Det: MType;
begin

	Ed := InitialEd;
  Matr := Original;

  { прямой ход }
  for i := 0 to m_size do
  begin

  	// равен ли диагональный элемент 1
    if Matr[i][i] <> 1 then
    begin

      // проверили текущий диагональный элемент на 0
      if Matr[i][i] = 0 then
      begin

        k := i + 1;
        while ((Matr[k][i] = 0) AND (k <= m_size)) do inc(k);

        {
					на выходе из цикла в теории может оказаться так,
					что весь столбец нулевой. такое возможно, и, в
					принципе, надо сделать проброс исключения на этот
					счёт.

					но это лишь означает, что det = 0. Мы собираемся
					это проверять снаружи, что исключает такую возможность.
					но она есть,  это факт.

				}

        if Matr[k][i] <> 0 then
        begin

          divider := Matr[k][i];

          // приводим диагоальный элемент к 1 (делим строку на него)
          for p := 0 to m_size do
          begin

            Matr[i][p] := Matr[i][p] + Matr[k][p] / divider;
            Ed[i][p] := Ed[i][p] + Ed[k][p] / divider;

          end;

        end; // if Matr[k][i] <> 0

      end // if Matr[i][i] = 0
      else // диагональный элемент (!= 0 && != 1)
      begin

      	divider := Matr[i][i];

        // приводим диагоальный элемент к 1 (делим строку на него)
        for p := 0 to m_size do
        begin

        	Ed[i][p] := Ed[i][p] / divider;
          Matr[i][p] := Matr[i][p] / divider;

        end;

      end;

    end; // приравняли диагональный элемент к 1

    // приводим матрицу к треугольному виду
    for j := i + 1 to m_size do  // вертикальный индекс

    	if Matr[j][i] <> 0 then // если сбоку не 0
      begin

        left_side := Matr[j][i];

        for p := 0 to m_size do  // горизонтальный индекс
        begin

        	if Ed[i][p] <> 0 then // если сверху не 0
						Ed[j][p] := Ed[j][p] - Ed[i][p] * left_side;

					if Matr[i][p] <> 0 then // если сверху не 0
						Matr[j][p] := Matr[j][p] - Matr[i][p] * left_side;

        end;

      end; // if Matr[j][i] <> 0


  end; // конец прямого хода

  // проверка определителя на 0
  det := 1;
  for i := 0 to m_size do
  	det := det * Matr[i][i];

	if det = 0 then
  begin

    result := Error;
    exit;

  end;

  // обратный ход
  for i := m_size downto 1 do // диагональный индекс

    for j := i - 1 downto 0 do // вертикальный индекс

    	if Matr[j][i] <> 0 then // если сбоку не 0
      begin

      	right_side := Matr[j][i];

        for k := m_size downto 0 do // горизонтальный индекс
        begin

        	if Ed[i][k] <> 0 then // если снизу не 0
						Ed[j][k] := Ed[j][k] - Ed[i][k] * right_side;

					if Matr[i][k] <> 0 then // если снизу не 0
						Matr[j][k] := Matr[j][k] - Matr[i][k] * right_side;

        end;

      end;

  // конец обратного хода

	result := Ed;

end; // inverse(Original: TMatrix)

end.
