unit uEpheremides;

interface

{ Модуль для получения эфемерид

  Примечание: файлы, подготовленные для использования в этом модуле не
  универсальны, так же как и реализация их использования. В идеале необходимо
  границы файла эферемид узнавать из файла, но это усложнит программу. Для
  данного уровня реализации этого достаточно, хотя и не совсем удобно.

  Так же важное замечание: координаты и параметры нутации получены на полночь }

uses
  uConstants, Classes, Dialogs, SysUtils;

const

  eph_file = 'eph_earth-sun.txt';
  nut_file = 'earth_nutations.txt';
  DE_start = 47892; // Начальная дата файла эверемид (01 января 1990)
  DE_end = 57258; // Конечная дата

type

  { TO-DO:
    * Определить, какой конкретно СК находятся эферемиды
  }

  TEpheremides = class
  private
    eph_list, nut_list: TStringList; { Сюда загружается файл с координатами
      эферемид и параметрами нутации }

  public
    function GetEpheremides(MJD: double; Nutations: boolean = false)
      : coordinates;

    constructor Create;
    destructor Destroy; override;
  end;

var

  Epheremides: TEpheremides;

implementation

{ TEpheremides }

constructor TEpheremides.Create;
begin

  inherited;

  eph_list := TStringList.Create;
  eph_list.LoadFromFile(file_dir + eph_file);

  nut_list := TStringList.Create;
  nut_list.LoadFromFile(file_dir + nut_file);

end;

destructor TEpheremides.Destroy;
begin

  eph_list.Free;
  nut_list.Free;

  inherited;
end;

{ Получение геоцентрических координат для данной даты в астрономических единиц
  (на выходе - в метрах) и параметры нутации }
function TEpheremides.GetEpheremides(MJD: double; Nutations: boolean = false)
  : coordinates;
var
  days: integer;
  temp_coord: coordinates;
  temp_text: string;
begin

  days := Trunc(MJD - DE_start); // Число дней с начала файла эферемид

  if (days < 0) or (days > DE_end - DE_start) then
  begin

    ShowMessage('Неверно выбрана дата. Модуль эферемид');
    // Надо вынести в проверку даты
    exit;

  end
  else
  begin

    if Nutations then // Получаем параметры нутации?
    begin

      { Параметрами нутации называются следующие угловые переменные:

        Δψ — нутация в долготе,
        Δε — нутация в наклоне.

        Параметры нутации являются функциями барицентрического динамического
        времени и необходимы для вычисления матрицы нутации. Числовое значение
        нутации в долготе используется при вычислении истинного звёездного
        времени. }

      temp_text := nut_list[days];
      with temp_coord do
      begin

        x := StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1));
        delete(temp_text, 0, pos(deletimer, temp_text));
        y := StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1));
        // delete(temp_text, 0, pos(deletimer, temp_text));
        z := 0;

      end;

    end
    else // Нет, получаем координаты Солнца относительно Земли
    begin

      temp_text := eph_list[days];
      with temp_coord do
      begin

        x := StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1)) * au;
        delete(temp_text, 0, pos(deletimer, temp_text));
        y := StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1)) * au;
        delete(temp_text, 0, pos(deletimer, temp_text));
        z := StrToFloat(Copy(temp_text, 0, pos(deletimer, temp_text) - 1)) * au;

      end;

    end;

    { В результат уходят только координаты }
    result := temp_coord;

  end;

end;

end.
