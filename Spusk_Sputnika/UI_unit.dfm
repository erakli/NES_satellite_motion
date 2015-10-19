object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #1052#1086#1076#1077#1083#1080#1088#1086#1074#1072#1085#1080#1077' '#1076#1074#1080#1078#1077#1085#1080#1103' '#1048#1057#1047
  ClientHeight = 275
  ClientWidth = 690
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object gbox_Main: TGroupBox
    Left = 8
    Top = 8
    Width = 674
    Height = 145
    Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
    TabOrder = 0
    object lab_TLE: TLabel
      Left = 272
      Top = 21
      Width = 186
      Height = 13
      Caption = #1055#1086#1083#1077' '#1074#1074#1086#1076#1072' '#1076#1074#1091#1089#1090#1088#1086#1095#1085#1099#1093' '#1101#1083#1077#1084#1077#1085#1090#1086#1074
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lab_Step: TLabel
      Left = 272
      Top = 117
      Width = 119
      Height = 13
      Caption = #1064#1072#1075' '#1080#1085#1090#1077#1075#1088#1080#1088#1086#1074#1072#1085#1080#1103', '#1089
    end
    object memo_TLE: TMemo
      Left = 272
      Top = 40
      Width = 391
      Height = 41
      Lines.Strings = (
        
          '1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0 ' +
          ' 3477'
        
          '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.666221913' +
          '02881')
      TabOrder = 0
    end
    object gbox_Time: TGroupBox
      Left = 16
      Top = 22
      Width = 209
      Height = 84
      Caption = #1042#1088#1077#1084#1103' '#1101#1082#1089#1087#1077#1088#1080#1084#1077#1085#1090#1072
      TabOrder = 1
      object lab_StartTime: TLabel
        Left = 16
        Top = 26
        Width = 37
        Height = 13
        Caption = #1053#1072#1095#1072#1083#1086
      end
      object lab_EndTime: TLabel
        Left = 16
        Top = 53
        Width = 31
        Height = 13
        Caption = #1050#1086#1085#1077#1094
      end
      object maskEd_EndDate: TMaskEdit
        Left = 64
        Top = 50
        Width = 67
        Height = 21
        EditMask = '!00/00/0000;0;_'
        MaxLength = 10
        TabOrder = 0
        Text = '11042004'
      end
      object maskEd_EndTime: TMaskEdit
        Left = 141
        Top = 50
        Width = 51
        Height = 21
        EditMask = '!00:00:00;0;_'
        MaxLength = 8
        TabOrder = 1
        Text = '000000'
      end
      object maskEd_StartDate: TMaskEdit
        Left = 64
        Top = 23
        Width = 67
        Height = 21
        EditMask = '!00/00/0000;0;_'
        MaxLength = 10
        TabOrder = 2
        Text = '11032004'
      end
      object maskEd_StartTime: TMaskEdit
        Left = 141
        Top = 23
        Width = 52
        Height = 21
        EditMask = '!00:00:00;0;_'
        MaxLength = 8
        TabOrder = 3
        Text = '000000'
      end
    end
    object btn_Run: TButton
      Left = 16
      Top = 112
      Width = 89
      Height = 25
      Caption = #1052#1086#1076#1077#1083#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 2
      OnClick = btn_RunClick
    end
    object ed_Step: TEdit
      Left = 405
      Top = 114
      Width = 65
      Height = 21
      TabOrder = 3
      Text = '3600'
    end
  end
  object gbox_Result: TGroupBox
    Left = 376
    Top = 159
    Width = 306
    Height = 106
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1084#1086#1076#1077#1083#1080#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 1
    object lab_ResultX: TLabel
      Left = 16
      Top = 42
      Width = 6
      Height = 13
      Caption = 'X'
    end
    object lab_ResultY: TLabel
      Left = 16
      Top = 56
      Width = 6
      Height = 13
      Caption = 'Y'
    end
    object lab_ResultZ: TLabel
      Left = 16
      Top = 69
      Width = 6
      Height = 13
      Caption = 'Z'
    end
    object lab_ResultName: TLabel
      Left = 40
      Top = 21
      Width = 64
      Height = 13
      Caption = #1050#1086#1086#1088#1076#1080#1085#1072#1090#1099
    end
    object lab_ResultNameSpeed: TLabel
      Left = 168
      Top = 21
      Width = 48
      Height = 13
      Caption = #1057#1082#1086#1088#1086#1089#1090#1100
    end
    object memo_Result: TMemo
      Left = 37
      Top = 40
      Width = 124
      Height = 49
      TabOrder = 0
    end
    object memo_ResultSpeed: TMemo
      Left = 167
      Top = 40
      Width = 124
      Height = 49
      TabOrder = 1
    end
  end
  object gbox_Aditional: TGroupBox
    Left = 8
    Top = 159
    Width = 273
    Height = 105
    Caption = #1044#1086#1087#1086#1083#1100#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
    TabOrder = 2
    object lab_Mass: TLabel
      Left = 11
      Top = 47
      Width = 71
      Height = 13
      Caption = #1052#1072#1089#1089#1072' '#1048#1057#1047', '#1082#1075
    end
    object lab_Space: TLabel
      Left = 11
      Top = 21
      Width = 182
      Height = 13
      Caption = #1055#1083#1086#1097#1072#1076#1100' '#1087#1086#1087#1077#1088#1077#1095#1085#1086#1075#1086' '#1089#1077#1095#1077#1085#1080#1103' '#1048#1057#1047
    end
    object lab_Sb_coeff: TLabel
      Left = 11
      Top = 74
      Width = 154
      Height = 13
      Caption = #1041#1072#1083#1083#1080#1089#1090#1080#1095#1077#1089#1082#1080#1081' '#1082#1086#1101#1092#1092#1080#1094#1080#1077#1085#1090
    end
    object ed_Mass: TEdit
      Left = 205
      Top = 44
      Width = 57
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object ed_Space: TEdit
      Left = 205
      Top = 17
      Width = 57
      Height = 21
      TabOrder = 1
      Text = '1'
    end
    object ed_Sb_coeff: TEdit
      Left = 205
      Top = 71
      Width = 57
      Height = 21
      TabOrder = 2
      Text = '1'
    end
  end
end
