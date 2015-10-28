unit uConstants;

interface

uses
  System.SysUtils, uTypes;

const
  fm = 3.986004418E+5; // [km] Гравитационная постоянная
//  m_size = 2; // Размер матриц

  au = 1.49597870700E+8; // [km] Astronomical unit - астрономическая единица
  c = 299792.458; // [km/s] Скорость света

  SecInDay = 86400; // секунд в дне

  MJDCorrection = 2400000.5; // вычитать из JD

  // // Для торможения атмосферы
  // Earth_eq_rad = 6378.14; // [km] Экваториальный радиус Земли
  // Earth_alpha_0 = 0.0033528131778969; // 1 / 298.257 - сжатие Земли

  // // Для гармоник
  // Num_of_harm = 70;
  // CS_harmonics = 'CS.txt';

  deletimer = '	';

  asecInTurn = 360 * 60 * 60;
  MICRO = 1.0e-6;

//type

  // procedure Get_Harmonics(FileName: string);

const
  ResetCoord: coordinates = (x: 0; y: 0; z: 0);

var
  // harmonics : array [0 .. Num_of_harm - 1, 0 .. 1] of MType;
  Earth: TEarth;
  Sun: TSun;
  file_dir: string;

  CurYear: shortint;
  Third: MType;

  _P, _N: TMatrix; { Матрицы прецессии и нутации. Здесь они актуальны, пока
    обе вычисляются в TDB (TT). Здесь они изменяются в uControl и принимаются в
    uMatrix_conversation }

implementation

// procedure Get_Harmonics(FileName: string);
// var
// f: TextFile;
// i: integer;
// temp_text: string;
// begin
//
// AssignFile(f, FileName);
// Reset(f);
// for i := 0 to Num_of_harm - 1 do
// begin
// ReadLn(f, temp_text);
// harmonics[i, 0] :=
// StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1));
// harmonics[i, 1] := StrToFloat(Copy(temp_text, pos(deletimer, temp_text) + 1,
// length(temp_text)));
// end;
// CloseFile(f);
//
// end;

initialization

{ Путь к папке с программой. Нужен для подхвата файлов с  коэффициентами,
  которые должны лежать рядом с ним. }
file_dir := ExtractFileDir(ParamStr(0)) + '\';

with Earth do
begin
  eq_rad := 6378.1366;
  alpha_0 := 1 / 298.25642;
  omega := 7.292115E-5;
  density_120 := 1.58868E-8;
  // big_a := 149.597868E+6;
  big_a := au;
end;

with Sun do
begin
  q := 4.65E+5;
end;

CurYear := 15;
Third := 1 / 3;

// Get_Harmonics(file_dir + CS_harmonics);

end.
