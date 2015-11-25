unit UI_unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uConstants, uTime, uSputnik,
  uControl, uTypes, Vcl.StdCtrls, Vcl.Mask;

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
    gbox_Result: TGroupBox;
    memo_Result: TMemo;
    lab_ResultX: TLabel;
    lab_ResultY: TLabel;
    lab_ResultZ: TLabel;
    memo_ResultSpeed: TMemo;
    lab_ResultName: TLabel;
    lab_ResultNameSpeed: TLabel;
    ed_Step: TEdit;
    lab_Step: TLabel;
    gbox_Aditional: TGroupBox;
    ed_Sb_coeff: TEdit;
    lab_Sb_coeff: TLabel;
    procedure btn_RunClick(Sender: TObject);
  private
    { Private declarations }
    t_start_, t_end_: TDate;
    TLE_: TLE_lines;
    mass_, space_, step_, Sb_coeff_, A_: MType;

    procedure Proceed;
    procedure Run;
    procedure Result;
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
  begin
    with Result do
    begin
      Day := StrToInt(Copy(value, 1, 2));
      // добавить считывание части дня в виде часов/минут/сек сюда
      Month := StrToInt(Copy(value, 3, 2));
      Year := StrToInt(Copy(value, 5, 4));
      // Hour := StrToInt(Copy(value, 9, 2));
      // Minute := StrToInt(Copy(value, 11, 2));
      // second := StrToFloat(Copy(value, 13, 2));
    end;
  end;

begin

  first_date := maskEd_StartDate.Text + maskEd_StartTime.Text;
  t_start_ := ReadValue(first_date);

  second_date := maskEd_EndDate.Text + maskEd_EndTime.Text;
  t_end_ := ReadValue(second_date);

  for i := 0 to 1 do
    TLE_[i] := memo_TLE.Lines[i];

  mass_ := StrToFloat(ed_Mass.Text);
  space_ := StrToFloat(ed_Space.Text);
  Sb_coeff_ := StrToFloat(ed_Sb_coeff.Text);
  step_ := StrToFloat(ed_Step.Text);
  A_ := 1; // заглушка

end;

procedure TForm1.Run;
begin

  Control.Prepare(t_start_, t_end_, step_, TLE_, mass_, space_, Sb_coeff_, A_);
  Control.Modeling;

end;

procedure TForm1.Result;
var
  i: byte;
begin

  for i := 0 to 2 do
  begin
    memo_Result.Lines[i] := FloatToStr(Sputnik.state.coord[i]);
    memo_ResultSpeed.Lines[i] := FloatToStr(Sputnik.state.speed[i]);
  end;

end;

end.
