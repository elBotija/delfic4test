unit UNotas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, sqldb;

type

  { TfrmNotas }

  TfrmNotas = class(TForm)
    pnlTop: TPanel;
    lblTitulo: TLabel;
    pnlFiltros: TPanel;
    lblCurso: TLabel;
    cmbCurso: TComboBox;
    lblMateria: TLabel;
    cmbMateria: TComboBox;
    lblPeriodo: TLabel;
    cmbPeriodo: TComboBox;
    btnCargarNotas: TButton;
    sgNotas: TStringGrid;
    pnlEstadisticas: TPanel;
    btnCalcular: TButton;
    lblPromedio: TLabel;
    lblAprobados: TLabel;
    lblDesaprobados: TLabel;
    pnlBottom: TPanel;
    btnGuardarNotas: TButton;
    btnExportarReporte: TButton;
    btnCerrar: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCargarNotasClick(Sender: TObject);
    procedure btnCalcularClick(Sender: TObject);
    procedure btnGuardarNotasClick(Sender: TObject);
    procedure btnExportarReporteClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure sgNotasEditingDone(Sender: TObject);
  private
    FCursoIDs: TStringList;
    FMateriaIDs: TStringList;
    procedure CargarCursosYMaterias;
    procedure RecalcularFila(ARow: Integer);
  public

  end;

var
  frmNotas: TfrmNotas;

implementation

uses
  UDataModule;

{$R *.lfm}

{ TfrmNotas }

procedure TfrmNotas.FormShow(Sender: TObject);
begin
  if not Assigned(FCursoIDs) then
    FCursoIDs := TStringList.Create;
  if not Assigned(FMateriaIDs) then
    FMateriaIDs := TStringList.Create;

  CargarCursosYMaterias;

  sgNotas.ColCount := 6;
  sgNotas.RowCount := 1;
  sgNotas.Cells[0, 0] := 'ID';
  sgNotas.Cells[1, 0] := 'Legajo';
  sgNotas.Cells[2, 0] := 'Estudiante';
  sgNotas.Cells[3, 0] := 'Nota (1.00 - 10.00)';
  sgNotas.Cells[4, 0] := 'Condición';
  sgNotas.Cells[5, 0] := 'Observaciones del Docente';

  sgNotas.ColWidths[0] := 40;
  sgNotas.ColWidths[1] := 110;
  sgNotas.ColWidths[2] := 240;
  sgNotas.ColWidths[3] := 140;
  sgNotas.ColWidths[4] := 120;
  sgNotas.ColWidths[5] := 220;

  cmbPeriodo.ItemIndex := 0;
end;

procedure TfrmNotas.CargarCursosYMaterias;
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

procedure TfrmNotas.btnCargarNotasClick(Sender: TObject);
var
  SQL, CursoId, MateriaId, Periodo: string;
  Q: TSQLQuery;
  RowIdx: Integer;
  NotaVal: Double;
  NotaStr: string;
