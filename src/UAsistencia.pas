unit UAsistencia;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, sqldb;

type

  { TfrmAsistencia }

  TfrmAsistencia = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
    pnlFiltros: TPanel;
    lblFecha: TLabel;
    edtFecha: TEdit;
    lblCurso: TLabel;
    cmbCurso: TComboBox;
    lblMateria: TLabel;
    cmbMateria: TComboBox;
    btnCargarLista: TButton;
    sgAsistencia: TStringGrid;
    pnlBottom: TPanel;
    btnTodosPresentes: TButton;
    btnGuardar: TButton;
    btnCerrar: TButton;
    lblResumen: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnCargarListaClick(Sender: TObject);
    procedure btnTodosPresentesClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure sgAsistenciaSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
    procedure sgAsistenciaDblClick(Sender: TObject);
  private
    FCursoIDs: TStringList;
    FMateriaIDs: TStringList;
    procedure CargarCursosYMaterias;
    procedure ActualizarResumen;
  public

  end;

var
  frmAsistencia: TfrmAsistencia;

implementation

uses
  UDataModule;

{$R *.lfm}

{ TfrmAsistencia }

procedure TfrmAsistencia.FormShow(Sender: TObject);
begin
  if not Assigned(FCursoIDs) then
    FCursoIDs := TStringList.Create;
  if not Assigned(FMateriaIDs) then
    FMateriaIDs := TStringList.Create;

  edtFecha.Text := FormatDateTime('yyyy-mm-dd', Now);
  CargarCursosYMaterias;

  // Configurar columnas del StringGrid
  sgAsistencia.ColCount := 5;
  sgAsistencia.RowCount := 1;
  sgAsistencia.Cells[0, 0] := 'ID';
  sgAsistencia.Cells[1, 0] := 'Legajo';
  sgAsistencia.Cells[2, 0] := 'Estudiante';
  sgAsistencia.Cells[3, 0] := 'Estado (Doble clic para cambiar)';
  sgAsistencia.Cells[4, 0] := 'Observaciones';

  sgAsistencia.ColWidths[0] := 40;
  sgAsistencia.ColWidths[1] := 110;
  sgAsistencia.ColWidths[2] := 260;
  sgAsistencia.ColWidths[3] := 200;
  sgAsistencia.ColWidths[4] := 240;
end;

procedure TfrmAsistencia.CargarCursosYMaterias;
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

  cmbMateria.Items.Clear;
  FMateriaIDs.Clear;
  Q := DM.qryMaterias;
  if DM.ConsultarSQL('SELECT id, CONCAT(codigo, '' - '', nombre) AS descrip FROM materias WHERE activo = 1 ORDER BY nombre', Q) then
  begin
    while not Q.EOF do
    begin
      cmbMateria.Items.Add(Q.FieldByName('descrip').AsString);
      FMateriaIDs.Add(Q.FieldByName('id').AsString);
      Q.Next;
    end;
    if cmbMateria.Items.Count > 0 then
      cmbMateria.ItemIndex := 0;
  end;
end;

procedure TfrmAsistencia.btnCargarListaClick(Sender: TObject);
var
  SQL: string;
  Q: TSQLQuery;
  RowIdx: Integer;
  CursoId, MateriaId, Fecha: string;
