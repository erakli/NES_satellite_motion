unit uAtmosphericDrag;

{ ����������:
  � ������ ���������� ������������ �������������� ������������.

  ����� ����� ��������, ��� Kp ������ �����. � ������ ��������� ����� �
  ��������� ������� ����� ����� ����������� Ap, ������� ���� ����������
  �� ������� � ���������� � ���������.

  ��� ��, ��� �������� ����� ��������� � ������, ����� ����� ���������� �
  ��������� � ����� � ������������� ��� ��������������� (stand-91.doc) }

interface

uses
  uConstants, uTime, Math, System.SysUtils, Dialogs, uSputnik, uTypes,
  uFunctions, uStarTime;

const
  num = 4;
  AD_coef_A = 'AD_coef_A.txt';
  AD_coef_1 = 'AD_coef_1.txt';
  AD_coef_2 = 'AD_coef_2.txt';
  F10_7_and_Kp = 'solarinex.txt';

type

  // vectors = (a, b, c, n, fi_1, d, e, l);

  TCoefVect = array [0 .. num] of MType;

  TAtmosphericDrag = class
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
    den_a: array [0 .. num + 2] of MType;

    // ��� �0
    l: TCoefVect;

    // ��� �1
    c: TCoefVect;

    // Sun : TSun;     // ��������� ������ - ���������� �� ������

    { �������� ����� � ����������� �������: }
    S_time: MType; // [���]

    { ����������� ������, ������ ���� ������������ ��������� ���������
      �� ��������� � ��������� ������������: }
    fi_1: MType; // [���]
    n: array [0 .. num - 2] of MType;

    // ��� �2
    d: TCoefVect;
    A: array [0 .. num * 2] of MType; // ������������ ��������� A(d) ��� �2

    // ��� �3
    b: TCoefVect;

    // ��� �4
    e: array [0 .. num * 2] of MType;

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
    function series(h: MType; x: array of MType; n: byte;
      plus: boolean): MType;

    function densityNight(h: MType): MType;
    function density(t: MType; coord: coordinates): MType;
    // [��/�^3] - ���������� ���������

    function setK(h: MType; Index: byte; Value: coordinates): MType;
    function setA(d: word): MType;

    procedure getCoeffForK(F0: word; h: MType; vec: string);
    procedure getF0_Kp(t: MType);

    function ReadValue(text: string; flag: byte): MType;

    function SetTime(Value: MType): MType;
    function SetDays(Value: MType): word;
  public
    function RightPart(MJD: MType; coord, v: coordinates; Sb_coeff: MType): coordinates;

    constructor Create;
    destructor Destroy; override;
  end;

var
  AtmosphericDrag: TAtmosphericDrag;

implementation
// ---------------------------------------------------------------

constructor TAtmosphericDrag.Create;
var
  f: TextFile;
  temp_text: string;
  i: byte;
begin

  inherited;

  memo_ro := 0;

  AssignFile(f, file_dir + AD_coef_A);
  Reset(f);

  for i := Low(A) to High(A) do
  begin
    ReadLn(f, temp_text);
    A[i] := StrToFloat(Copy(temp_text, pos(deletimer, temp_text) + 1,
      length(temp_text)));
  end;

  CloseFile(f);

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
  with coord, Earth do
    result := dist - eq_rad * (1 - alpha_0 * sqr(z / dist));

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
var
  Date: TDate;
begin

  Date := FromMJDToDate(Value);
  with Date do
  begin
    Hour := 0;
    Minute := 0;
    second := 0;
  end;

  { ���������� ��� ��������� � ������ ��� � ��������� �������
    * ���������� ��� � ��� }
  result := (Value - FromDateToMJD(Date)) * SecInDay;

end;

// ��������� ���������� ����� � ������ ����
function TAtmosphericDrag.SetDays(Value: MType): word;
var
  Date: TDate;
  vis: byte; // ���� �� ��, ���������� �� ���
