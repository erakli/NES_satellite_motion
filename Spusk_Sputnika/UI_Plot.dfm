object Form_Plot: TForm_Plot
  Left = 0
  Top = 0
  Caption = 'Form_Plot'
  ClientHeight = 420
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnConstrainedResize = FormConstrainedResize
  OnCreate = FormCreate
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object Rot3D1: TRot3D
    Left = 0
    Top = 0
    Width = 580
    Height = 420
    Align = alClient
    AllocSize = 1000
    CentX = 282
    CentY = 202
    ColorScheme = csSystem
    ColorCubeFrame = 4210752
    ColorCubeHidLin = 11579568
    ColorCubeFaceLow = clSilver
    ColorCubeFaceHigh = 15658734
    IsoMetric = False
    AutoOrigin = True
    AutoScale = True
    FrameStyle = fsEmbossed
    Magnification = 0.800000000000000000
    MouseAction = maRotate
    MouseRot3Axes = True
    BoundBoxStyle = bbNone
    BoundBoxSize = 0
    AxDir = adLeftHanded
    AxSize = 700
    AxNameX = 'Z'
    AxNameY = 'X'
    AxNameZ = 'Y'
    ShowAxes = True
    TextFontStyle = []
    TextMarkSize = 8
    ViewAngleX = 40.000000000000000000
    ViewAngleY = 150.000000000000000000
    ViewAngleZ = 90.000000000000000000
    OnDblClick = Rot3D1DblClick
    ExplicitWidth = 521
    ExplicitHeight = 361
  end
end