object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 320
  HorizontalOffset = 300
  VerticalOffset = 200
  Width = 380
  object Conn: TMySQL80Connection
    Connected = False
    LoginPrompt = False
    KeepConnection = False
    Transaction = Trans
    Left = 40
    Top = 24
  end
  object Trans: TSQLTransaction
    Active = False
    Database = Conn
    Left = 120
    Top = 24
  end
  object qryGeneral: TSQLQuery
    FieldDefs = <>
    Database = Conn
    Transaction = Trans
    Params = <>
    Left = 200
    Top = 24
  end
  object qryAlumnos: TSQLQuery
    FieldDefs = <>
    Database = Conn
    Transaction = Trans
    Params = <>
    Left = 40
    Top = 96
  end
  object dsAlumnos: TDataSource
    DataSet = qryAlumnos
    Left = 120
    Top = 96
  end
  object qryCursos: TSQLQuery
    FieldDefs = <>
    Database = Conn
    Transaction = Trans
    Params = <>
    Left = 200
    Top = 96
  end
  object dsCursos: TDataSource
    DataSet = qryCursos
    Left = 280
    Top = 96
  end
  object qryMaterias: TSQLQuery
    FieldDefs = <>
    Database = Conn
    Transaction = Trans
    Params = <>
    Left = 40
    Top = 168
  end
  object dsMaterias: TDataSource
    DataSet = qryMaterias
    Left = 120
    Top = 168
  end
  object qryAsistencias: TSQLQuery
    FieldDefs = <>
    Database = Conn
    Transaction = Trans
    Params = <>
    Left = 200
    Top = 168
  end
  object dsAsistencias: TDataSource
    DataSet = qryAsistencias
    Left = 280
    Top = 168
  end
  object qryNotas: TSQLQuery
    FieldDefs = <>
    Database = Conn
    Transaction = Trans
    Params = <>
    Left = 40
    Top = 240
  end
  object dsNotas: TDataSource
    DataSet = qryNotas
    Left = 120
    Top = 240
  end
end