begin

  Date := FromMJDToDate(Value);
  with Date do
  begin
    if ((Year mod 4 = 0) AND (Year mod 100 <> 0)) OR (Year mod 400 = 0) then
      vis := 1 // ��� ����������� ����
    else
      vis := 2; // ��� ��������

    // ���������� ����, ��������� � ������ ����
    result := trunc((275 * Month) / 9) - vis * trunc((Month + 9) / 12) +
      days - 30;
  end;

end;

{ ��������� ���������� F10_7, F81 � Kp �� ����� (�� ������ ������
  - solarinex.txt) }
procedure TAtmosphericDrag.getF0_Kp(t: MType);
var
  f: TextFile;
  temp_text, Date: string;
  time, need_time_F81, need_time_Kp: TDate;
  F81_flag, Kp_flag: boolean; // �������� ��������� ���������� �������������

begin

  { ������������ ������� �� ����������:

    ��� ��������� ���������� ��� ������������ ���������� 1,7 ���.
    ��� ������������ ������������� - 0,6 ���. }

  need_time_F81 := FromMJDToDate(t - 1.7);
  need_time_Kp := FromMJDToDate(t - 0.6);

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
      DecodeDate(StrToDate(Date, FS), Year, Month, Day);

      { ���������� ���������� ���� � ����������� ��� F81.
        ��� ������ ��������� ������������ F10_7 � F81 }
      if (Year = need_time_F81.Year) AND (Month = need_time_F81.Month) AND
        (Day = need_time_F81.Day) then
      begin
        F10_7 := ReadValue(temp_text, 1);
        F81 := ReadValue(temp_text, 2);
        F81_flag := true;
      end;

      // ���������� ��� Kp, ��� ������ ��������� ������������ Kp
      if (Year = need_time_Kp.Year) AND (Month = need_time_Kp.Month) AND
        (Day = need_time_Kp.Day) then
      begin
        Kp := trunc(ReadValue(temp_text, 3));
        Kp_flag := true;
      end;

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
procedure TAtmosphericDrag.getCoeffForK(F0: word; h: MType; vec: string);
var
  f: TextFile;
  temp_text: string;
  i, flag: byte;
  coef_height: integer;

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

  if h >= 500 then { ����� �������������� 3 �������� �������� }
    temp_text := AD_coef_2 // ��������� 2 ���� (� 3 �������� ����������)
  else
    temp_text := AD_coef_1; // ����� 1 ���� (�� 2 (�� 120 ��))

  AssignFile(f, file_dir + temp_text);
  Reset(f);

  temp_text := ' ';

  if (vec <> 'n') OR (vec <> 'fi_1') then
  begin

    while (temp_text[1] <> vec) AND not EoF(f) do
    begin
      ReadLn(f, temp_text);
      if temp_text = '' then
        temp_text := ' ';
    end;
    if EoF(f) then
    begin
      ShowMessage('���� � ���������� ��� ������� �������������. ����� �����');
      exit;
    end;

    // ������� ������ ��� ������������
    coef_height := trunc(ReadValue(temp_text, flag));

    if h < coef_height then
    begin
      CloseFile(f);

      temp_text := AD_coef_1; { �� ��������� � 2 �������� ��������� }
      AssignFile(f, file_dir + temp_text);
      Reset(f);
    end;

  end;

  temp_text := ' ';

  while (temp_text[1] <> vec) AND not EoF(f) do
  begin
    ReadLn(f, temp_text);
    if temp_text = '' then
      temp_text := ' ';
  end;
  if EoF(f) then
  begin
    ShowMessage('���� � ���������� ��� ������� �������������. ����� �����');
    exit;
  end;

  // ����� ��� �������� ������������� (den_a, b, c, n, fi_1, d, e, l)
  case vec[1] of
    'a': // den_a
      for i := Low(den_a) to High(den_a) do
      begin
        ReadLn(f, temp_text);
        den_a[i] := ReadValue(temp_text, flag);
      end;
    'b':
      for i := Low(b) to High(b) do
      begin
        ReadLn(f, temp_text);
        b[i] := ReadValue(temp_text, flag);    // �������� � ReadValue �������� �� ������ �����
      end;
    'c':
      for i := Low(c) to High(c) do
      begin
        ReadLn(f, temp_text);
        c[i] := ReadValue(temp_text, flag);
      end;
    'n':
      for i := Low(n) to High(n) do
      begin
        n[i] := ReadValue(temp_text, flag);
        ReadLn(f, temp_text);
      end;
    'f':
      fi_1 := ReadValue(temp_text, flag); // fi_1
    'd':
      for i := Low(d) to High(d) do
      begin
        ReadLn(f, temp_text);
        d[i] := ReadValue(temp_text, flag);
      end;
    'e':
      for i := Low(e) to High(e) do
      begin
        ReadLn(f, temp_text);
        e[i] := ReadValue(temp_text, flag);
      end;
    'l':
      for i := Low(l) to High(l) do
      begin
        ReadLn(f, temp_text);
        l[i] := ReadValue(temp_text, flag);
      end;

  end; // End of case

  CloseFile(f);

