object ViewForm: TViewForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Winners'
  ClientHeight = 440
  ClientWidth = 609
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object ViewStringGrid: TStringGrid
    Left = 0
    Top = -5
    Width = 281
    Height = 246
    ColCount = 2
    FixedCols = 0
    FixedRows = 0
    TabOrder = 0
  end
end
