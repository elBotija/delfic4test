object frmMain: TfrmMain
  Left = 240
  Top = 120
  Width = 920
  Height = 650
  Caption = 'Sistema de Gestion Escolar v1.2 (Legacy Delphi)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 15
      Width = 370
      Height = 22
      Caption = 'Sistema de Gestion Escolar - Modulo Alumnos'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object pnlActions: TPanel
      Left = 504
      Top = 0
      Width = 408
      Height = 56
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnNavAsistencia: TButton
        Left = 40
        Top = 10
        Width = 175
        Height = 35
        Caption = 'Pantalla 2: Asistencias'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnNavAsistenciaClick
      end
      object btnNavNotas: TButton
        Left = 224
        Top = 10
        Width = 175
        Height = 35
        Caption = 'Pantalla 3: Notas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btnNavNotasClick
      end
    end
  end
  object pnlSearch: TPanel
    Left = 0
    Top = 56
    Width = 912
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblBuscar: TLabel
      Left = 16
      Top = 14
      Width = 117
      Height = 13
      Caption = 'Buscar por Apellido/DNI:'
    end
    object txtBuscar: TEdit
      Left = 168
      Top = 10
      Width = 260
      Height = 21
      TabOrder = 0
    end
    object btnBuscar: TButton
      Left = 436
      Top = 9
      Width = 80
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
    object btnLimpiarFiltro: TButton
      Left = 524
      Top = 9
      Width = 110
      Height = 25
      Caption = 'Mostrar Todos'
      TabOrder = 2
      OnClick = btnLimpiarFiltroClick
    end
  end
  object dbgAlumnos: TDBGrid
    Left = 0
    Top = 100
    Width = 912
    Height = 254
    Align = alClient
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnCellClick = dbgAlumnosCellClick
  end
  object pnlDetalle: TPanel
    Left = 0
    Top = 354
    Width = 912
    Height = 248
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object gbDetalle: TGroupBox
      Left = 8
      Top = 8
      Width = 896
      Height = 232
      Align = alClient
      Caption = ' Ficha del Alumno (Datos y Edicion) '
      TabOrder = 0
      object lblIdInterno: TLabel
        Left = 16
        Top = 20
        Width = 14
        Height = 13
        Caption = 'ID:'
      end
      object txtId: TEdit
        Left = 80
        Top = 16
        Width = 60
        Height = 21
        Enabled = False
        TabOrder = 0
      end
      object lblLegajo: TLabel
        Left = 160
        Top = 20
        Width = 35
        Height = 13
        Caption = 'Legajo:'
      end
      object edtLegajo: TEdit
        Left = 216
        Top = 16
        Width = 140
        Height = 21
        TabOrder = 1
      end
      object lblCurso: TLabel
        Left = 380
        Top = 20
        Width = 30
        Height = 13
        Caption = 'Curso:'
      end
      object cmbCurso: TComboBox
        Left = 430
        Top = 16
        Width = 180
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
      end
      object lblEstado: TLabel
        Left = 630
        Top = 20
        Width = 36
        Height = 13
        Caption = 'Estado:'
      end
      object cmbEstado: TComboBox
        Left = 690
        Top = 16
        Width = 180
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        Items.Strings = (
          'REGULAR'
          'LIBRE'
          'EGRESADO'
          'SUSPENDIDO')
      end
      object lblApellido: TLabel
        Left = 16
        Top = 55
        Width = 40
        Height = 13
        Caption = 'Apellido:'
      end
      object edtApellido: TEdit
        Left = 80
        Top = 52
        Width = 276
        Height = 21
        TabOrder = 4
      end
      object lblNombre: TLabel
        Left = 380
        Top = 55
        Width = 40
        Height = 13
        Caption = 'Nombre:'
      end
      object edtNombre: TEdit
        Left = 440
        Top = 52
        Width = 280
        Height = 21
        TabOrder = 5
      end
      object lblDni: TLabel
        Left = 16
        Top = 95
        Width = 22
        Height = 13
        Caption = 'DNI:'
      end
      object edtDni: TEdit
        Left = 80
        Top = 92
        Width = 160
        Height = 21
        TabOrder = 6
      end
      object lblEmail: TLabel
        Left = 260
        Top = 95
        Width = 28
        Height = 13
        Caption = 'Email:'
      end
      object edtEmail: TEdit
        Left = 310
        Top = 92
        Width = 250
        Height = 21
        TabOrder = 7
      end
      object lblTelefono: TLabel
        Left = 580
        Top = 95
        Width = 45
        Height = 13
        Caption = 'Telefono:'
      end
      object edtTelefono: TEdit
        Left = 645
        Top = 92
        Width = 225
        Height = 21
        TabOrder = 8
      end
      object btnNuevo: TButton
        Left = 180
        Top = 145
        Width = 110
        Height = 35
        Caption = '&Nuevo'
        TabOrder = 9
        OnClick = btnNuevoClick
      end
      object btnGuardar: TButton
        Left = 310
        Top = 145
        Width = 120
        Height = 35
        Caption = '&Guardar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 10
        OnClick = btnGuardarClick
      end
      object btnEliminar: TButton
        Left = 450
        Top = 145
        Width = 110
        Height = 35
        Caption = '&Eliminar'
        TabOrder = 11
        OnClick = btnEliminarClick
      end
      object btnCancelar: TButton
        Left = 580
        Top = 145
        Width = 110
        Height = 35
        Caption = '&Cancelar'
        TabOrder = 12
        OnClick = btnCancelarClick
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 40
    Top = 130
    object mnuArchivo: TMenuItem
      Caption = '&Archivo'
      object mnuAlumnos: TMenuItem
        Caption = '&Alumnos'
      end
      object mnuSeparador1: TMenuItem
        Caption = '-'
      end
      object mnuSalir: TMenuItem
        Caption = '&Salir'
        OnClick = mnuSalirClick
      end
    end
    object mnuProcesos: TMenuItem
      Caption = '&Procesos'
      object mnuAsistencia: TMenuItem
        Caption = 'Toma de &Asistencia'
        OnClick = btnNavAsistenciaClick
      end
      object mnuNotas: TMenuItem
        Caption = 'Carga de &Calificaciones'
        OnClick = btnNavNotasClick
      end
    end
    object mnuAyuda: TMenuItem
      Caption = 'A&yuda'
      object mnuAcercaDe: TMenuItem
        Caption = '&Acerca de...'
        OnClick = mnuAcercaDeClick
      end
    end
  end
end
