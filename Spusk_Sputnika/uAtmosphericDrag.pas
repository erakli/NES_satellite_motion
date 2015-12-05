unit uAtmosphericDrag;

{ ����������:
  � ������ ���������� ������������ �������������� ������������.

  ����� ����� ��������, ��� Kp ������ �����. � ������ ��������� ����� �
  ��������� ������� ����� ����� ����������� Ap, ������� ���� ����������
  �� ������� � ���������� � ���������.

  ��� ��, ��� �������� ����� ��������� � ������, ����� ����� ���������� �
  ��������� � ����� � ������������� ��� ��������������� (stand-91.doc)


  ! ��������, � ������� getF0_Kp ���� ������, �� ������� ���������� ��������
  ��������! }

interface

uses
  Math, System.SysUtils, Dialogs,
  uConstants,
  uTime,
  uTypes,
  uFunctions, uStarTime, uMatrix_Operations,
  uAtmospericDrag_Coeff, uMatrix_Conversation;

const
//  AD_coef_A = 'AD_coef_A.txt';
//  AD_coef_1 = 'AD_coef_1.txt';
//  AD_coef_2 = 'AD_coef_2.txt';
  F10_7_and_Kp = 'solarinex.txt';

type

  // vectors = (a, b, c, n, fi_1, d, e, l);

  TAtmosphericDrag = class(TObject)
  private
    { �������� ������� ���������� ��������� ���������: }
    F10_7: MType; { [10^-22 * �� * �^-2 * ��^-1]
      �������������� ������ ��������� ���������� }

    F81: MType; { ���������������� ������. ��������� ���������� F10_7
      �� 81 ����� (��� ������� ������ ������) }

    F0: word; { ������������� ������� ��������� ����������.
      ���������������� ������ F81, ������� 25 }

    Kp: byte; { [�����] �������������������� ����������� �������������� ������
      ������������ ������������� }

    time: MType; // [���] ��������� �����
    days: word; // ����� ����� �� ������ ����

    { ���������, �����������:
      K[0] - ��������� ��������� ���������, ��������� � ����������� F81 �� F0
      K[1] - �������� ������ � ������������� ���������
      K[2] - ����������� ������
      K[3] - ��������� ���������, ��������� � ����������� F10,7 �� F81
      K[4] - ����������� ��������� ��������� �� ������������ ������������� }
    K: TCoefVect;

    { ������������ ������, ������������ ��� ������� ��������� ��������� ���
      ��������� ��������� �������������� ������ ��������� ���������� F0: }
    // ��� ro_0 (densityNight)
    den_a: array [0 .. NUM_OF_den_A] of MType;

    // ��� �0
    l: TCoefVect;

    // ��� �1
    _�: TCoefVect;

    // Sun : TSun;     // ��������� ������ - ���������� �� ������

    { �������� ����� � ����������� �������: }
    S_time: MType; // [���]

    { ����������� ������, ������ ���� ������������ ��������� ���������
      �� ��������� � ��������� ������������: }
    fi_1: MType; // [���]
    n: array [0 .. NUM_OF_N] of MType;

    // ��� �2
    d: TCoefVect;
    A: array [0 .. NUM_OF_A] of MType; // ������������ ��������� A(d) ��� �2

    // ��� �3
    b: TCoefVect;

    // ��� �4
    e: array [0 .. NUM_OF_E] of MType;

    // ������������ ��� ���������� ��������� �� ������ <120 km
    h_i, // [km] ������ ������� ����
    a0, // [��/�^3]
    k1, // [1/��]
    k2 // [1/��^2]
      : MType;

    memo_ro: byte; { ����� ����, � ������� �� �� ����� ����������. ���
      �������������� ��������� ���� memo_ro, �������
      ������������ }

    // function module(coord : coordinates) : MType; // ������ ��� ���������
    function height(coord: coordinates): MType; // [km]
    function series(h: MType; x: array of MType; n: byte; plus: boolean): MType;

    function densityNight(h: MType): MType;
    function density(t: MType; coord: coordinates): MType;
    // [��/�^3] - ���������� ���������

    function setK(h: MType; Index: byte; Value: coordinates): MType;
    function setA(d: word): MType;

    procedure getCoeffForK(F0: word; h: MType; vec: char);
    procedure getF0_Kp(t: MType);

    function ReadValue(text: string; flag: byte): MType;

    function SetTime(Value: MType): MType;
