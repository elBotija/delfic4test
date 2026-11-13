object frmAsistencia: TfrmAsistencia
  Left = 280
  Top = 150
  Width = 880
  Height = 600
  Caption = 'Toma de Asistencia Diaria (Legacy Delphi)'
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
    Width = 872
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 14
      Width = 320
      Height = 18
      Caption = 'Modulo de Asistencia Escolar - Pantalla 2'
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
    Width = 872
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblFecha: TLabel
      Left = 16
      Top = 20
      Width = 33
      Height = 13
      Caption = 'Fecha:'
    end
    object edtFecha: TEdit
      Left = 64
      Top = 16
      Width = 100
      Height = 21
      TabOrder = 0
    end
    object lblCurso: TLabel
      Left = 180
      Top = 20
      Width = 30
      Height = 13
      Caption = 'Curso:'
    end
    object cmbCurso: TComboBox
      Left = 226
      Top = 16
      Width = 160
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
    end
    object lblMateria: TLabel
      Left = 400
      Top = 20
      Width = 38
      Height = 13
      Caption = 'Materia:'
    end
    object cmbMateria: TComboBox
      Left = 458
      Top = 16
      Width = 220
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
    end
    object btnCargarLista: TButton
      Left = 690
      Height = 28
      Top = 14
      Width = 160
      Caption = 'Cargar Alumnos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnCargarListaClick
    end
  end
  object sgAsistencia: TStringGrid
    Left = 0
    Top = 110
    Width = 872
    Height = 420
    Align = alClient
    ColCount = 5
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    RowCount = 1
    TabOrder = 2
    OnDblClick = sgAsistenciaDblClick
    OnSelectCell = sgAsistenciaSelectCell
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 530
    Width = 872
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object lblResumen: TLabel
      Left = 16
      Top = 10
      Width = 380
      Height = 13
      Caption = 'Total Alumnos: 0 | Presentes: 0 | Ausentes: 0 | Tardes: 0 | Justificados: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnTodosPresentes: TButton
      Left = 16
      Top = 32
      Width = 180
      Height = 32
      Caption = 'Marcar Todos PRESENTE'
      TabOrder = 0
      OnClick = btnTodosPresentesClick
    end
    object btnGuardar: TButton
      Left = 560
      Top = 32
      Width = 170
      Height = 32
      Caption = '&Guardar Asistencias'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnGuardarClick
    end
    object btnCerrar: TButton
      Left = 745
      Top = 32
      Width = 110
      Height = 32
      Caption = 'Cerrar'
      TabOrder = 2
      OnClick = btnCerrarClick
    end
  end
end
