unit UI_Plot;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SDL_Rot3D, SDL_sdlbase;

const
	WM_MESSAGE = WM_USER;
  
type
  TForm_Plot = class(TForm)
    Rot3D1: TRot3D;
    procedure Rot3D1DblClick(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight,
      MaxWidth, MaxHeight: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
//    move: Boolean;
//    PointX, PointY: integer;
		procedure ReceiveMessage(var msg: TMessage); message WM_MESSAGE;
  public
    { Public declarations }
  end;
  
var
  Form_Plot: TForm_Plot;

implementation

//uses uFunctions;
uses uSputnik;

{$R *.dfm}


procedure TForm_Plot.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
  
begin
	Rot3D1.CentX := Rot3D1.Width div 2;
  Rot3D1.CentY := Rot3D1.Height div 2;
end;


procedure TForm_Plot.FormCreate(Sender: TObject);

begin
	Rot3D1.CentX := Rot3D1.Width div 2;
  Rot3D1.CentY := Rot3D1.Height div 2;
//  move := false;
end;


procedure TForm_Plot.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  
const
	ZoomCoef = 0.1;
  AxCoef = 100;
  
begin
	if WheelDelta > 0 then
  begin
		Rot3D1.Magnification := Rot3D1.Magnification + ZoomCoef;
//    Rot3D1.AxSize := Rot3D1.AxSize + AxCoef;
  end
  else
  begin
  	Rot3D1.Magnification := Rot3D1.Magnification - ZoomCoef;
//    Rot3D1.AxSize := Rot3D1.AxSize - AxCoef;
  end;
end;


procedure TForm_Plot.Rot3D1DblClick(Sender: TObject);

begin
	Rot3D1.ViewAngleX := 40;
  Rot3D1.ViewAngleY := 150;
  Rot3D1.ViewAngleZ := 90;
end;


procedure TForm_Plot.ReceiveMessage(var msg: TMessage);
var
	SputnikObject: TSputnik;
begin
  Rot3D1.ColorData := clBlue;
  SputnikObject := TSputnik(msg.LParam);
end;

//procedure TForm_Plot.Rot3D1MouseDown(Sender: TObject; Button: TMouseButton;
//  Shift: TShiftState; X, Y: Integer);
//begin
//	if ssLeft in Shift then
//  begin
//    move := true;
//    PointX := X;
//    PointY := Y;
//  end;
//end;
//
//procedure TForm_Plot.Rot3D1MouseMove(Sender: TObject; Shift: TShiftState; X,
//  Y: Integer);
//
//const
//	Coeff = 0.1;
//  
//var
//	angle: Extended;
//  sign: integer;
//
//begin
//	if move then
//  begin   
//    angle := Round(Rot3D1.ViewAngleY) mod 360;
//    sign := getSign(angle);
//    
//    if abs(angle) < 180 then
//    begin
//    	Rot3D1.ViewAngleY := Rot3D1.ViewAngleY + (Y - PointY) * Coeff * sign;
//    end
//    else
//    begin
//    	Rot3D1.ViewAngleY := Rot3D1.ViewAngleY - (Y - PointY) * Coeff * sign;  
//    end;
//    
//  end;
//end;
//
//procedure TForm_Plot.Rot3D1MouseUp(Sender: TObject; Button: TMouseButton;
//  Shift: TShiftState; X, Y: Integer);
//begin
//	move := false;
//end;

end.
