# Guía de Migración de Delphi Legacy a Stack Moderno

Esta guía describe cómo utilizar este repositorio como banco de pruebas (benchmark) para evaluar herramientas de migración asistidas por IA (AIDLC), refactorizaciones manuales o frameworks modernos.

---

## 1. Objetivos del Ejercicio de Migración

1. **Desacoplar la UI de la Base de Datos:**
   Eliminar el acceso directo a MariaDB desde el cliente de escritorio y crear una capa de Backend / API RESTful.
2. **Centralizar la Lógica de Negocio:**
   Extraer las reglas de cálculo de promedios, validaciones de legajo/DNI y estados académicos fuera de los eventos de GUI (`OnClick`, `OnEditingDone`).
3. **Modernizar la Persistencia:**
   Migrar el esquema SQL con herramientas de migración declarativas (Prisma, Flyway, Alembic o Liquibase) e implementar transacciones atómicas.
4. **Construir una Interfaz Web / Móvil Moderna:**
   Reemplazar las 3 pantallas de Delphi por una Single Page Application (SPA) o Server-Side Rendered (SSR) con diseño responsivo.

---

## 2. Mapeo de Componentes Legacy a Modernos

### Pantalla 1 (Gestión de Alumnos)
- **Legacy:** `UMain.pas` con `TDBGrid`, `TEdit`, `TButton` y SQL dinámico.
- **Backend Moderno:**
  - `GET /api/v1/students?search=...&course_id=...`
  - `POST /api/v1/students`
  - `PUT /api/v1/students/{id}`
  - `DELETE /api/v1/students/{id}`
- **Frontend Moderno:** Componente React/Vue/Svelte con tabla con paginación, modal de alta/edición y debounce en el campo de búsqueda.

### Pantalla 2 (Toma de Asistencia)
- **Legacy:** `UAsistencia.pas` con `TStringGrid` y doble clic para alternar estados.
- **Backend Moderno:**
  - `GET /api/v1/attendance?course_id=...&subject_id=...&date=...`
  - `POST /api/v1/attendance/bulk` (recibe un array de `{ student_id, status, notes }` y ejecuta un bulk upsert en una única transacción).
- **Frontend Moderno:** Grid responsivo con botones de estado tipo badge (`Presente`, `Ausente`, `Tarde`, `Justificado`), botón "Marcar Todos Presentes" y métricas visuales instantáneas.

### Pantalla 3 (Carga de Calificaciones)
- **Legacy:** `UNotas.pas` con cálculo de promedios en bucle cliente y exportación a `.txt`.
- **Backend Moderno:**
  - `GET /api/v1/grades?course_id=...&subject_id=...&period=...`
  - `POST /api/v1/grades/bulk`
  - `GET /api/v1/grades/report/pdf` o `csv` (generación server-side de boletines).
- **Frontend Moderno:** Data grid editable con validación inmediata en cliente y servidor, indicadores de estado académico y gráficos de rendimiento escolar (Chart.js / Recharts).

---

## 3. Ejemplo de Arquitectura Destino Sugerida

```
+-------------------------------------------------------------+
|                MODERN WEB FRONTEND (React / Next.js)         |
|  - AlumnosPage.tsx                                          |
|  - AsistenciaPage.tsx                                       |
|  - CalificacionesPage.tsx                                   |
+------------------------------+------------------------------+
                               | HTTPS / JSON
+------------------------------v------------------------------+
|            BACKEND API (FastAPI / Node.js / NestJS)          |
|  - AlumnosService & Controller                              |
|  - AsistenciaService & Controller                           |
|  - CalificacionesService & Controller                       |
+------------------------------+------------------------------+
                               | ORM (SQLAlchemy / Prisma)
+------------------------------v------------------------------+
|             BASE DE DATOS (MariaDB / PostgreSQL)            |
|  - Tablas normalizadas con migraciones versionadas          |
+-------------------------------------------------------------+
```

---

## 4. Estrategia de Verificación de Paridad

Para asegurar que la migración no introduzca regresiones funcionales:
1. **Verificación de Datos Semilla:** Ejecutar las consultas de `database/queries_legacy.sql` sobre la base de datos moderna y comparar los resultados con los que arrojaba la aplicación Delphi.
2. **Prueba de Caso Extremo (Edge Case):**
   - Inserción de notas decimales con coma o punto (`7,50` vs `7.50`).
   - Actualización de asistencia para el mismo alumno en la misma fecha (debe actualizar, no duplicar fila).
   - Cálculo del estado: nota `5.99` debe resultar en `DESAPROBADO`, nota `6.00` en `APROBADO`.
