unit UI_unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uConstants, uTime, uSputnik,
  uControl, uTypes, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    memo_TLE: TMemo;
    gbox_Main: TGroupBox;
    lab_TLE: TLabel;
    ed_Mass: TEdit;
    ed_Space: TEdit;
    lab_Mass: TLabel;
    lab_Space: TLabel;
    maskEd_StartDate: TMaskEdit;
    maskEd_EndDate: TMaskEdit;
    maskEd_StartTime: TMaskEdit;
    maskEd_EndTime: TMaskEdit;
    gbox_Time: TGroupBox;
    lab_StartTime: TLabel;
    lab_EndTime: TLabel;
    btn_Run: TButton;
    gbox_Aditional: TGroupBox;
    ed_Sb_coeff: TEdit;
    lab_Sb_coeff: TLabel;
    RadGroup_CoordType: TRadioGroup;
    Ed_Decart_Y: TEdit;
    Ed_Decart_X: TEdit;
    Ed_Decart_Z: TEdit;
    GBox_Decart: TGroupBox;
    lab_Decart_Y: TLabel;
    lab_Decart_X: TLabel;
    lab_Decart_Z: TLabel;
    Ed_Decart_Vy: TEdit;
    Ed_Decart_Vx: TEdit;
    Ed_Decart_Vz: TEdit;
    lab_Decart_Vy: TLabel;
    lab_Decart_Vx: TLabel;
    lab_Decart_Vz: TLabel;
    procedure btn_RunClick(Sender: TObject);
  private
    { Private declarations }
    t_start_, t_end_: TDate;
    TLE_: TLE_lines;
    mass_, space_, step_, Cb_coeff_, CrossSecArea_: MType;

    Decart_Coord, Decart_Speed: TVector;

    procedure Proceed;
    procedure Run;
//    procedure Result;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btn_RunClick(Sender: TObject);
begin

  Proceed;
  Run;

end;


procedure TForm1.Proceed;
var
  first_date, second_date: string;
  i: byte;

  function ReadValue(value: string): TDate;
  var
  	Hour, Minute: Byte;
    second: MType;
  begin
    with Result do
    begin
      Day := StrToInt(Copy(value, 1, 2));
      Month := StrToInt(Copy(value, 3, 2));
      Year := StrToInt(Copy(value, 5, 4));

      Hour := StrToInt(Copy(value, 9, 2));
      Minute := StrToInt(Copy(value, 11, 2));
      second := StrToFloat(Copy(value, 13, 2));

      Day := Day + Hour / HoursPerDay + Minute / MinsPerHour + second / SecInDay;
    end;
  end;

begin

  first_date := maskEd_StartDate.Text + maskEd_StartTime.Text;
  t_start_ := ReadValue(first_date);

  second_date := maskEd_EndDate.Text + maskEd_EndTime.Text;
  t_end_ := ReadValue(second_date);

  if RadGroup_CoordType.ItemIndex = 0 then
    for i := 0 to 1 do
      TLE_[i] := memo_TLE.Lines[i]
  else
  begin
  	Decart_Coord[0] := StrToFloat(Ed_Decart_X.Text);
    Decart_Coord[1] := StrToFloat(Ed_Decart_Y.Text);
    Decart_Coord[2] := StrToFloat(Ed_Decart_Z.Text);

    Decart_Speed[0] := StrToFloat(Ed_Decart_Vx.Text);
    Decart_Speed[1] := StrToFloat(Ed_Decart_Vy.Text);
    Decart_Speed[2] := StrToFloat(Ed_Decart_Vz.Text);
  end;

  mass_ := StrToFloat(ed_Mass.Text);
  space_ := StrToFloat(ed_Space.Text);
  Cb_coeff_ := StrToFloat(ed_Sb_coeff.Text);
//  step_ := StrToFloat(ed_Step.Text);
  CrossSecArea_ := 3; // заглушка

end;

procedure TForm1.Run;
begin

	if RadGroup_CoordType.ItemIndex = 0 then
  	Control.Prepare(t_start_, t_end_, TLE_, NullVec, NullVec, mass_, space_, Cb_coeff_, CrossSecArea_)
  else
  begin
  	Control.Prepare(t_start_, t_end_, TLE_, Decart_Coord, Decart_Speed, mass_, space_, Cb_coeff_, CrossSecArea_, false);
  end;

  Control.Modeling;

end;

//procedure TForm1.Result;
////var
////  i: byte;
//begin
//
////  for i := 0 to 2 do
////  begin
////    memo_Result.Lines[i] := FloatToStr(Sputnik.state.coord[i]);
////    memo_ResultSpeed.Lines[i] := FloatToStr(Sputnik.state.speed[i]);
////  end;
//
//end;

end.
