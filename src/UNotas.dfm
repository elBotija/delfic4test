object frmNotas: TfrmNotas
  Left = 260
  Top = 130
  Width = 900
  Height = 620
  Caption = 'Carga y Consulta de Calificaciones (Legacy Delphi)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 892
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 14
      Width = 330
      Height = 18
      Caption = 'Modulo de Calificaciones Escolares - Pantalla 3'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlFiltros: TPanel
    Left = 0
    Top = 50
    Width = 892
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblCurso: TLabel
      Left = 16
      Top = 20
      Width = 30
      Height = 13
      Caption = 'Curso:'
    end
    object cmbCurso: TComboBox
      Left = 60
      Top = 16
      Width = 140
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object lblMateria: TLabel
      Left = 215
      Top = 20
      Width = 38
      Height = 13
      Caption = 'Materia:'
    end
    object cmbMateria: TComboBox
      Left = 270
      Top = 16
      Width = 190
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
    end
    object lblPeriodo: TLabel
      Left = 475
      Top = 20
      Width = 39
      Height = 13
      Caption = 'Periodo:'
    end
    object cmbPeriodo: TComboBox
      Left = 530
      Top = 16
      Width = 170
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        '1er Trimestre'
        '2do Trimestre'
        '3er Trimestre'
        'Final Diciembre'
        'Final Febrero')
    end
    object btnCargarNotas: TButton
      Left = 715
      Top = 14
      Width = 165
      Height = 28
      Caption = 'Cargar Calificaciones'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnCargarNotasClick
    end
  end
  object sgNotas: TStringGrid
    Left = 0
    Top = 110
    Width = 892
    Height = 390
    Align = alClient
    ColCount = 6
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    RowCount = 1
    TabOrder = 2
  end
  object pnlEstadisticas: TPanel
    Left = 0
    Top = 500
    Width = 892
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnCalcular: TButton
      Left = 16
      Top = 10
      Width = 150
      Height = 28
      Caption = 'Recalcular Totales'
      TabOrder = 0
      OnClick = btnCalcularClick
    end
    object lblPromedio: TLabel
      Left = 190
      Top = 16
      Width = 135
      Height = 13
      Caption = 'Promedio General: S/D'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAprobados: TLabel
      Left = 450
      Top = 16
      Width = 73
      Height = 13
      Caption = 'Aprobados: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDesaprobados: TLabel
      Left = 600
      Top = 16
      Width = 92
      Height = 13
      Caption = 'Desaprobados: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 550
    Width = 892
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object btnGuardarNotas: TButton
      Left = 460
      Top = 16
      Width = 160
      Height = 36
      Caption = '&Guardar Calificaciones'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnGuardarNotasClick
    end
    object btnExportarReporte: TButton
      Left = 635
      Top = 16
      Width = 140
      Height = 36
      Caption = 'Exportar Boletin TXT'
      TabOrder = 1
      OnClick = btnExportarReporteClick
    end
    object btnCerrar: TButton
      Left = 790
      Top = 16
      Width = 95
      Height = 36
      Caption = 'Cerrar'
      TabOrder = 2
      OnClick = btnCerrarClick
    end
  end
end
