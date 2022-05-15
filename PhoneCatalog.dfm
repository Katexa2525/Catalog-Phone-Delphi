object Form_Main: TForm_Main
  Left = 0
  Top = 0
  Caption = #1043#1083#1072#1074#1085#1072#1103' '#1092#1086#1088#1084#1072
  ClientHeight = 475
  ClientWidth = 865
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button_Close: TButton
    Left = 774
    Top = 432
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 5
    OnClick = Button_CloseClick
  end
  object Button_Add: TButton
    Left = 16
    Top = 432
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 1
    OnClick = Button_AddClick
  end
  object Button_Del: TButton
    Left = 97
    Top = 432
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 2
    OnClick = Button_DelClick
  end
  object Button_Edit: TButton
    Left = 178
    Top = 432
    Width = 89
    Height = 25
    Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 3
    OnClick = Button_EditClick
  end
  object Button_Find: TButton
    Left = 693
    Top = 41
    Width = 75
    Height = 25
    Caption = #1053#1072#1081#1090#1080
    TabOrder = 6
  end
  object Button_Filter: TButton
    Left = 774
    Top = 41
    Width = 75
    Height = 25
    Caption = #1060#1080#1083#1100#1090#1088
    TabOrder = 7
  end
  object Button_Sort: TButton
    Left = 612
    Top = 41
    Width = 75
    Height = 25
    Caption = #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072
    TabOrder = 8
  end
  object StringGrid_Catalog: TStringGrid
    Left = 8
    Top = 72
    Width = 841
    Height = 345
    ColCount = 13
    DrawingStyle = gdsGradient
    FixedColor = clSilver
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect, goFixedRowDefAlign]
    ParentFont = False
    TabOrder = 0
    OnDblClick = StringGrid_CatalogDblClick
  end
  object Button_SaveToFile: TButton
    Left = 302
    Top = 432
    Width = 133
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083
    TabOrder = 4
    OnClick = Button_SaveToFileClick
  end
end
