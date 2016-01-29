object Main_Window: TMain_Window
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1052#1086#1076#1077#1083#1080#1088#1086#1074#1072#1085#1080#1077' '#1076#1074#1080#1078#1077#1085#1080#1103' '#1048#1057#1047
  ClientHeight = 376
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gbox_Main: TGroupBox
    Left = 0
    Top = 0
    Width = 649
    Height = 273
    Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
    TabOrder = 0
    object gbox_Time: TGroupBox
      Left = 16
      Top = 22
      Width = 209
      Height = 84
      Caption = #1042#1088#1077#1084#1103' '#1101#1082#1089#1087#1077#1088#1080#1084#1077#1085#1090#1072
      TabOrder = 0
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
        Width = 65
        Height = 21
        EditMask = '!00/00/0000;0;_'
        MaxLength = 10
        TabOrder = 0
        Text = '12032004'
      end
      object maskEd_EndTime: TMaskEdit
        Left = 141
        Top = 50
        Width = 49
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
    object gbox_Data: TGroupBox
      Left = 231
      Top = 18
      Width = 415
      Height = 247
      Caption = #1053#1072#1095#1072#1083#1100#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
      TabOrder = 1
      object lab_Forces: TLabel
        Left = 12
        Top = 132
        Width = 229
        Height = 21
        AutoSize = False
        Caption = #1042#1086#1079#1084#1091#1097#1072#1102#1097#1080#1077' '#1089#1080#1083#1099', '#1076#1077#1081#1089#1090#1074#1091#1102#1097#1080#1077' '#1085#1072' '#1048#1057#1047
        WordWrap = True
      end
      object lab_TLE: TLabel
        Left = 12
        Top = 183
        Width = 214
        Height = 13
        Caption = #1055#1086#1083#1077' '#1074#1074#1086#1076#1072' '#1076#1074#1091#1089#1090#1088#1086#1095#1085#1099#1093' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' (TLE)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object CheckListBox_Forces: TCheckListBox
        Left = 247
        Top = 132
        Width = 121
        Height = 45
        ItemHeight = 13
        Items.Strings = (
          'Sun Pressure'
          'GEO Potential'
          'Atmospheric Drag')
        TabOrder = 0
      end
      object memo_TLE: TMemo
        Left = 12
        Top = 202
        Width = 391
        Height = 39
        Lines.Strings = (
          
            '1 25544U 98067A   04070.88065972  .00013484  00000-0  13089-3 0 ' +
            ' 3477'
          
            '2 25544  51.6279 106.4208 0010791 261.4810  91.7966 15.666221913' +
            '02881')
        TabOrder = 1
      end
      object RadGroup_CoordType: TRadioGroup
        Left = 228
        Top = 27
        Width = 179
        Height = 60
        Caption = #1058#1080#1087' '#1080#1089#1093#1086#1076#1085#1099#1093' '#1076#1072#1085#1085#1099#1093
        ItemIndex = 1
        Items.Strings = (
          'TLE'
          #1044#1077#1082#1072#1088#1090#1086#1074#1099' '#1082#1086#1086#1088#1076#1080#1085#1072#1090#1099)
        TabOrder = 2
      end
      object GBox_Decart: TGroupBox
        Left = 12
        Top = 21
        Width = 210
        Height = 105
        Caption = #1044#1077#1082#1072#1088#1090#1086#1074#1099' '#1082#1086#1086#1088#1076#1080#1085#1072#1090#1099' ('#1084#1077#1090#1088#1099')'
        TabOrder = 3
        object lab_Decart_Y: TLabel
          Left = 11
          Top = 47
          Width = 6
          Height = 13
          Caption = 'Y'
        end
        object lab_Decart_X: TLabel
          Left = 11
          Top = 21
          Width = 6
          Height = 13
          Caption = 'X'
        end
        object lab_Decart_Z: TLabel
          Left = 11
          Top = 74
          Width = 6
          Height = 13
          Caption = 'Z'
        end
        object lab_Decart_Vy: TLabel
          Left = 114
          Top = 47
          Width = 12
          Height = 13
          Caption = 'Vy'
        end
        object lab_Decart_Vx: TLabel
          Left = 114
          Top = 21
          Width = 12
          Height = 13
          Caption = 'Vx'
        end
        object lab_Decart_Vz: TLabel
          Left = 114
          Top = 74
          Width = 11
          Height = 13
          Caption = 'Vz'
        end
        object Ed_Decart_X: TEdit
          Left = 31
          Top = 18
          Width = 58
          Height = 21
          TabOrder = 0
          Text = '6600000'
        end
        object Ed_Decart_Y: TEdit
          Left = 31
          Top = 44
          Width = 57
          Height = 21
          TabOrder = 1
          Text = '0'
        end
        object Ed_Decart_Z: TEdit
          Left = 32
          Top = 71
          Width = 57
          Height = 21
          TabOrder = 2
          Text = '0'
        end
        object Ed_Decart_Vy: TEdit
          Left = 136
          Top = 44
          Width = 57
          Height = 21
          TabOrder = 3
          Text = '7800'
        end
        object Ed_Decart_Vx: TEdit
          Left = 136
          Top = 18
          Width = 58
          Height = 21
          TabOrder = 4
          Text = '0'
        end
        object Ed_Decart_Vz: TEdit
          Left = 136
          Top = 71
          Width = 57
          Height = 21
          TabOrder = 5
          Text = '0'
        end
      end
    end
    object gbox_IntegrationParam: TGroupBox
      Left = 16
      Top = 112
      Width = 209
      Height = 130
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1080#1085#1090#1077#1075#1088#1080#1088#1086#1074#1072#1085#1080#1103
      TabOrder = 2
      object label_Interval: TLabel
        Left = 16
        Top = 82
        Width = 122
        Height = 31
        AutoSize = False
        Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' '#1080#1085#1090#1077#1075#1088#1080#1088#1086#1074#1072#1085#1080#1103', '#1089
        WordWrap = True
      end
      object label_Precision: TLabel
        Left = 16
        Top = 26
        Width = 176
        Height = 13
        Caption = #1058#1086#1095#1085#1086#1089#1090#1100' '#1080#1085#1090#1077#1075#1088#1080#1088#1086#1074#1072#1085#1080#1103' (1.0e-x)'
      end
      object edit_Interval: TEdit
        Left = 144
        Top = 82
        Width = 54
        Height = 21
        TabOrder = 0
        Text = '120'
      end
      object ed_Precision: TEdit
        Left = 143
        Top = 45
        Width = 55
        Height = 21
        NumbersOnly = True
        ReadOnly = True
        TabOrder = 1
        Text = '12'
      end
      object ScrollBar_Precision: TScrollBar
        Left = 24
        Top = 45
        Width = 113
        Height = 20
        Max = 17
        Min = 5
        PageSize = 0
        Position = 12
        TabOrder = 2
        OnChange = ScrollBar_PrecisionChange
      end
    end
  end
  object gbox_Aditional: TGroupBox
    Left = 373
    Top = 279
    Width = 273
    Height = 97
    Caption = #1044#1086#1087#1086#1083#1100#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
    TabOrder = 1
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
    object lab_Mass: TLabel
      Left = 11
      Top = 47
      Width = 71
      Height = 13
      Caption = #1052#1072#1089#1089#1072' '#1048#1057#1047', '#1082#1075
    end
    object ed_Mass: TEdit
      Left = 205
      Top = 44
      Width = 57
      Height = 21
      TabOrder = 0
      Text = '417289'
    end
    object ed_Sb_coeff: TEdit
      Left = 205
      Top = 71
      Width = 57
      Height = 21
      TabOrder = 1
      Text = '2.2'
    end
    object ed_Space: TEdit
      Left = 205
      Top = 18
      Width = 57
      Height = 21
      TabOrder = 2
      Text = '3'
    end
  end
  object btn_Run: TButton
    Left = 8
    Top = 331
    Width = 97
    Height = 37
    Caption = #1052#1086#1076#1077#1083#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 2
    OnClick = btn_RunClick
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security In' +
      'fo=False;Initial Catalog=NES_motion;Data Source=MAIN-PC;'
    Provider = 'SQLOLEDB.1'
    Left = 216
    Top = 304
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    Left = 304
    Top = 304
  end
end
