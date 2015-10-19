unit uTest_Module;

interface

uses
  uConstants, uEpheremides, Dialogs, System.SysUtils, uAtmosphericDrag;

var
  i: byte;
  a: double;
  r: array [0 .. 5] of double;
  not_load: shortint;

  MJD, Sb_coeff: double;
  coord, v: coordinates;

implementation

initialization

MJD := 57258;

// AtmosphericDrag.RightPart(MJD, coord, v, Sb_coeff);  // Необходимы параметры

// a := 2457198.5;
// not_load := 0;
//
// _libmain(a, r, not_load);
//
// ShowMessage('a = ' + FloatToStr(a));
// for i := 0 to 5 do
// ShowMessage('r[' + FloatToStr(i) + '] = ' + FloatToStr(r[i]));

end.