//    function SetDays(Value: MType): word;
  public
    function RightPart(JD: MType; coord, v: coordinates; Cb_coeff, CrossSecArea: MType)
      : coordinates;

    constructor Create;
    destructor Destroy; override;
  end;

var
  AtmosphericDrag: TAtmosphericDrag;

implementation

// ---------------------------------------------------------------

constructor TAtmosphericDrag.Create;
var
//  f: TextFile;
//  temp_text: string;
  i: byte;
begin

  inherited;

  memo_ro := 0;

  for i := 0 to High(A) do
  	A[i] := AD_coef_A[i];

//  AssignFile(f, file_dir + AD_coef_A);
//  Reset(f);
//
//  for i := Low(A) to High(A) do
//  begin
//    ReadLn(f, temp_text);
//    A[i] := StrToFloat(Copy(temp_text, pos(deletimer, temp_text) + 1,
//      length(temp_text)));
//  end;
//
//  CloseFile(f);

end;

destructor TAtmosphericDrag.Destroy;
begin
  inherited;
end;


// function TAtmosphericDrag.module(coord : coordinates) : MType;
// begin
//
// with coord do
// result := sqrt( sqr(x) + sqr(y) + sqr(z) );
//
// end;

{ ���������� ������ ��� ������ ����������. ����� �������� }
function TAtmosphericDrag.height(coord: coordinates): MType;
var
  dist: MType;
begin

  dist := module(coord);

  // �������������� ������ ��������� � �� (��� ��� ���� �������� � ��)
  with Earth do
    result := dist - eq_rad / 1000 * (1 - alpha_0 * sqr(coord[2] / dist));

end;

// ���������� ����������� ������ �� ������ �� �����
function TAtmosphericDrag.ReadValue(text: string; flag: byte): MType;
var
  i, position: byte;
  proc_text: string;
begin

  proc_text := text;

  for i := 0 to flag do
  begin
    position := pos(deletimer, proc_text);
    delete(proc_text, 1, position);
  end;
  result := StrToFloat(Copy(proc_text, 1, pos(deletimer, proc_text) - 1));

end;

// ��������� ���������� ������ � ������ ��� �� ���������� �������
function TAtmosphericDrag.SetTime(Value: MType): MType;
// var
// Date: TDate;
begin

  // Date := FromJDToDate(Value);
  // with Date do
  // begin
  // Hour := 0;
  // Minute := 0;
  // second := 0;
  // end;

  { ���������� ��� ��������� � ������ ��� � ��������� �������
    * ���������� ��� � ��� }
  result := Frac(Value) * SecInDay;

end;

// ��������� ���������� ����� � ������ ����
//function TAtmosphericDrag.SetDays(Value: MType): word;
//var
//  Date: TDate;
//  vis: byte; // ���� �� ��, ���������� �� ���
//begin
//
//  Date := FromJDToDate(Value);
//  with Date do
//  begin
//    if ((Year mod 4 = 0) AND (Year mod 100 <> 0)) OR (Year mod 400 = 0) then
//      vis := 1 // ��� ����������� ����
//    else
//      vis := 2; // ��� ��������
//
//    // ���������� ����, ��������� � ������ ����
//    result := trunc((275 * Month) / 9) - vis * trunc((Month + 9) / 12) +
//      days - 30;
//  end;
//
//end;

{ ��������� ���������� F10_7, F81 � Kp �� ����� (�� ������ ������
  - solarinex.txt) }