begin
  if (cmbCurso.ItemIndex < 0) or (cmbMateria.ItemIndex < 0) then
  begin
    ShowMessage('Debe seleccionar curso y materia.');
    Exit;
  end;

  CursoId := FCursoIDs[cmbCurso.ItemIndex];
  MateriaId := FMateriaIDs[cmbMateria.ItemIndex];
  Fecha := Trim(edtFecha.Text);

  // Consulta legacy con LEFT JOIN para traer asistencias ya tomadas o defaults
  SQL := 'SELECT a.id, a.legajo, CONCAT(a.apellido, '', '', a.nombre) AS estudiante, ' +
         'COALESCE(asi.estado, ''PRESENTE'') AS estado, ' +
         'COALESCE(asi.observacion, '''') AS observacion ' +
         'FROM alumnos a ' +
         'LEFT JOIN asistencias asi ON asi.alumno_id = a.id ' +
         '     AND asi.materia_id = ' + MateriaId + ' ' +
         '     AND asi.fecha = ''' + Fecha + ''' ' +
         'WHERE a.curso_id = ' + CursoId + ' AND a.estado = ''REGULAR'' ' +
         'ORDER BY a.apellido, a.nombre';

  Q := DM.qryAsistencias;
  if DM.ConsultarSQL(SQL, Q) then
  begin
    sgAsistencia.RowCount := 1;
    RowIdx := 1;
    while not Q.EOF do
    begin
      sgAsistencia.RowCount := RowIdx + 1;
      sgAsistencia.Cells[0, RowIdx] := Q.FieldByName('id').AsString;
      sgAsistencia.Cells[1, RowIdx] := Q.FieldByName('legajo').AsString;
      sgAsistencia.Cells[2, RowIdx] := Q.FieldByName('estudiante').AsString;
      sgAsistencia.Cells[3, RowIdx] := Q.FieldByName('estado').AsString;
      sgAsistencia.Cells[4, RowIdx] := Q.FieldByName('observacion').AsString;
      Inc(RowIdx);
      Q.Next;
    end;
    ActualizarResumen;
  end;
end;

procedure TfrmAsistencia.sgAsistenciaDblClick(Sender: TObject);
var
  R: Integer;
  Actual: string;
begin
  R := sgAsistencia.Row;
  if (R >= 1) and (R < sgAsistencia.RowCount) then
  begin
    Actual := sgAsistencia.Cells[3, R];
    if Actual = 'PRESENTE' then
      sgAsistencia.Cells[3, R] := 'AUSENTE'
    else if Actual = 'AUSENTE' then
      sgAsistencia.Cells[3, R] := 'TARDE'
    else if Actual = 'TARDE' then
      sgAsistencia.Cells[3, R] := 'JUSTIFICADO'
    else
      sgAsistencia.Cells[3, R] := 'PRESENTE';

    ActualizarResumen;
  end;
end;

procedure TfrmAsistencia.sgAsistenciaSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
end;

procedure TfrmAsistencia.btnTodosPresentesClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 1 to sgAsistencia.RowCount - 1 do
  begin
    sgAsistencia.Cells[3, i] := 'PRESENTE';
  end;
  ActualizarResumen;
end;

procedure TfrmAsistencia.ActualizarResumen;
var
  i, Pres, Aus, Tard, Just: Integer;
begin
  Pres := 0;
  Aus := 0;
  Tard := 0;
  Just := 0;
  for i := 1 to sgAsistencia.RowCount - 1 do
  begin
    if sgAsistencia.Cells[3, i] = 'PRESENTE' then Inc(Pres)
    else if sgAsistencia.Cells[3, i] = 'AUSENTE' then Inc(Aus)
    else if sgAsistencia.Cells[3, i] = 'TARDE' then Inc(Tard)
    else if sgAsistencia.Cells[3, i] = 'JUSTIFICADO' then Inc(Just);
  end;

  lblResumen.Caption := Format('Total Alumnos: %d | Presentes: %d | Ausentes: %d | Tardes: %d | Justificados: %d',
    [sgAsistencia.RowCount - 1, Pres, Aus, Tard, Just]);
end;

procedure TfrmAsistencia.btnGuardarClick(Sender: TObject);
var
  i: Integer;
  MateriaId, Fecha, AlumnoId, Estado, Obs, SQL: string;
  Guardados: Integer;
begin
  if sgAsistencia.RowCount <= 1 then
  begin
    ShowMessage('No hay alumnos cargados en la lista.');
    Exit;
  end;

  MateriaId := FMateriaIDs[cmbMateria.ItemIndex];
  Fecha := Trim(edtFecha.Text);
  Guardados := 0;

  // Patron Legacy: Batch Loop ejecutando consultas SQL individuales
  for i := 1 to sgAsistencia.RowCount - 1 do
  begin
    AlumnoId := sgAsistencia.Cells[0, i];
    Estado := sgAsistencia.Cells[3, i];
    Obs := sgAsistencia.Cells[4, i];

    SQL := 'INSERT INTO asistencias (alumno_id, materia_id, fecha, estado, observacion) ' +
           'VALUES (' + AlumnoId + ', ' + MateriaId + ', ''' + Fecha + ''', ''' + Estado + ''', ''' + Obs + ''') ' +
           'ON DUPLICATE KEY UPDATE estado = VALUES(estado), observacion = VALUES(observacion)';

    if DM.EjecutarSQL(SQL) then
      Inc(Guardados);
  end;

  ShowMessage(Format('Se guardaron exitosamente %d registros de asistencia para la fecha %s.', [Guardados, Fecha]));
end;

procedure TfrmAsistencia.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
