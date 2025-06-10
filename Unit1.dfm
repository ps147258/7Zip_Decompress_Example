object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnDestroy = FormDestroy
  TextHeight = 15
  object ListView1: TListView
    Left = 8
    Top = 32
    Width = 608
    Height = 384
    Columns = <
      item
        Caption = 'Name'
        Width = 360
      end
      item
        Alignment = taRightJustify
        Caption = 'Size'
        Width = 100
      end
      item
        Caption = 'Date'
        Width = 120
      end>
    HideSelection = False
    MultiSelect = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = ListView1Change
    OnData = ListView1Data
  end
  object JvFilenameEdit1: TJvFilenameEdit
    Left = 8
    Top = 8
    Width = 608
    Height = 23
    TabOrder = 1
    Text = 'JvFilenameEdit1'
    OnChange = JvFilenameEdit1Change
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <
      item
        Text = 'Count'
        Width = 90
      end
      item
        Text = 'Selected'
        Width = 100
      end>
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 40
    Top = 64
    object DecompressSelected: TMenuItem
      Caption = 'Decompress selected'
      OnClick = DecompressSelectedClick
    end
    object DecompressAll: TMenuItem
      Caption = 'Decompress all'
      OnClick = DecompressAllClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CopyNameSelected: TMenuItem
      Caption = 'Copy name selected'
      OnClick = CopyNameSelectedClick
    end
    object CopyNameAll: TMenuItem
      Caption = 'Copy name all'
      OnClick = CopyNameAllClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object SelectAll: TMenuItem
      Caption = 'Select all'
      OnClick = SelectAllClick
    end
    object UnselectAll: TMenuItem
      Caption = 'Unselect all'
      OnClick = UnselectAllClick
    end
    object InvertSelection: TMenuItem
      Caption = 'Invert selection'
      OnClick = InvertSelectionClick
    end
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Left = 136
    Top = 64
  end
end