procedure TAtmosphericDrag.getF0_Kp(t: MType);
var
  f: TextFile;
  temp_text, Date: string;
  time, need_time_F81, need_time_Kp: TDate;
  F81_flag, Kp_flag: boolean; // �������� ��������� ���������� �������������

  _Day: word; // ������� - ������������� �������� ���
begin

  { ������������ ������� �� ����������:

    ��� ��������� ���������� ��� ������������ ���������� 1,7 ���.
    ��� ������������ ������������� - 0,6 ���. }

  need_time_F81 := FromJDToDate(t - 1.7);
  need_time_Kp := FromJDToDate(t - 0.6);

  {
  	��������, ��������� ������� �� ������ � �������:
      ������ F10_7 ��������� � 20.00 UT
      ������ Kp ��������� � �������� ����� (12.00 UT)
  }

  F81_flag := false;
  Kp_flag := false;

  AssignFile(f, file_dir + F10_7_and_Kp);
  Reset(f);

  ReadLn(f, temp_text); // �������� ���� ��������� �����
  ReadLn(f, temp_text);

  while not EoF(f) do
  begin

    ReadLn(f, temp_text);

    // ����� ��������� �� ��������� �������
    Date := Copy(temp_text, pos(deletimer, temp_text) + 1, 10);

    with time do
    begin
      { ����������� ���������� ���� �� string � TDate (����������� ����������
        ���, ����� � ���� ���������� TDate) }
      DecodeDate(StrToDate(Date, FS), Year, Month, _Day);

      Day := _Day; // �������������� ����

      { ���������� ���������� ���� � ����������� ��� F81.
        ��� ������ ��������� ������������ F10_7 � F81 }
      if (Year = need_time_F81.Year) then
        if (Month = need_time_F81.Month) then
          if (Day = Trunc(need_time_F81.Day)) then
          // ���� ���������, ��� ��� '���������' �������� ����� double
          begin
            F10_7 := ReadValue(temp_text, 1);
            F81 := ReadValue(temp_text, 2);
            F81_flag := true;
          end;

      // ���������� ��� Kp, ��� ������ ��������� ������������ Kp
      if (Year = need_time_Kp.Year) then
        if (Month = need_time_Kp.Month) then
          if (Day = Trunc(need_time_Kp.Day)) then
          begin
            Kp := trunc(ReadValue(temp_text, 3));
            Kp_flag := true;
          end
          else continue // day
        else continue   // month
      else continue;    // year

    end;

    // ��� ������������ �������, ����� ����� ���������
    if F81_flag AND Kp_flag then
      break;

  end;

  CloseFile(f);

  if NOT F81_flag OR NOT Kp_flag then
  begin
    ShowMessage('Boss, we gotta problem with F10_7 (F81) = ' +
      BoolToStr(F81_flag) + ', Kp = ' + BoolToStr(Kp_flag) + '.');
    exit;
  end;

end;

{ ��������� ������� ������������� ��� ���������� ������� � }
procedure TAtmosphericDrag.getCoeffForK(F0: word; h: MType; vec: char);
var
//  f: TextFile;
//  temp_text: string;
  i, flag, range, coef_num: byte;
//  coef_height: integer;

