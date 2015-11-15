unit uAtmosphericDrag;

{ Примечание:
  В данной реализации используются среднесуточные коэффициенты.

  Также стоит заметить, что Kp берётся сразу. В случае изменения файла с
  исходными данными стоит брать коэффициент Ap, который надо переводить
  по таблице в приложении А стандарта.

  Так же, при внесении любых уточнений в модель, имеет смысл обратиться к
  стандарту и файлу с исправлениями его предшественника (stand-91.doc) }

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
    { Основные индексы вычисления плотности атмосферы: }
    F10_7: MType; { [10^-22 * Вт * м^-2 * Гц^-1]
      среднесуточный индекс солнечной активности }

    F81: MType; { средневзвешенный индекс. Результат осреднения F10_7
      за 81 сутки (три оборота вокруг Солнца) }

    F0: word; { фиксированный уровень солнечной активности.
      Средневзвешенный индекс F81, кратный 25 }

    Kp: byte; { [баллы] квазилогарифмический планетарный среднесуточный индекс
      геомагнитной возмущенности }

    time: MType; // [сек] всемирное время
    days: word; // число суток от начала года

    { множители, учитывающие:
      K[0] - изменение плотности атмосферы, связанное с отклонением F81 от F0
      K[1] - суточный эффект в распределении плотности
      K[2] - полугодовой эффект
      K[3] - изменение плотности, связанное с отклонением F10,7 от F81
      K[4] - зависимость плотности атмосферы от геомагнитной возмущенности }
    K: TCoefVect;

    { коэффициенты модели, используемые для расчета плотности атмосферы при
      различных значениях фиксированного уровня солнечной активности F0: }
    // При ro_0 (densityNight)
    den_a: array [0 .. num + 2] of MType;

    // При К0
    l: TCoefVect;

    // При К1
    c: TCoefVect;

    // Sun : TSun;     // Параметры Солнца - необходимо их задать

    { звездное время в гринвичскую полночь: }
    S_time: MType; // [рад]

    { коэффициент модели, равный углу запаздывания максимума плотности
      по отношению к максимуму освещенности: }
    fi_1: MType; // [рад]
    n: array [0 .. num - 2] of MType;

    // При К2
    d: TCoefVect;
    A: array [0 .. num * 2] of MType; // Коэффициенты множителя A(d) при К2

    // При К3
    b: TCoefVect;

    // При К4
    e: array [0 .. num * 2] of MType;

    // Коэффициенты при вычислении плотности на высоте <120 km
    h_i, // [km] Нижняя граница слоя
    a0, // [кг/м^3]
    k1, // [1/км]
    k2 // [1/км^2]
      : MType;

    memo_ro: byte; { Номер слоя, в котором мы до этого находились. При
      несоответствии нынешнего слоя memo_ro, сменяем
      коэффициенты }

    // function module(coord : coordinates) : MType; // Модуль трёх компонент
    function height(coord: coordinates): MType; // [km]
    function series(h: MType; x: array of MType; n: byte;
      plus: boolean): MType;

    function densityNight(h: MType): MType;
    function density(t: MType; coord: coordinates): MType;
    // [кг/м^3] - Вычисление плотности

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

{ Вычисление высоты над земным элепсоидом. Стоит уточнить }
function TAtmosphericDrag.height(coord: coordinates): MType;
var
  dist: MType;
begin

  dist := module(coord);
  with coord, Earth do
    result := dist - eq_rad * (1 - alpha_0 * sqr(z / dist));

end;

// Извлечение необходимых данных из строки по флагу
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

// Получение количества секунд с начала дня по всемирному времени
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

  { Количество сек прошедших с начала дня в юлианском формате
    * количество сек в дне }
  result := (Value - FromDateToMJD(Date)) * SecInDay;

end;

// Получение количества суток с начала года
function TAtmosphericDrag.SetDays(Value: MType): word;
var
  Date: TDate;
  vis: byte; // Флаг на то, високосный ли год
begin

  Date := FromMJDToDate(Value);
  with Date do
  begin
    if ((Year mod 4 = 0) AND (Year mod 100 <> 0)) OR (Year mod 400 = 0) then
      vis := 1 // для високосного года
    else
      vis := 2; // для обычного

    // Количество дней, прошедших с начала года
    result := trunc((275 * Month) / 9) - vis * trunc((Month + 9) / 12) +
      days - 30;
  end;

end;

{ Получение параметров F10_7, F81 и Kp из файла (на данный момент
  - solarinex.txt) }
procedure TAtmosphericDrag.getF0_Kp(t: MType);
var
  f: TextFile;
  temp_text, Date: string;
  time, need_time_F81, need_time_Kp: TDate;
  F81_flag, Kp_flag: boolean; // признаки успешного считывания коэффициентов

