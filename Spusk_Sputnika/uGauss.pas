unit uGauss;

interface

uses
	uTypes;

function inverse(Original: TMatrix): TMatrix;

implementation


{ ��������� ������� ������� ������

	������ ���������� ������������� ������ ��� ������ 3�3 }
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
  divider, // ��������, ������ ��-���������� ����. ��������
  left_side, right_side, Det: MType;
begin

	Ed := InitialEd;
  Matr := Original;

  { ������ ��� }
  for i := 0 to m_size do
  begin

  	// ����� �� ������������ ������� 1
    if Matr[i][i] <> 1 then
    begin

      // ��������� ������� ������������ ������� �� 0
      if Matr[i][i] = 0 then
      begin

        k := i + 1;
        while ((Matr[k][i] = 0) AND (k <= m_size)) do inc(k);

        {
					�� ������ �� ����� � ������ ����� ��������� ���,
					��� ���� ������� �������. ����� ��������, �, �
					��������, ���� ������� ������� ���������� �� ����
					����.

					�� ��� ���� ��������, ��� det = 0. �� ����������
					��� ��������� �������, ��� ��������� ����� �����������.
					�� ��� ����,  ��� ����.

				}

        if Matr[k][i] <> 0 then
        begin

          divider := Matr[k][i];

          // �������� ����������� ������� � 1 (����� ������ �� ����)
          for p := 0 to m_size do
          begin

            Matr[i][p] := Matr[i][p] + Matr[k][p] / divider;
            Ed[i][p] := Ed[i][p] + Ed[k][p] / divider;

          end;

        end; // if Matr[k][i] <> 0

      end // if Matr[i][i] = 0
      else // ������������ ������� (!= 0 && != 1)
      begin

      	divider := Matr[i][i];

        // �������� ����������� ������� � 1 (����� ������ �� ����)
        for p := 0 to m_size do
        begin

        	Ed[i][p] := Ed[i][p] / divider;
          Matr[i][p] := Matr[i][p] / divider;

        end;

      end;

    end; // ���������� ������������ ������� � 1

    // �������� ������� � ������������ ����
    for j := i + 1 to m_size do  // ������������ ������

    	if Matr[j][i] <> 0 then // ���� ����� �� 0
      begin

        left_side := Matr[j][i];

        for p := 0 to m_size do  // �������������� ������
        begin

        	if Ed[i][p] <> 0 then // ���� ������ �� 0
						Ed[j][p] := Ed[j][p] - Ed[i][p] * left_side;

					if Matr[i][p] <> 0 then // ���� ������ �� 0
						Matr[j][p] := Matr[j][p] - Matr[i][p] * left_side;

        end;

      end; // if Matr[j][i] <> 0


  end; // ����� ������� ����

  // �������� ������������ �� 0
  det := 1;
  for i := 0 to m_size do
  	det := det * Matr[i][i];

	if det = 0 then
  begin

    result := Error;
    exit;

  end;

  // �������� ���
  for i := m_size downto 1 do // ������������ ������

    for j := i - 1 downto 0 do // ������������ ������

    	if Matr[j][i] <> 0 then // ���� ����� �� 0
      begin

      	right_side := Matr[j][i];

        for k := m_size downto 0 do // �������������� ������
        begin

        	if Ed[i][k] <> 0 then // ���� ����� �� 0
						Ed[j][k] := Ed[j][k] - Ed[i][k] * right_side;

					if Matr[i][k] <> 0 then // ���� ����� �� 0
						Matr[j][k] := Matr[j][k] - Matr[i][k] * right_side;

        end;

      end;

  // ����� ��������� ����

	result := Ed;

end; // inverse(Original: TMatrix)

end.