begin

  case F0 of
    75:
      flag := 1;
    100:
      flag := 2;
    125:
      flag := 3;
    150:
      flag := 4;
    175:
      flag := 5;
    200:
      flag := 6;
    250:
      flag := 7;
  else
    flag := 4;
  end;

  // ����� �� �������� ������ ��� ��� ��������� � �������, �� ������ ������ ������ �� ������� � �������
  flag := flag - 1;

  range := 1; // ����� ������� 3 �������� ��������

  // coef_num - ����� ������������ (��� ������ ������ ����������)
  case vec of
    'a': // den_a
      begin
      	coef_num := 0;

        range := ifthen ( h < AD_coef_h[range][coef_num, flag], 0, 1 );

        for i := 0 to High(den_a) do
          den_a[i] := AD_coef_den_a[range][i, flag];
      end;

    'b':
    	begin
      	coef_num := 1;

        range := ifthen ( h < AD_coef_h[range][coef_num, flag], 0, 1 );

        for i := 0 to High(b) do
          b[i] := AD_coef_b[range][i, flag];
      end;

    'c':
    	begin
      	coef_num := 2;

        range := ifthen ( h < AD_coef_h[range][coef_num, flag], 0, 1 );

        for i := 0 to High(_�) do
          _�[i] := AD_coef_c[range][i, flag];
      end;

    'd':
    	begin
      	coef_num := 3;

        range := ifthen ( h < AD_coef_h[range][coef_num, flag], 0, 1 );

        for i := 0 to High(d) do
          d[i] := AD_coef_d[range][i, flag];
      end;

    'e':
    	begin
      	coef_num := 4;

      	range := ifthen ( h < AD_coef_h[1][coef_num, flag], 0, 1 );

        for i := 0 to NUM_OF_E do
          e[i] := AD_coef_e[range][i, flag];
      end;

    'l':
    	begin
      	coef_num := 5;

        range := ifthen ( h < AD_coef_h[range][coef_num, flag], 0, 1 );

        for i := 0 to High(l) do
          l[i] := AD_coef_l[range][i, flag];
      end;

    'n':
      for i := 0 to High(n) do
        n[i] := AD_coef_n[i, flag];

    'f':	fi_1 := AD_coef_fi_1[flag];	// fi_1

  end; // End of case

//  // ���������� � ������� �� �����
//  if h >= 500 then { ����� ������������� 3 �������� �������� }
//    temp_text := AD_coef_2 // ��������� 2 ���� (� 3 �������� ����������)
//  else
//    temp_text := AD_coef_1; // ����� 1 ���� (�� 2 (�� 120 ��))
//
//  AssignFile(f, file_dir + temp_text);
//  Reset(f);
//
//  temp_text := ' ';
//
//  if (vec <> 'n') OR (vec <> 'fi_1') then
//  begin
//
//    while (temp_text[1] <> vec) AND not EoF(f) do
//    begin
//      ReadLn(f, temp_text);
//      if temp_text = '' then
//        temp_text := ' ';
//    end;
//    if EoF(f) then
//    begin
//      ShowMessage('���� � ���������� ��� ������� �������������. ����� �����');
//      exit;
//    end;
//
//    // ������� ������ ��� ������������
//    coef_height := trunc(ReadValue(temp_text, flag));
//
//    if h < coef_height then
//    begin
//      CloseFile(f);
//
//      temp_text := AD_coef_1; { �� ��������� � 2 �������� ��������� }
//      AssignFile(f, file_dir + temp_text);
//      Reset(f);
//    end;
//
//  end;
//
//  temp_text := ' ';
//
//
//  { �������� ��� ����������� }
//  while (temp_text[1] <> vec) AND not EoF(f) do
//  begin
//    ReadLn(f, temp_text);
//    if temp_text = '' then
//      temp_text := ' ';
//  end;
//  if EoF(f) then
//  begin
//    ShowMessage('���� � ���������� ��� ������� �������������. ����� �����');
//    exit;
//  end;
//
//  // ����� ��� �������� ������������� (den_a, b, c, n, fi_1, d, e, l)
//  case vec[1] of
//    'a': // den_a
//      for i := Low(den_a) to High(den_a) do
//      begin
//        ReadLn(f, temp_text);
//        den_a[i] := ReadValue(temp_text, flag);
//      end;
//    'b':
//      for i := Low(b) to High(b) do
//      begin
//        ReadLn(f, temp_text);
//        b[i] := ReadValue(temp_text, flag);
//        // �������� � ReadValue �������� �� ������ �����
//      end;
//    'c':
//      for i := Low(c) to High(c) do
//      begin
//        ReadLn(f, temp_text);
//        c[i] := ReadValue(temp_text, flag);
//      end;
//    'n':
//      for i := Low(n) to High(n) do
//      begin
//        n[i] := ReadValue(temp_text, flag);
//        ReadLn(f, temp_text);
//      end;
//    'f':
//      fi_1 := ReadValue(temp_text, flag); // fi_1
//    'd':
//      for i := Low(d) to High(d) do
//      begin
//        ReadLn(f, temp_text);
//        d[i] := ReadValue(temp_text, flag);
//      end;
//    'e':
//      for i := Low(e) to High(e) do
//      begin
//        ReadLn(f, temp_text);
//        e[i] := ReadValue(temp_text, flag);
//      end;
//    'l':
//      for i := Low(l) to High(l) do
//      begin
//        ReadLn(f, temp_text);
//        l[i] := ReadValue(temp_text, flag);
//      end;
//
//  end; // End of case
//
//  CloseFile(f);

