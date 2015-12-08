unit uEpheremides;

interface

//uses StdCtrls, ExtCtrls;
uses SysUtils, Variants;

type

  interpolation_info = record
    pc, vc: array[0..18] of double;
    twot: double;
    np,nv: integer;
  end;

  jpl_eph_data = record
    ephem_start, ephem_end, ephem_step: double;
    ncon: longint;
    au,
    emrat: double;
    ipt: array[0..13, 0..3] of longint;
    ephemeris_version,
    kernel_size, recsize, ncoeff,
    swap_bytes,
    curr_cache_loc: longint;
    pvsun: array[0..6] of double;
    pvsun_t: double;
    cache: PDouble;
    iinfo: interpolation_info;
    ifile: ^file;
  end;


//procedure _libmain(var a: double; r: array of double;
//  not_load: shortint); cdecl;

procedure jpl_init_ephemeris(ephemeris_filename: string;
                             var nam: array of string; val: PDouble);

var
  init_err_code: byte;
  {
    JPL_INIT_NO_ERROR                 0
    JPL_INIT_FILE_NOT_FOUND          -1
    JPL_INIT_FSEEK_FAILED            -2
    JPL_INIT_FREAD_FAILED            -3
    JPL_INIT_FREAD2_FAILED           -4
    JPL_INIT_FILE_CORRUPT            -5
    JPL_INIT_MEMORY_FAILURE          -6
    JPL_INIT_FREAD3_FAILED           -7
    JPL_INIT_FREAD4_FAILED           -8
    JPL_INIT_NOT_CALLED              -9
  }

  JPL_HEADER_SIZE: integer;

implementation

//procedure _libmain(var a: double; r: array of double; not_load: shortint);
//  cdecl; external 'my_eph.dll';
//// name '_libmain';

procedure jpl_init_ephemeris(ephemeris_filename: string;
                             var nam: array of string; val: PDouble);
var
  i, j: integer;
  de_version: longint;
  title: ^string;
  ifile: ^file;
  rval: ^jpl_eph_data;
  temp_data: jpl_eph_data;

  Buffer: array[0..84] of byte;
  count: longint;
  flag: boolean;
begin
//  init_err_code = 0;
  AssignFile(ifile^, ephemeris_filename);
  Reset(ifile^, 84);

  init_err_code := 0;
  temp_data.ifile := @ifile;
  FileExists(ephemeris_filename, flag);
  if not flag then
    init_err_code := 1
  else
  begin
    BlockRead(ifile^, title, 1, count);
    if count < 0 then
      init_err_code := 3
    else
    begin
      Reset(ifile^, JPL_HEADER_SIZE);
      BlockRead(ifile^, temp_data, 1, count);
      if count < 0 then
        init_err_code := 4
    end;
  end;

  if init_err_code <> 0 then
  begin
    FileExists(ephemeris_filename, flag);
    if flag then
      CloseFile(ifile^);
    exit;
  end;

  de_version := StrToInt(title^) + 26;

  with temp_data do
  begin
    ipt[12][0] := ipt[12][1];
    ipt[12][1] := ipt[12][2];
    ipt[12][2] := ephemeris_version;
    ephemeris_version := de_version;

//  Дописать про неверный порядок байтов
//    swap_bytes :=

    if (emrat > 81.3008) or (emrat < 81.30055) then
    begin
      init_err_code := 5;
      CloseFile(ifile^);
      exit;
    end;

    kernel_size := 4;
    for i := 0 to 13 do
    begin
      if i = 11 then
        j := 4
      else
        j := 6;
      kernel_size := ipt[i][1] * ipt[i][2] * j;
    end;
   recsize := kernel_size * 4;
   ncoeff := kernel_size div 2;
  end;

//  rval := @(jpl_eph_data + temp_data.recsize);         // проверить

//  if rval = null then
//  begin
//    init_err_code := 6;
//    FileClose(ifile);
//    exit;
//  end;


end;


initialization

JPL_HEADER_SIZE := 5 * sizeof(double) + 41 * sizeof(longint);
init_err_code := 9;

end.
