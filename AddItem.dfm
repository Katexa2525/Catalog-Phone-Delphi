object Form_AddItem: TForm_AddItem
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1085#1086#1074#1086#1075#1086' '#1101#1083#1077#1084#1077#1085#1090#1072' '#1074' '#1082#1072#1090#1072#1083#1086#1075
  ClientHeight = 466
  ClientWidth = 481
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
    Left = 48
    Top = 32
    Width = 101
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1090#1077#1083#1077#1092#1086#1085#1072
  end
  object Label2: TLabel
    Left = 48
    Top = 80
    Width = 18
    Height = 13
    Caption = #1058#1080#1087
  end
  object Label3: TLabel
    Left = 48
    Top = 128
    Width = 26
    Height = 13
    Caption = #1062#1077#1085#1072
  end
  object Label4: TLabel
    Left = 48
    Top = 176
    Width = 61
    Height = 13
    Caption = #1043#1086#1076' '#1074#1099#1093#1086#1076#1072
  end
  object Label6: TLabel
    Left = 48
    Top = 224
    Width = 117
    Height = 13
    Caption = #1054#1087#1077#1088#1072#1094#1080#1086#1085#1085#1072#1103' '#1089#1080#1089#1090#1077#1084#1072
  end
  object Label7: TLabel
    Left = 256
    Top = 32
    Width = 87
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1074' '#1076#1102#1081#1084#1072#1093
  end
  object Label8: TLabel
    Left = 255
    Top = 80
    Width = 35
    Height = 13
    Caption = #1044#1083#1080#1085#1072' '
  end
  object Label9: TLabel
    Left = 256
    Top = 128
    Width = 40
    Height = 13
    Caption = #1064#1080#1088#1080#1085#1072
  end
  object Label10: TLabel
    Left = 256
    Top = 176
    Width = 107
    Height = 13
    Caption = #1054#1087#1077#1088#1072#1090#1080#1074#1085#1072#1103' '#1087#1072#1084#1103#1090#1100
  end
  object Label11: TLabel
    Left = 256
    Top = 224
    Width = 98
    Height = 13
    Caption = #1042#1089#1090#1088#1086#1077#1085#1085#1072#1103' '#1087#1072#1084#1103#1090#1100
  end
  object Label5: TLabel
    Left = 48
    Top = 283
    Width = 49
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object Button_Cancel: TButton
    Left = 364
    Top = 408
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    TabOrder = 13
    OnClick = Button_CancelClick
  end
  object Button_Save: TButton
    Left = 255
    Top = 408
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 12
    OnClick = Button_SaveClick
  end
  object Edit_PhoneName: TEdit
    Left = 48
    Top = 53
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object Edit_DisplayHight: TEdit
    Left = 256
    Top = 99
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 6
  end
  object Edit_Price: TEdit
    Left = 48
    Top = 147
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 2
  end
  object Edit_DisplaySize: TEdit
    Left = 256
    Top = 51
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 5
  end
  object Edit_DisplayWidth: TEdit
    Left = 256
    Top = 147
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 7
  end
  object Edit_YearVihoda: TEdit
    Left = 48
    Top = 197
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object Edit_OperationMemory: TEdit
    Left = 256
    Top = 197
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 8
  end
  object Edit_VstrMemory: TEdit
    Left = 256
    Top = 243
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 9
  end
  object Edit_OS: TEdit
    Left = 48
    Top = 243
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object ComboBox_TypePhone: TComboBox
    Left = 48
    Top = 101
    Width = 145
    Height = 21
    TabOrder = 1
    Items.Strings = (
      #1057#1084#1072#1088#1090#1092#1086#1085
      #1050#1085#1086#1087#1086#1095#1085#1099#1081
      #1056#1072#1089#1082#1083#1072#1076#1085#1086#1081)
  end
  object GroupBox1: TGroupBox
    Left = 255
    Top = 288
    Width = 184
    Height = 65
    Caption = #1053#1072#1083#1080#1095#1080#1077' '#1092#1088#1086#1085#1090#1072#1083#1100#1085#1086#1081' '#1082#1072#1084#1077#1088#1099
    TabOrder = 10
    object RadioButton_Yes: TRadioButton
      Left = 16
      Top = 16
      Width = 113
      Height = 17
      Caption = #1044#1072
      TabOrder = 1
    end
    object RadioButton_No: TRadioButton
      Left = 16
      Top = 39
      Width = 113
      Height = 17
      Caption = #1053#1077#1090
      TabOrder = 0
    end
  end
  object Memo_Description: TMemo
    Left = 48
    Top = 302
    Width = 185
    Height = 89
    Lines.Strings = (
      '')
    TabOrder = 11
  end
end