end;

{ ������� ��� �������� "�����" � ������������ �������� }
function TAtmosphericDrag.series(h: MType; x: array of MType; n: byte;
  plus: boolean): MType;
var
  sum: MType;
  i: byte;
begin

  sum := 0;
  if NOT plus then // ���� �� ���������� ������ ����� ���������� K[4]
  for i := 0 to n do
    sum := sum + x[i] * IntPower(h, i)
  else
  for i := 0 to n do
    sum := sum + x[i + 5] * IntPower(h, i);

  result := sum;

end;

{ ��������� ������������ � }
function TAtmosphericDrag.setK(h: MType; Index: byte;
  Value: coordinates): MType;
var
  cos_fi, r, beta: MType;
  { �������� ����� ��������, ��� ������� ������������ ���������
    ���������, � �������� � ������������ ��������� ���������
    � �� �������� �������������, ��� }
begin

  case Index of
    0:
      K[Index] := 1 + series(h, l, NUM_OF_COEF, false) * (F81 - F0) / F0;
    1:
      begin
        beta := sun.alpha - S_time - Earth.omega * time + fi_1;
        r := module(Value);
        cos_fi := 1 /
          (r * (Value[2] * sin(sun.beta) + cos(sun.beta) *
           		 (Value[0] * cos(beta) + Value[1] * sin(beta))));

        { ������� � ����������� ���������. ������ ���� �� stand_91.doc }
        cos_fi := sqrt(abs(1 + cos_fi) / 2);

        K[Index] := series(h, _�, NUM_OF_COEF, false) *
          Power(cos_fi, series(h, n, NUM_OF_COEF - 2, false));
      end;
    2:
      K[Index] := series(h, d, NUM_OF_COEF, false) * setA(days);
    3:
      K[Index] := series(h, b, NUM_OF_COEF, false) * (F10_7 - F81) /
        (F81 + abs(F10_7 - F81));
    4:
      K[Index] := series(h, e, NUM_OF_COEF, false) * series(Kp, e, NUM_OF_COEF, true);
  end;

  result := K[Index];

end;

function TAtmosphericDrag.setA(d: word): MType;
var
  i: byte;
  sum: MType;
begin

  sum := 0;
  for i := Low(A) to High(A) do
    sum := sum + A[i] * IntPower(d, i);

  result := sum;

end;

function TAtmosphericDrag.densityNight(h: MType): MType;
begin

  result := Earth.density_120 * exp(series(h, den_a, NUM_OF_COEF + 2, false));

end;

function TAtmosphericDrag.density(t: MType; coord: coordinates): MType;
const
  vec = 'abcnfdel'; // ������ � ������� ������� �������� �������������
var
  i: byte;
  h, main_part: MType;
