unit UDataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, DB, sqldb, mysql80conn, Dialogs;

type

  { TDM }

  TDM = class(TDataModule)
    Conn: TMySQL80Connection;
    Trans: TSQLTransaction;
    qryGeneral: TSQLQuery;
    qryAlumnos: TSQLQuery;
    dsAlumnos: TDataSource;
    qryCursos: TSQLQuery;
    dsCursos: TDataSource;
    qryMaterias: TSQLQuery;
    dsMaterias: TDataSource;
    qryAsistencias: TSQLQuery;
    dsAsistencias: TDataSource;
    qryNotas: TSQLQuery;
    dsNotas: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FHost: string;
    FPort: Integer;
    FDatabase: string;
    FUser: string;
    FPass: string;
    procedure CargarConfiguracion;
  public
    function Conectar: Boolean;
    procedure Desconectar;
    function EjecutarSQL(const ASQL: string): Boolean;
    function ConsultarSQL(const ASQL: string; AQry: TSQLQuery): Boolean;
  end;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.CargarConfiguracion;
var
  Ini: TIniFile;
  IniPath: string;
  EnvHost, EnvPort, EnvDb, EnvUser, EnvPass: string;
begin
  // Valores por defecto
  FHost := '127.0.0.1';
  FPort := 3306;
  FDatabase := 'colegio_legacy';
  FUser := 'colegio_user';
  FPass := 'colegio_pass';

  // Leer desde config.ini si existe en la ruta de la aplicacion
  IniPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  if not FileExists(IniPath) then
    IniPath := ExtractFilePath(ParamStr(0)) + '../src/config.ini';

  if FileExists(IniPath) then
  begin
    Ini := TIniFile.Create(IniPath);
    try
      FHost := Ini.ReadString('DATABASE', 'Host', FHost);
      FPort := Ini.ReadInteger('DATABASE', 'Port', FPort);
      FDatabase := Ini.ReadString('DATABASE', 'Database', FDatabase);
      FUser := Ini.ReadString('DATABASE', 'User', FUser);
      FPass := Ini.ReadString('DATABASE', 'Password', FPass);
    finally
      Ini.Free;
    end;
  end;

  // Sobrescribir con variables de entorno (ideal para Docker)
  EnvHost := GetEnvironmentVariable('DB_HOST');
  if EnvHost <> '' then FHost := EnvHost;

  EnvPort := GetEnvironmentVariable('DB_PORT');
  if EnvPort <> '' then FPort := StrToIntDef(EnvPort, 3306);

  EnvDb := GetEnvironmentVariable('DB_NAME');
  if EnvDb <> '' then FDatabase := EnvDb;

  EnvUser := GetEnvironmentVariable('DB_USER');
  if EnvUser <> '' then FUser := EnvUser;

  EnvPass := GetEnvironmentVariable('DB_PASS');
  if EnvPass <> '' then FPass := EnvPass;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  CargarConfiguracion;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  Desconectar;
end;

function TDM.Conectar: Boolean;
begin
  Result := False;
  try
    if Conn.Connected then
      Conn.Close;

    Conn.HostName := FHost;
    Conn.Port := FPort;
    Conn.DatabaseName := FDatabase;
    Conn.UserName := FUser;
    Conn.Password := FPass;
    Conn.Transaction := Trans;

    Conn.Open;
    Trans.Active := True;
    Result := True;
  except
    on E: Exception do
    begin
      ShowMessage('Error al conectar a la Base de Datos MariaDB (' + FHost + ':' + IntToStr(FPort) + '): ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TDM.Desconectar;
begin
  try
    if Trans.Active then
      Trans.Rollback;
    if Conn.Connected then
      Conn.Close;
  except
    // Silencio en cierre legacy
  end;
end;

function TDM.EjecutarSQL(const ASQL: string): Boolean;
begin
  Result := False;
  try
    qryGeneral.Close;
    qryGeneral.SQL.Text := ASQL;
    qryGeneral.ExecSQL;
    Trans.CommitRetaining;
    Result := True;
  except
    on E: Exception do
    begin
      Trans.RollbackRetaining;
      ShowMessage('Error SQL Legacy: ' + E.Message + LineEnding + 'Consulta: ' + ASQL);
    end;
  end;
end;

function TDM.ConsultarSQL(const ASQL: string; AQry: TSQLQuery): Boolean;
begin
  Result := False;
  try
    AQry.Close;
    AQry.SQL.Text := ASQL;
    AQry.Open;
    Result := True;
  except
    on E: Exception do
    begin
      ShowMessage('Error en Consulta: ' + E.Message + LineEnding + 'SQL: ' + ASQL);
    end;
  end;
end;

end.
