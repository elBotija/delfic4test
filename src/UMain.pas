unit UMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  StdCtrls, DBGrids, DBCtrls, DB, sqldb;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    mnuArchivo: TMenuItem;
    mnuAlumnos: TMenuItem;
    mnuSeparador1: TMenuItem;
    mnuSalir: TMenuItem;
    mnuProcesos: TMenuItem;
    mnuAsistencia: TMenuItem;
    mnuNotas: TMenuItem;
    mnuAyuda: TMenuItem;
    mnuAcercaDe: TMenuItem;
    pnlTop: TPanel;
    pnlActions: TPanel;
    btnNavAsistencia: TButton;
    btnNavNotas: TButton;
    lblTitulo: TLabel;
    pnlSearch: TPanel;
    lblBuscar: TLabel;
    txtBuscar: TEdit;
    btnBuscar: TButton;
    btnLimpiarFiltro: TButton;
    dbgAlumnos: TDBGrid;
    pnlDetalle: TPanel;
    gbDetalle: TGroupBox;
    lblLegajo: TLabel;
    edtLegajo: TEdit;
    lblApellido: TLabel;
    edtApellido: TEdit;
    lblNombre: TLabel;
    edtNombre: TEdit;
    lblDni: TLabel;
    edtDni: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblTelefono: TLabel;
    edtTelefono: TEdit;
    lblCurso: TLabel;
    cmbCurso: TComboBox;
    lblEstado: TLabel;
    cmbEstado: TComboBox;
    btnNuevo: TButton;
    btnGuardar: TButton;
    btnEliminar: TButton;
    btnCancelar: TButton;
    lblIdInterno: TLabel;
    txtId: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnLimpiarFiltroClick(Sender: TObject);
    procedure dbgAlumnosCellClick(Column: TColumn);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNavAsistenciaClick(Sender: TObject);
    procedure btnNavNotasClick(Sender: TObject);
    procedure mnuSalirClick(Sender: TObject);
    procedure mnuAcercaDeClick(Sender: TObject);
  private
    FCursoIDs: TStringList;
    procedure CargarCursos;
    procedure CargarAlumnos(const AFiltro: string);
    procedure LimpiarFormulario;
    procedure CargarRegistroSeleccionado;
  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  UDataModule, UAsistencia, UNotas;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormShow(Sender: TObject);
begin
  FCursoIDs := TStringList.Create;
  if DM.Conectar then
  begin
    CargarCursos;
    CargarAlumnos('');
  end;
end;

procedure TfrmMain.CargarCursos;
var
  Q: TSQLQuery;
begin
  cmbCurso.Items.Clear;
  FCursoIDs.Clear;
  Q := DM.qryCursos;
  if DM.ConsultarSQL('SELECT id, nombre FROM cursos WHERE activo = 1 ORDER BY anio_escolar, division', Q) then
  begin
    while not Q.EOF do
    begin
      cmbCurso.Items.Add(Q.FieldByName('nombre').AsString);
      FCursoIDs.Add(Q.FieldByName('id').AsString);
      Q.Next;
    end;
    if cmbCurso.Items.Count > 0 then
      cmbCurso.ItemIndex := 0;
  end;
end;

procedure TfrmMain.CargarAlumnos(const AFiltro: string);
var
  SQL: string;
begin
  // Patron Legacy: Consulta SQL directa embebida en codigo con concatenacion
  SQL := 'SELECT a.id, a.legajo, a.apellido, a.nombre, a.dni, a.email, a.telefono, ' +
         'c.nombre AS curso, a.curso_id, a.estado, a.fecha_alta ' +
         'FROM alumnos a ' +
         'INNER JOIN cursos c ON a.curso_id = c.id ';

  if Trim(AFiltro) <> '' then
  begin
    SQL := SQL + 'WHERE a.apellido LIKE ''%' + Trim(AFiltro) + '%'' ' +
                 'OR a.nombre LIKE ''%' + Trim(AFiltro) + '%'' ' +
                 'OR a.legajo LIKE ''%' + Trim(AFiltro) + '%'' ';
  end;

  SQL := SQL + 'ORDER BY a.apellido, a.nombre';

  if DM.ConsultarSQL(SQL, DM.qryAlumnos) then
  begin
    dbgAlumnos.DataSource := DM.dsAlumnos;
    CargarRegistroSeleccionado;
  end;
end;

procedure TfrmMain.CargarRegistroSeleccionado;
var
  Q: TSQLQuery;
  CursoIdActual: string;
  Idx: Integer;
begin
  Q := DM.qryAlumnos;
  if (Q.Active) and (not Q.IsEmpty) then
  begin
    txtId.Text := Q.FieldByName('id').AsString;
    edtLegajo.Text := Q.FieldByName('legajo').AsString;
    edtApellido.Text := Q.FieldByName('apellido').AsString;
    edtNombre.Text := Q.FieldByName('nombre').AsString;
    edtDni.Text := Q.FieldByName('dni').AsString;
    edtEmail.Text := Q.FieldByName('email').AsString;
    edtTelefono.Text := Q.FieldByName('telefono').AsString;
    cmbEstado.Text := Q.FieldByName('estado').AsString;

    CursoIdActual := Q.FieldByName('curso_id').AsString;
    Idx := FCursoIDs.IndexOf(CursoIdActual);
    if Idx >= 0 then
      cmbCurso.ItemIndex := Idx;
  end;
end;