begin

  h := height(coord); // ��������� ������

  if h < 120 then // ������ ���� ������ ������� 1 ��������� ���������

  begin
    case trunc(h) of
      0 .. 19:
        if memo_ro <> 1 then // <-���� �� � ���� ���������, �� � ������ ��
        begin // �������� �� ���� ����������, �������������
          memo_ro := 1; // ���������� ���� �������� � �����
          h_i := 0; // ������������. ����� ������ ������ �� ����
          a0 := 1.228;
          k1 := -9.0764E-2;
          k2 := -2.0452E-3;
        end;
      20 .. 59:
        if memo_ro <> 2 then
        begin
          memo_ro := 2;
          h_i := 20;
          a0 := 9.013E-2;
          k1 := -0.16739;
          k2 := 6.2669E-4;
        end;
      60 .. 99:
        if memo_ro <> 3 then
        begin
          memo_ro := 3;
          h_i := 60;
          a0 := 3.104E-4;
          k1 := -0.137;
          k2 := -7.8653E-4;
        end;
      100 .. 119:
        if memo_ro <> 4 then
        begin
          memo_ro := 4;
          h_i := 100;
          a0 := 3.66E-7;
          k1 := -0.18553;
          k2 := 1.5397E-3;
        end;
    end; // End of case

    result := a0 * exp(k1 * (h - h_i) + k2 * sqr(h - h_i));
    // �������� ��������� ��� <120km
  end

  else // ������ ��������� ���� 120 ��

  begin

    getF0_Kp(t); // ��������� ����������� ��������� F10_7, F81 � Kp

    case Round(F81) of // ������� F81 � F0
      75 - 12 .. 75 + 12:
        F0 := 75;
      100 - 12 .. 100 + 12:
        F0 := 100;
      125 - 12 .. 125 + 12:
        F0 := 125;
      150 - 12 .. 150 + 12:
        F0 := 150;
      175 - 12 .. 175 + 12:
        F0 := 175;
      200 - 12 .. 200 + 12:
        F0 := 200;
      250 - 12 .. 250 + 12:
        F0 := 250
    else
      begin
        ShowMessage('�����-�� �������� ��������� ����������. t = ' +
          FloatToStr(t) + ', F81 = ' + FloatToStr(F81));
        result := 0;
        exit;
      end;
    end;

    for i := Low(vec) to High(vec) do
      getCoeffForK(F0, h, vec[i]); // �������� ������������ ��� ������� ������

    for i := Low(K) to High(K) do
      setK(h, i, coord); // ��������� ������������ �

    main_part := K[0] * (1 + K[2] + K[3] + K[4]);

    result := densityNight(h) * main_part; // �������� ��������� ��� >120km
  end;

  // result := 2.0e-13 * exp( - (h - 200) / 60 ); // ������� �������

end;

function TAtmosphericDrag.RightPart(JD: MType; coord, v: coordinates;
  Cb_coeff, CrossSecArea: MType): coordinates;
var
//  speed,
  ro, UT1: MType;
  // Fe: TVector; // ������� ��������� � �������� ��
  AtmospereSpeed, EarthRot: TVector;
//  Mct: TMatrix;
	Mtc: TMatrix;
begin

//  speed := module(v);

	Sun.SetParams(JD);

  UT1 := UT1_time(JD);

  time := SetTime(UT1);
  days := DayNumber(UT1);
//  S_time := ToGetGMSTime(UT1);
	S_time := GMSTime(UT1, TT_time(JD));

  // ��������� � ��
  ro := density(UT1, ConstProduct(1.0e-3, coord)); // ��������� �������� �������� ���������

  { ! ! ! �������� ���������� ��������������� ��������� }
//  result[0] := -Sb_coeff * ro * speed * v[0];
//  result[1] := -Sb_coeff * ro * speed * v[1];
//  result[2] := -Sb_coeff * ro * speed * v[2];

  EarthRot := NullVec;
  EarthRot[2] := Earth.omega;

  Mtc := ITRS2GCRS( TT_time(JD) );
  EarthRot := MultMatrVec(Mtc, EarthRot);

  AtmospereSpeed := CrossProduct(EarthRot, coord);

//	Mct := TranspMatr( ITRS2GCRS(TT_time(JD)) ); // ������� �������� �� �������� � ������

	result := ConstProduct( - CrossSecArea * Cb_coeff * ro * 0.5, VecDec(v, AtmospereSpeed) );

end;

end.
