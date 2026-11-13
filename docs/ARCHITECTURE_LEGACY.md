# Arquitectura del Sistema Legacy (Delphi + MariaDB)

Este documento detalla la arquitectura original del sistema de gestión escolar, sus componentes, flujos de datos y los antipatrones técnicos presentes intencionalmente como objetivo de análisis y refactorización en pruebas de migración.

---

## 1. Modelo de Arquitectura

El sistema responde a una arquitectura **Client-Server clásica de 2 capas (Two-Tier Monolith)**:
- **Capa de Presentación y Lógica (Fat Client):** Ejecutable compilado en Object Pascal (Delphi / Free Pascal Lazarus). Toda la validación, lógica de negocio, cálculos de promedios y formateo residen directamente en los eventos de los formularios de escritorio.
- **Capa de Persistencia:** MariaDB / MySQL 5.7+ accesible directamente desde el cliente mediante el driver SQLdb / MySQL Connector.

```
+-------------------------------------------------------------+
|                     CLIENTE DELPHI (FAT CLIENT)              |
|                                                             |
|   +-------------------+  +-------------------------------+  |
|   | UMain (Pantalla 1)|  | UAsistencia (Pantalla 2)      |  |
|   | CRUD Alumnos      |  | Toma de Asistencias Diarias   |  |
|   +---------+---------+  +---------------+---------------+  |
|             |                            |                  |
|             +-------------+--------------+                  |
|                           |                                 |
|                  +--------+------------------+              |
|                  | UNotas (Pantalla 3)       |              |
|                  | Calificaciones & Promedios|              |
|                  +--------+------------------+              |
|                           |                                 |
|                  +--------v------------------+              |
|                  | UDataModule               |              |
|                  | TMySQL57Connection / SQL  |              |
|                  +--------+------------------+              |
+---------------------------|---------------------------------+
                            | TCP 3306 (SQL Directo)
                            v
               +--------------------------+
               |  MariaDB (colegio_legacy)|
               +--------------------------+
```

---

## 2. Inventario de Pantallas y Funcionalidades

### Pantalla 1: Gestión de Alumnos (`UMain.pas`, `UMain.lfm` / `.dfm`)
- **Propósito:** Registro maestro de alumnos, visualización en grilla interactiva y búsqueda por filtros.
- **Controles Clave:**
  - `dbgAlumnos` (`TDBGrid`): Grilla conectada a `dsAlumnos`.
  - `txtBuscar` + `btnBuscar`: Filtro dinámico por apellido o DNI.
  - Formulario de edición inferior: Legajo, Apellido, Nombre, DNI, Email, Teléfono, Curso y Estado.
  - Botones de acción: `btnNuevo`, `btnGuardar`, `btnEliminar`, `btnCancelar`.
- **Navegación:** Botones en barra superior y menú para abrir Pantalla 2 y Pantalla 3.

### Pantalla 2: Toma de Asistencia Diaria (`UAsistencia.pas`, `UAsistencia.lfm` / `.dfm`)
- **Propósito:** Registro masivo de presentismo por fecha, curso y materia.
- **Controles Clave:**
  - Filtros: Selector de fecha (`edtFecha`), curso (`cmbCurso`) y materia (`cmbMateria`).
  - Grilla interactiva (`TStringGrid` `sgAsistencia`): Lista los alumnos regulares del curso.
  - Acción rápida: Doble clic en celda para rotar estado (`PRESENTE` -> `AUSENTE` -> `TARDE` -> `JUSTIFICADO`).
  - Botón `btnTodosPresentes`: Asigna "PRESENTE" a toda la lista con un solo clic.
  - Botón `btnGuardar`: Itera todas las filas y ejecuta consultas SQL individuales tipo `INSERT ... ON DUPLICATE KEY UPDATE`.
  - Barra de resumen: Contador en tiempo real de alumnos presentes, ausentes y tardes.

### Pantalla 3: Carga de Calificaciones y Boletín (`UNotas.pas`, `UNotas.lfm` / `.dfm`)
- **Propósito:** Carga de notas trimestrales o de exámenes finales, cálculo de promedios y emisión de boletín.
- **Controles Clave:**
  - Filtros: Curso, Materia y Periodo lectivo (1er Trimestre, 2do Trimestre, 3er Trimestre, Final Diciembre, Final Febrero).
  - Grilla `sgNotas` (`TStringGrid`): Edición directa de la columna de calificación (escala 1.00 a 10.00).
  - Lógica en evento `sgNotasEditingDone`: Evalúa automáticamente la nota ingresada y asigna `APROBADO` (>= 6.00) o `DESAPROBADO` (< 6.00).
  - Panel estadístico: Calcula promedio general del grupo, cantidad y porcentaje de aprobados/desaprobados.
  - Botón `btnExportarReporte`: Emula la salida de reportes legacy generando un archivo de texto formateado en disco.

---

## 3. Catálogo de Antipatrones Legacy (Objetivos de Migración)

| Antipatrón | Ubicación en Código | Riesgo / Problema | Solución Moderna Recomendada |
|---|---|---|---|
| **SQL Concatenation** | `UMain.pas:btnGuardarClick`, `UAsistencia.pas:btnGuardarClick` | Riesgo crítico de SQL Injection, falta de escaping adecuado. | Consultas parametrizadas, ORM (Prisma, TypeORM, SQLAlchemy) o Prepared Statements. |
| **Business Logic en UI** | `UNotas.pas:RecalcularFila`, `UNotas.pas:btnCalcularClick` | La regla de aprobación (>= 6.00) y el cálculo de promedio están codificados en la interfaz gráfica. | Mover la lógica a una capa de servicios de backend / dominio (Domain Services). |
| **Batch Loops N+1 en Cliente** | `UAsistencia.pas:btnGuardarClick`, `UNotas.pas:btnGuardarNotasClick` | Se ejecutan N sentencias SQL individuales dentro de un bucle `for` sobre una grilla. | Batch insert en una sola transacción o endpoint `POST /api/attendance/bulk`. |
| **Credenciales en INI / Cliente** | `UDataModule.pas:CargarConfiguracion`, `config.ini` | Las credenciales de la base de datos están expuestas al binario cliente. | API Gateway / Backend intermedio con variables de entorno seguras (Secrets Manager / `.env`). |
| **Falta de API REST / GraphQL** | Todo el sistema | No existe desacoplamiento entre cliente y base de datos; imposible consumir desde web o móvil sin reescribir. | Creación de API RESTful o GraphQL en Node.js, Python, Go o Java. |
