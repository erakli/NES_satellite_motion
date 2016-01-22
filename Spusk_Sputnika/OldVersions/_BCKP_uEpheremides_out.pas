unit uEpheremides_out;

interface

const
  EPHFILE_NAME = 'lnxp1600p2200.405';

var
  nams: array[0..400] of string;
  vals: array[0..400] of double;
implementation

function jpl_init_ephemeris(ephemeris_filename: string;
                            var nam: array of string; val: array of double):
                        byte; stdcall; external 'eph';

initialization

jpl_init_ephemeris(EPHFILE_NAME, nams, vals);

end.
