-- =====================================================================
-- Queries Legacy Empleadas en Pantallas Delphi (Referencia)
-- =====================================================================

-- Pantalla 1: Listado y filtro de Alumnos
SELECT a.id, a.legajo, a.apellido, a.nombre, a.dni, a.email, a.telefono, 
       c.nombre AS curso, a.estado, a.fecha_alta
FROM alumnos a
INNER JOIN cursos c ON a.curso_id = c.id
WHERE a.apellido LIKE '%González%'
ORDER BY a.apellido, a.nombre;

-- Pantalla 1: Guardar nuevo Alumno (Legacy Direct SQL)
INSERT INTO alumnos (legajo, apellido, nombre, dni, fecha_nacimiento, email, telefono, curso_id, estado, fecha_alta)
VALUES ('LEG-2024-011', 'Benítez', 'Franco', '45999888', '2008-05-10', 'fbenitez@escuela.edu.ar', '11-1111-2222', 1, 'REGULAR', CURDATE());

-- Pantalla 2: Carga de Alumnos para Asistencia en fecha seleccionada
SELECT a.id AS alumno_id, a.legajo, CONCAT(a.apellido, ', ', a.nombre) AS estudiante,
       COALESCE(asi.estado, 'PRESENTE') AS estado,
       COALESCE(asi.observacion, '') AS observacion
FROM alumnos a
LEFT JOIN asistencias asi ON asi.alumno_id = a.id 
     AND asi.materia_id = 1 
     AND asi.fecha = '2024-04-15'
WHERE a.curso_id = 1 AND a.estado = 'REGULAR'
ORDER BY a.apellido, a.nombre;

-- Pantalla 2: Upsert Asistencia
INSERT INTO asistencias (alumno_id, materia_id, fecha, estado, observacion)
VALUES (1, 1, '2024-04-15', 'PRESENTE', 'Llegada a horario')
ON DUPLICATE KEY UPDATE estado = VALUES(estado), observacion = VALUES(observacion);

-- Pantalla 3: Carga de Calificaciones por Curso, Materia y Periodo
SELECT a.id AS alumno_id, a.legajo, CONCAT(a.apellido, ', ', a.nombre) AS estudiante,
       c.nota, c.observacion,
       CASE 
         WHEN c.nota IS NULL THEN 'PENDIENTE'
         WHEN c.nota >= 6.00 THEN 'APROBADO'
         ELSE 'DESAPROBADO'
       END AS condicion
FROM alumnos a
LEFT JOIN calificaciones c ON c.alumno_id = a.id 
     AND c.materia_id = 1 
     AND c.periodo = '1er Trimestre'
WHERE a.curso_id = 1 AND a.estado = 'REGULAR'
ORDER BY a.apellido, a.nombre;

-- Pantalla 3: Reporte de Promedios por Alumno (Legacy Batch Report)
SELECT a.legajo, CONCAT(a.apellido, ', ', a.nombre) AS alumno,
       COUNT(c.id) AS materias_evaluadas,
       ROUND(AVG(c.nota), 2) AS promedio_general,
       SUM(CASE WHEN c.nota >= 6.0 THEN 1 ELSE 0 END) AS materias_aprobadas,
       SUM(CASE WHEN c.nota < 6.0 THEN 1 ELSE 0 END) AS materias_desaprobadas
FROM alumnos a
LEFT JOIN calificaciones c ON c.alumno_id = a.id
WHERE a.curso_id = 1
GROUP BY a.id, a.legajo, a.apellido, a.nombre;