begin

  { Запаздывание каждого из параметров:

    Для солнечной активности это запаздывание составляет 1,7 сут.
    Для геомагнитной возмущенности - 0,6 сут. }

  need_time_F81 := FromMJDToDate(t - 1.7);
  need_time_Kp := FromMJDToDate(t - 0.6);

  F81_flag := false;
  Kp_flag := false;

  AssignFile(f, file_dir + F10_7_and_Kp);
  Reset(f);

  ReadLn(f, temp_text); // Проходим мимо текстовых строк
  ReadLn(f, temp_text);

  while not EoF(f) do
  begin

    ReadLn(f, temp_text);

    // Время извлекаем из очередной строчки
    Date := Copy(temp_text, pos(deletimer, temp_text) + 1, 10);

    with time do
    begin
      { Преобразуем вытащенную дату из string в TDate (присваиваем полученные
        год, месяц и день переменной TDate) }
      DecodeDate(StrToDate(Date, FS), Year, Month, Day);

      { Сравниваем полученную дату с необходимой для F81.
        При успехе считываем коэффициенты F10_7 и F81 }
      if (Year = need_time_F81.Year) AND (Month = need_time_F81.Month) AND
        (Day = need_time_F81.Day) then
      begin
        F10_7 := ReadValue(temp_text, 1);
        F81 := ReadValue(temp_text, 2);
        F81_flag := true;
      end;

      // Аналогично для Kp, при успехе считываем коэффициенты Kp
      if (Year = need_time_Kp.Year) AND (Month = need_time_Kp.Month) AND
        (Day = need_time_Kp.Day) then
      begin
        Kp := trunc(ReadValue(temp_text, 3));
        Kp_flag := true;
      end;

    end;

    // Оба коэффициента считаны, поиск можно закончить
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

{ Заполняем массивы коэффициентов для вычисления массива К }
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

  if h >= 500 then { Сразу проссматриваем 3 высотный диапазон }
    temp_text := AD_coef_2 // Открываем 2 файл (с 3 высотным диапазоном)
  else
    temp_text := AD_coef_1; // Иначе 1 файл (со 2 (от 120 км))

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
      ShowMessage('Беда с названиями или файлами коэффициентов. Конец файла');
      exit;
    end;

    // Сверяем высоту для коэффициента
    coef_height := trunc(ReadValue(temp_text, flag));

    if h < coef_height then
    begin
      CloseFile(f);

      temp_text := AD_coef_1; { Мы находимся в 2 высотном диапазоне }
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
    ShowMessage('Беда с названиями или файлами коэффициентов. Конец файла');
    exit;
  end;

  // Набор имён массивов коэффициентов (den_a, b, c, n, fi_1, d, e, l)
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
        b[i] := ReadValue(temp_text, flag);    // добавить в ReadValue проверку на пустой текст
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

{ Функция для подсчёта "рядов" с возрастающей степенью }
function TAtmosphericDrag.series(h: MType; x: array of MType; n: byte;
  plus: boolean): MType;
var
  sum: MType;
  i: byte;
begin

  sum := 0;
  for i := 0 to n do
    sum := sum + x[i] * IntPower(h, i);

  if plus then // Флаг на вычисление второй части множителей K[4]
    for i := 0 to n do
      sum := sum + x[i + 5] * IntPower(h, i);

  result := sum;

end;

{ Заполняем коэффициенты К }
function TAtmosphericDrag.setK(h: MType; Index: byte;
  Value: coordinates): MType;
var
  cos_fi, r, beta: MType;
  { разность между долготой, для которой рассчитывают плотность
    атмосферы, и долготой с максимальным значением плотности
    в ее суточном распределении, рад }
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

        { Перевод к половинному аргументу. Модуль взят из stand_91.doc }
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
  vec = 'abcnfdel'; // Строка с первыми буквами массивов коэффициентов
var
  i: byte;
  h, main_part: MType;
begin

  h := height(coord); // Вычисляем высоту

  if h < 120 then // Высота ниже нижней границы 1 высотного диапазона

  begin
    case trunc(h) of
      0 .. 19:
        if memo_ro <> 1 then // <-Если мы в этом диапазоне, но в памяти не
        begin // хранится об этом информация, следовательно
          memo_ro := 1; // запоминаем этот диапазон и задаём
          h_i := 0; // коэффициенты. Иначе ничего менять не надо
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
    // Итоговая плотность для <120km
  end

  else // Высота оказалась выше 120 км

  begin

    getF0_Kp(t); // Заполнили необходимые параметры F10_7, F81 и Kp

    case Round(F81) of // Привели F81 к F0
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
        ShowMessage('Какая-то странная солнечная активность. t = ' +
          FloatToStr(t) + ', F81 = ' + FloatToStr(F81));
        result := 0;
        exit;
      end;
    end;

    for i := Low(vec) + 1 to High(vec) do // !Проверить нижнюю границу
      getCoeffForK(F0, h, vec[i]); // Получили коэффициенты для текущей высоты

    for i := Low(K) to High(K) do
      setK(h, i, coord); // Посчитали коэффициенты К

    main_part := K[0] * (1 + K[2] + K[3] + K[4]);

    result := densityNight(h) * main_part; // Итоговая плотность для >120km
  end;

  // result := 2.0e-13 * exp( - (h - 200) / 60 ); // Простой вариант

end;

function TAtmosphericDrag.RightPart(MJD: MType; coord, v: coordinates; Sb_coeff: MType)
  : coordinates;
var
  speed, ro, UT1: MType;
  // Fe: TVector; // Матрица ускорения в небесной СК
begin

  speed := module(v);

  UT1 := UT1_time(MJD);

  time := SetTime(UT1);
  days := SetDays(UT1);
  S_time := ToGetGMSTime(UT1);

  ro := density(UT1, coord); // Запускаем алгоритм подсчёта плотности

  { ! Уточнить вычисление результирующего ускорения }
  result.x := -Sb_coeff * ro * speed * v.x;
  result.y := -Sb_coeff * ro * speed * v.y;
  result.z := -Sb_coeff * ro * speed * v.z;

end;

end.