procedure TfrmMain.LimpiarFormulario;
begin
  txtId.Text := '';
  edtLegajo.Text := 'LEG-' + FormatDateTime('yyyy', Now) + '-';
  edtApellido.Text := '';
  edtNombre.Text := '';
  edtDni.Text := '';
  edtEmail.Text := '';
  edtTelefono.Text := '';
  cmbEstado.ItemIndex := 0;
  edtLegajo.SetFocus;
end;

procedure TfrmMain.dbgAlumnosCellClick(Column: TColumn);
begin
  CargarRegistroSeleccionado;
end;

procedure TfrmMain.btnBuscarClick(Sender: TObject);
begin
  CargarAlumnos(txtBuscar.Text);
end;

procedure TfrmMain.btnLimpiarFiltroClick(Sender: TObject);
begin
  txtBuscar.Text := '';
  CargarAlumnos('');
end;

procedure TfrmMain.btnNuevoClick(Sender: TObject);
begin
  LimpiarFormulario;
end;

procedure TfrmMain.btnGuardarClick(Sender: TObject);
var
  SQL: string;
  CursoId: string;
begin
  // Validaciones clasicas en capa visual
  if Trim(edtLegajo.Text) = '' then
  begin
    ShowMessage('El campo Legajo es obligatorio.');
    edtLegajo.SetFocus;
    Exit;
  end;

  if Trim(edtApellido.Text) = '' then
  begin
    ShowMessage('El campo Apellido es obligatorio.');
    edtApellido.SetFocus;
    Exit;
  end;

  if Trim(edtNombre.Text) = '' then
  begin
    ShowMessage('El campo Nombre es obligatorio.');
    edtNombre.SetFocus;
    Exit;
  end;

  if (cmbCurso.ItemIndex < 0) or (cmbCurso.ItemIndex >= FCursoIDs.Count) then
  begin
    ShowMessage('Debe seleccionar un curso valido.');
    Exit;
  end;

  CursoId := FCursoIDs[cmbCurso.ItemIndex];

  // Anti-patron legacy clasico: SQL dinamico concatenado
  if Trim(txtId.Text) = '' then
  begin
    // INSERT
    SQL := 'INSERT INTO alumnos (legajo, apellido, nombre, dni, email, telefono, curso_id, estado, fecha_alta) ' +
           'VALUES (' +
           '''' + Trim(edtLegajo.Text) + ''', ' +
           '''' + Trim(edtApellido.Text) + ''', ' +
           '''' + Trim(edtNombre.Text) + ''', ' +
           '''' + Trim(edtDni.Text) + ''', ' +
           '''' + Trim(edtEmail.Text) + ''', ' +
           '''' + Trim(edtTelefono.Text) + ''', ' +
           CursoId + ', ' +
           '''' + Trim(cmbEstado.Text) + ''', ' +
           'CURDATE())';
  end
  else
  begin
    // UPDATE
    SQL := 'UPDATE alumnos SET ' +
           'legajo = ''' + Trim(edtLegajo.Text) + ''', ' +
           'apellido = ''' + Trim(edtApellido.Text) + ''', ' +
           'nombre = ''' + Trim(edtNombre.Text) + ''', ' +
           'dni = ''' + Trim(edtDni.Text) + ''', ' +
           'email = ''' + Trim(edtEmail.Text) + ''', ' +
           'telefono = ''' + Trim(edtTelefono.Text) + ''', ' +
           'curso_id = ' + CursoId + ', ' +
           'estado = ''' + Trim(cmbEstado.Text) + ''' ' +
           'WHERE id = ' + txtId.Text;
  end;

  if DM.EjecutarSQL(SQL) then
  begin
    ShowMessage('Datos del alumno guardados correctamente.');
    CargarAlumnos(txtBuscar.Text);
  end;
end;

procedure TfrmMain.btnEliminarClick(Sender: TObject);
var
  SQL: string;
begin
  if Trim(txtId.Text) = '' then
  begin
    ShowMessage('Seleccione un alumno de la lista para eliminar.');
    Exit;
  end;

  if MessageDlg('Confirmar', '¿Esta seguro de dar de baja al alumno ' + edtApellido.Text + ', ' + edtNombre.Text + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    SQL := 'DELETE FROM alumnos WHERE id = ' + txtId.Text;
    if DM.EjecutarSQL(SQL) then
    begin
      ShowMessage('Alumno eliminado.');
      LimpiarFormulario;
      CargarAlumnos(txtBuscar.Text);
    end;
  end;
end;

procedure TfrmMain.btnCancelarClick(Sender: TObject);
begin
  CargarRegistroSeleccionado;
end;

procedure TfrmMain.btnNavAsistenciaClick(Sender: TObject);
begin
  if not Assigned(frmAsistencia) then
    frmAsistencia := TfrmAsistencia.Create(Self);
  frmAsistencia.Show;
end;

procedure TfrmMain.btnNavNotasClick(Sender: TObject);
begin
  if not Assigned(frmNotas) then
    frmNotas := TfrmNotas.Create(Self);
  frmNotas.Show;
end;

procedure TfrmMain.mnuSalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mnuAcercaDeClick(Sender: TObject);
begin
  ShowMessage('Sistema de Gestion Escolar Legacy v1.2' + LineEnding +
              'Desarrollado originalmente en Delphi 7 / Lazarus' + LineEnding +
              'Base de Datos: MariaDB / MySQL' + LineEnding +
              'Caso de Prueba de Migracion de Arquitectura.');
end;

end.
