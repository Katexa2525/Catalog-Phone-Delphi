object Form_AddItem: TForm_AddItem
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1085#1086#1074#1086#1075#1086' '#1101#1083#1077#1084#1077#1085#1090#1072' '#1074' '#1082#1072#1090#1072#1083#1086#1075
  ClientHeight = 521
  ClientWidth = 669
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 32
    Width = 101
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1090#1077#1083#1077#1092#1086#1085#1072
  end
  object Label2: TLabel
    Left = 16
    Top = 59
    Width = 18
    Height = 13
    Caption = #1058#1080#1087
  end
  object Label3: TLabel
    Left = 16
    Top = 113
    Width = 51
    Height = 13
    Caption = #1062#1077#1085#1072', '#1088#1091#1073
  end
  object Label6: TLabel
    Left = 16
    Top = 86
    Width = 117
    Height = 13
    Caption = #1054#1087#1077#1088#1072#1094#1080#1086#1085#1085#1072#1103' '#1089#1080#1089#1090#1077#1084#1072
  end
  object Label5: TLabel
    Left = 16
    Top = 352
    Width = 49
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object Label4: TLabel
    Left = 271
    Top = 113
    Width = 65
    Height = 13
    Caption = #1043#1086#1076' '#1074#1099#1093#1086#1076#1072':'
  end
  object Button_Cancel: TButton
    Left = 586
    Top = 488
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    TabOrder = 8
    OnClick = Button_CancelClick
  end
  object Button_Save: TButton
    Left = 505
    Top = 488
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 7
    OnClick = Button_SaveClick
  end
  object Edit_PhoneName: TEdit
    Left = 139
    Top = 29
    Width = 521
    Height = 21
    TabOrder = 0
    TextHint = #1042#1074#1077#1076#1080#1090#1077' '#1085#1072#1079#1074#1072#1085#1080#1077' '#1090#1077#1083#1077#1092#1086#1085#1072
  end
  object Edit_Price: TEdit
    Left = 139
    Top = 110
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 3
  end
  object Edit_OS: TEdit
    Left = 139
    Top = 83
    Width = 521
    Height = 21
    TabOrder = 2
    TextHint = #1042#1074#1077#1076#1080#1090#1077' '#1085#1072#1079#1074#1072#1085#1080#1077' '#1086#1087#1077#1088#1072#1094#1080#1086#1085#1085#1086#1081' '#1089#1080#1089#1090#1077#1084#1099
  end
  object ComboBox_TypePhone: TComboBox
    Left = 139
    Top = 56
    Width = 256
    Height = 21
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    Items.Strings = (
      #1057#1084#1072#1088#1090#1092#1086#1085
      #1050#1085#1086#1087#1086#1095#1085#1099#1081
      #1056#1072#1089#1082#1083#1072#1076#1085#1086#1081)
  end
  object Memo_Description: TMemo
    Left = 17
    Top = 371
    Width = 644
    Height = 102
    Hint = 'sfsf'
    Lines.Strings = (
      '')
    ParentShowHint = False
    ShowHint = False
    TabOrder = 6
  end
  object GroupBox_Param: TGroupBox
    Left = 17
    Top = 146
    Width = 644
    Height = 199
    Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099
    TabOrder = 5
    object Label7: TLabel
      Left = 53
      Top = 31
      Width = 120
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1101#1082#1088#1072#1085#1072', '#1076#1102#1081#1084#1099':'
    end
    object Label12: TLabel
      Left = 53
      Top = 59
      Width = 130
      Height = 13
      Caption = #1054#1087#1077#1088#1072#1090#1080#1074#1085#1072#1103' '#1087#1072#1084#1103#1090#1100', '#1043#1073':'
    end
    object Label10: TLabel
      Left = 52
      Top = 86
      Width = 121
      Height = 13
      Caption = #1042#1089#1090#1088#1086#1077#1085#1085#1072#1103' '#1087#1072#1084#1103#1090#1100', '#1043#1073':'
    end
    object Label9: TLabel
      Left = 309
      Top = 31
      Width = 93
      Height = 13
      Caption = #1044#1083#1080#1085#1072' '#1101#1082#1088#1072#1085#1072', '#1084#1084':'
    end
    object Label11: TLabel
      Left = 301
      Top = 58
      Width = 101
      Height = 13
      Caption = #1064#1080#1088#1080#1085#1072' '#1101#1082#1088#1072#1085#1072', '#1084#1084':'
    end
    object Edit_DisplaySize: TEdit
      Left = 189
      Top = 28
      Width = 98
      Height = 21
      NumbersOnly = True
      TabOrder = 0
    end
    object Edit_DisplayHight: TEdit
      Left = 408
      Top = 28
      Width = 65
      Height = 21
      NumbersOnly = True
      TabOrder = 3
    end
    object Edit_DisplayWidth: TEdit
      Left = 408
      Top = 55
      Width = 65
      Height = 21
      NumbersOnly = True
      TabOrder = 4
    end
    object Edit_OperationMemory: TEdit
      Left = 189
      Top = 55
      Width = 50
      Height = 21
      NumbersOnly = True
      TabOrder = 1
    end
    object Edit_VstrMemory: TEdit
      Left = 189
      Top = 82
      Width = 50
      Height = 21
      NumbersOnly = True
      TabOrder = 2
    end
    object GroupBox_Camera: TGroupBox
      Left = 53
      Top = 127
      Width = 177
      Height = 49
      Caption = #1053#1072#1083#1080#1095#1080#1077' '#1092#1088#1086#1085#1090#1072#1083#1100#1085#1086#1081' '#1082#1072#1084#1077#1088#1099
      TabOrder = 5
      object RadioButton_Yes: TRadioButton
        Left = 25
        Top = 23
        Width = 48
        Height = 17
        Caption = #1044#1072
        TabOrder = 1
      end
      object RadioButton_No: TRadioButton
        Left = 113
        Top = 22
        Width = 48
        Height = 17
        Caption = #1053#1077#1090
        TabOrder = 0
      end
    end
  end
  object Edit_YearVihoda: TEdit
    Left = 342
    Top = 110
    Width = 65
    Height = 21
    TabOrder = 4
  end
end
