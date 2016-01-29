unit UI_unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uConstants, uTime, uSputnik,
  uControl, uTypes, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Data.Win.ADODB,
  Data.DB, Vcl.CheckLst, SDL_Rot3D;

type
  TMain_Window = class(TForm)
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
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    CheckListBox_Forces: TCheckListBox;
    lab_Forces: TLabel;
    edit_Interval: TEdit;
    label_Interval: TLabel;
    gbox_Data: TGroupBox;
    gbox_IntegrationParam: TGroupBox;
    ScrollBar_Precision: TScrollBar;
    ed_Precision: TEdit;
    label_Precision: TLabel;
    procedure btn_RunClick(Sender: TObject);
    procedure ScrollBar_PrecisionChange(Sender: TObject);
  private
    { Private declarations }
    ControlInit: TControlInitRec;
    t_start, t_end: TDate;

    procedure Proceed;
    procedure Run;
//    procedure Result;
  public
    { Public declarations }
  end;

var
  Main_Window: TMain_Window;

implementation

//uses uGraph;

{$R *.dfm}

procedure TMain_Window.btn_RunClick(Sender: TObject);
begin

	if StrToFloat(edit_Interval.Text) <= 0 then
  begin
    edit_Interval.Text := '1';
    ShowMessage('Интервал выдачи должен быть положительным числом');
  end
  else
  begin
  	Proceed;
  	Run;
  end;

end;


procedure TMain_Window.Proceed;
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

      Day := Day + Hour / HoursPerDay + Minute / MinsPerDay + second / SecsPerDay;
    end;
  end;

begin

	with ControlInit do
  begin
    first_date := maskEd_StartDate.Text + maskEd_StartTime.Text;
    t_start := ReadValue(first_date);

    second_date := maskEd_EndDate.Text + maskEd_EndTime.Text;
    t_end := ReadValue(second_date);

    if RadGroup_CoordType.ItemIndex = 0 then
    begin
    	coord := NullVec;
      speed := NullVec;
      for i := 0 to 1 do
        TLE[i] := memo_TLE.Lines[i]
    end
    else
    begin
      coord[0] := StrToFloat(Ed_Decart_X.Text);
      coord[1] := StrToFloat(Ed_Decart_Y.Text);
      coord[2] := StrToFloat(Ed_Decart_Z.Text);

      speed[0] := StrToFloat(Ed_Decart_Vx.Text);
      speed[1] := StrToFloat(Ed_Decart_Vy.Text);
      speed[2] := StrToFloat(Ed_Decart_Vz.Text);
    end;

    mass := StrToFloat(ed_Mass.Text);
    s := StrToFloat(ed_Space.Text);
    Сb_coeff := StrToFloat(ed_Sb_coeff.Text);
  //  Сb_coeff := StrToFloat(ed_Step.Text);
    CrossSecArea := 3; // заглушка

    Interval := StrToFloat(edit_Interval.Text);
    Precision := StrToInt(ed_Precision.Text);

    for i := 0 to ForcesNum do
      if CheckListBox_Forces.Checked[i] then Forces[i] := true;
  end;

end;

procedure TMain_Window.Run;
begin

	if RadGroup_CoordType.ItemIndex = 0 then
  	Control.Prepare(t_start, t_end, ControlInit)
  else
  begin
  	Control.Prepare(t_start, t_end, ControlInit, false);
  end;

  Control.Modeling;

//  if NOT Assigned(FormGraph) then FormGraph := TFormGraph.Create(Self);
//  FormGraph.Show;

end;

procedure TMain_Window.ScrollBar_PrecisionChange(Sender: TObject);
begin
	ed_Precision.Text := IntToStr(ScrollBar_Precision.Position);
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