begin
  if (cmbCurso.ItemIndex < 0) or (cmbMateria.ItemIndex < 0) or (cmbPeriodo.ItemIndex < 0) then
  begin
    ShowMessage('Debe seleccionar Curso, Materia y Periodo lectivo.');
    Exit;
  end;

  CursoId := FCursoIDs[cmbCurso.ItemIndex];
  MateriaId := FMateriaIDs[cmbMateria.ItemIndex];
  Periodo := Trim(cmbPeriodo.Text);

  // Consulta legacy con LEFT JOIN para obtener notas ya existentes o vacias
  SQL := 'SELECT a.id, a.legajo, CONCAT(a.apellido, '', '', a.nombre) AS estudiante, ' +
         'c.nota, c.observacion ' +
         'FROM alumnos a ' +
         'LEFT JOIN calificaciones c ON c.alumno_id = a.id ' +
         '     AND c.materia_id = ' + MateriaId + ' ' +
         '     AND c.periodo = ''' + Periodo + ''' ' +
         'WHERE a.curso_id = ' + CursoId + ' AND a.estado = ''REGULAR'' ' +
         'ORDER BY a.apellido, a.nombre';

  Q := DM.qryNotas;
  if DM.ConsultarSQL(SQL, Q) then
  begin
    sgNotas.RowCount := 1;
    RowIdx := 1;
    while not Q.EOF do
    begin
      sgNotas.RowCount := RowIdx + 1;
      sgNotas.Cells[0, RowIdx] := Q.FieldByName('id').AsString;
      sgNotas.Cells[1, RowIdx] := Q.FieldByName('legajo').AsString;
      sgNotas.Cells[2, RowIdx] := Q.FieldByName('estudiante').AsString;

      if Q.FieldByName('nota').IsNull then
      begin
        sgNotas.Cells[3, RowIdx] := '';
        sgNotas.Cells[4, RowIdx] := 'PENDIENTE';
      end
      else
      begin
        NotaVal := Q.FieldByName('nota').AsFloat;
        NotaStr := FormatFloat('0.00', NotaVal);
        sgNotas.Cells[3, RowIdx] := NotaStr;
        // Regla de negocio embebida en cliente (Legacy Smell)
        if NotaVal >= 6.0 then
          sgNotas.Cells[4, RowIdx] := 'APROBADO'
        else
          sgNotas.Cells[4, RowIdx] := 'DESAPROBADO';
      end;

      sgNotas.Cells[5, RowIdx] := Q.FieldByName('observacion').AsString;
      Inc(RowIdx);
      Q.Next;
    end;
    btnCalcularClick(Sender);
  end;
end;

procedure TfrmNotas.RecalcularFila(ARow: Integer);
var
  NotaStr: string;
  NotaVal: Double;
  FS: TFormatSettings;
begin
  if (ARow >= 1) and (ARow < sgNotas.RowCount) then
  begin
    NotaStr := Trim(sgNotas.Cells[3, ARow]);
    if NotaStr = '' then
    begin
      sgNotas.Cells[4, ARow] := 'PENDIENTE';
      Exit;
    end;

    FS := DefaultFormatSettings;
    FS.DecimalSeparator := '.';
    NotaStr := StringReplace(NotaStr, ',', '.', [rfReplaceAll]);

    if TryStrToFloat(NotaStr, NotaVal, FS) then
    begin
      if (NotaVal < 1.0) or (NotaVal > 10.0) then
      begin
        ShowMessage('La nota debe encontrarse en la escala de 1.00 a 10.00');
        sgNotas.Cells[3, ARow] := '';
        sgNotas.Cells[4, ARow] := 'PENDIENTE';
      end
      else
      begin
        sgNotas.Cells[3, ARow] := FormatFloat('0.00', NotaVal, FS);
        // Logica de aprobacion client-side
        if NotaVal >= 6.00 then
          sgNotas.Cells[4, ARow] := 'APROBADO'
        else
          sgNotas.Cells[4, ARow] := 'DESAPROBADO';
      end;
    end
    else
    begin
      ShowMessage('Formato de calificacion no valido. Utilice numeros (Ej: 7.50).');
      sgNotas.Cells[3, ARow] := '';
      sgNotas.Cells[4, ARow] := 'PENDIENTE';
    end;
  end;
end;

procedure TfrmNotas.sgNotasEditingDone(Sender: TObject);
begin
  RecalcularFila(sgNotas.Row);
  btnCalcularClick(Sender);
end;

procedure TfrmNotas.btnCalcularClick(Sender: TObject);
var
  i, CantNotas, Aprob, Desap: Integer;
  SumaNotas, NotaVal: Double;
  NotaStr: string;
  FS: TFormatSettings;
begin
  CantNotas := 0;
  SumaNotas := 0.0;
  Aprob := 0;
  Desap := 0;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  for i := 1 to sgNotas.RowCount - 1 do
  begin
    NotaStr := StringReplace(Trim(sgNotas.Cells[3, i]), ',', '.', [rfReplaceAll]);
    if (NotaStr <> '') and TryStrToFloat(NotaStr, NotaVal, FS) then
    begin
      Inc(CantNotas);
      SumaNotas := SumaNotas + NotaVal;
      if NotaVal >= 6.0 then
        Inc(Aprob)
      else
        Inc(Desap);
    end;
  end;

  if CantNotas > 0 then
    lblPromedio.Caption := Format('Promedio General: %.2f (Evaluados: %d)', [SumaNotas / CantNotas, CantNotas])
  else
    lblPromedio.Caption := 'Promedio General: S/D';

  lblAprobados.Caption := Format('Aprobados: %d', [Aprob]);
  lblDesaprobados.Caption := Format('Desaprobados: %d', [Desap]);
end;

procedure TfrmNotas.btnGuardarNotasClick(Sender: TObject);
var
  i, Guardados: Integer;
  MateriaId, Periodo, AlumnoId, NotaStr, Obs, SQL: string;
  NotaVal: Double;
  FS: TFormatSettings;
begin
  if sgNotas.RowCount <= 1 then
  begin
    ShowMessage('No hay lista de calificaciones cargada.');
    Exit;
  end;

  MateriaId := FMateriaIDs[cmbMateria.ItemIndex];
  Periodo := Trim(cmbPeriodo.Text);
  Guardados := 0;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  for i := 1 to sgNotas.RowCount - 1 do
  begin
    AlumnoId := sgNotas.Cells[0, i];
    NotaStr := StringReplace(Trim(sgNotas.Cells[3, i]), ',', '.', [rfReplaceAll]);
    Obs := Trim(sgNotas.Cells[5, i]);

    if (NotaStr <> '') and TryStrToFloat(NotaStr, NotaVal, FS) then
    begin
      SQL := 'INSERT INTO calificaciones (alumno_id, materia_id, periodo, nota, observacion) ' +
             'VALUES (' + AlumnoId + ', ' + MateriaId + ', ''' + Periodo + ''', ' +
             FormatFloat('0.00', NotaVal, FS) + ', ''' + Obs + ''') ' +
             'ON DUPLICATE KEY UPDATE nota = VALUES(nota), observacion = VALUES(observacion)';

      if DM.EjecutarSQL(SQL) then
        Inc(Guardados);
    end;
  end;

  ShowMessage(Format('Se guardaron %d calificaciones correspondientes al periodo "%s".', [Guardados, Periodo]));
end;

procedure TfrmNotas.btnExportarReporteClick(Sender: TObject);
var
  Reporte: TStringList;
  FileName: string;
  i: Integer;
begin
  if sgNotas.RowCount <= 1 then
  begin
    ShowMessage('No hay datos para exportar.');
    Exit;
  end;

  Reporte := TStringList.Create;
  try
    Reporte.Add('========================================================================');
    Reporte.Add('BOLETIN DE CALIFICACIONES - SISTEMA LEGACY');
    Reporte.Add('Curso: ' + cmbCurso.Text + ' | Materia: ' + cmbMateria.Text + ' | Periodo: ' + cmbPeriodo.Text);
    Reporte.Add('Fecha de Emision: ' + FormatDateTime('yyyy-mm-dd hh:nn', Now));
    Reporte.Add('========================================================================');
    Reporte.Add(Format('%-12s %-30s %-10s %-15s', ['LEGAJO', 'ESTUDIANTE', 'NOTA', 'CONDICION']));
    Reporte.Add('------------------------------------------------------------------------');

    for i := 1 to sgNotas.RowCount - 1 do
    begin
      Reporte.Add(Format('%-12s %-30s %-10s %-15s', [
        sgNotas.Cells[1, i],
        Copy(sgNotas.Cells[2, i], 1, 28),
        sgNotas.Cells[3, i],
        sgNotas.Cells[4, i]
      ]));
    end;
    Reporte.Add('========================================================================');
    Reporte.Add(lblPromedio.Caption);
    Reporte.Add(lblAprobados.Caption + ' | ' + lblDesaprobados.Caption);

    FileName := ExtractFilePath(ParamStr(0)) + 'reporte_calificaciones_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.txt';
    Reporte.SaveToFile(FileName);
    ShowMessage('Reporte legacy generado correctamente en:' + LineEnding + FileName);
  finally
    Reporte.Free;
  end;
end;

procedure TfrmNotas.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