end;

{ ������� ��� �������� "�����" � ������������ �������� }
function TAtmosphericDrag.series(h: MType; x: array of MType; n: byte;
  plus: boolean): MType;
var
  sum: MType;
  i: byte;
begin

  sum := 0;
  for i := 0 to n do
    sum := sum + x[i] * IntPower(h, i);

  if plus then // ���� �� ���������� ������ ����� ���������� K[4]
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
      K[Index] := 1 + series(h, l, num, false) * (F81 - F0) / F0;
    1:
      begin
        beta := sun.alpha - S_time - Earth.omega * time + fi_1;
        r := module(Value);
        with Value do
          cos_fi := 1 /
            (r * (z * sin(sun.beta) + cos(sun.beta) * (x * cos(beta) + y *
            sin(beta))));

        { ������� � ����������� ���������. ������ ���� �� stand_91.doc }
        cos_fi := sqrt(abs(1 + cos_fi) / 2);

        K[Index] := series(h, c, num, false) *
          Power(cos_fi, series(h, n, num - 2, false));
      end;
    2:
      K[Index] := series(h, d, num, false) * setA(days);
    3:
      K[Index] := series(h, b, num, false) * (F10_7 - F81) /
        (F81 + abs(F10_7 - F81));
    4:
      K[Index] := series(h, e, num, false) * series(Kp, e, num, true);
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

  result := Earth.density_120 * exp(series(h, den_a, num + 2, false));

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

    for i := Low(vec) + 1 to High(vec) do // !��������� ������ �������
      getCoeffForK(F0, h, vec[i]); // �������� ������������ ��� ������� ������

    for i := Low(K) to High(K) do
      setK(h, i, coord); // ��������� ������������ �

    main_part := K[0] * (1 + K[2] + K[3] + K[4]);

    result := densityNight(h) * main_part; // �������� ��������� ��� >120km
  end;

  // result := 2.0e-13 * exp( - (h - 200) / 60 ); // ������� �������

end;

function TAtmosphericDrag.RightPart(MJD: MType; coord, v: coordinates; Sb_coeff: MType)
  : coordinates;
var
  speed, ro, UT1: MType;
  // Fe: TVector; // ������� ��������� � �������� ��
begin

  speed := module(v);

  UT1 := UT1_time(MJD);

  time := SetTime(UT1);
  days := SetDays(UT1);
  S_time := ToGetGMSTime(UT1);

  ro := density(UT1, coord); // ��������� �������� �������� ���������

  { ! �������� ���������� ��������������� ��������� }
  result.x := -Sb_coeff * ro * speed * v.x;
  result.y := -Sb_coeff * ro * speed * v.y;
  result.z := -Sb_coeff * ro * speed * v.z;

end;

end.
