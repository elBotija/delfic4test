# 📖 Manual de Uso e Inicialización - KiroCrew AIDLC-Light

Este manual te guía paso a paso para configurar y ejecutar una migración asistida por IA usando el framework AIDLC-Light sobre Kiro Crew.

## Arquitectura del Framework

AIDLC-Light funciona sobre Kiro Crew usando dos piezas:

1. **6 Agentes Custom (Crewmates)**: su **prompt** (`.md`) vive versionado en `.kiro/agents/` dentro del repo. El **spec** (`.json`) NO se versiona: lo genera `install.sh` con los paths absolutos de tu clon y lo registra en Kiro Crew.
2. **1 Skill de Orquestación**: en `.kiro/skills/aidlc-light/SKILL.md` — coordina las 3 fases del pipeline usando `spawn_run`.

## Prerrequisitos

Antes de instalar necesitás:

1. **Kiro Crew funcionando** y el CLI `kirocrew` disponible en tu PATH. Verificá con:
   ```bash
   kirocrew --version
   ```
   Si el comando no existe, instalá/activá Kiro Crew primero. `install.sh` aborta con un mensaje claro si no encuentra el CLI.
2. **Bash** (Linux, macOS o WSL en Windows). El instalador es un script `bash`.
3. **Permiso para escribir en `~/.kiro/agents/`** desde tu terminal. El registro de crewmates lo corrés **vos**, no un agente: escribir ahí y correr `kirocrew agent create/update` está reservado a tu usuario, no al proceso de un agente.

## Paso 0: Clonar la herramienta (una sola vez)

AIDLC-Light es una **herramienta** que instalás una vez y reutilizás en muchos proyectos (modelo A). Clonala en un lugar fijo, separada de tus proyectos:

```bash
git clone <url-de-AIDLC-Light> ~/tools/AIDLC-Light
cd ~/tools/AIDLC-Light
```

Para actualizar la metodología más adelante: `git pull` dentro de esa carpeta. Como tu código generado vive en otra carpeta (`project_dir`), el pull nunca choca con tu trabajo.

## Paso 1: Instalar los Agentes en Kiro Crew

El repo trae un instalador que genera los specs `.json` con los paths absolutos de **tu** clon, crea un workspace propio para tu proyecto y registra los 6 crewmates. Corré desde la raíz del repo:

```bash
./install.sh                 # toma el nombre de config/project_params.yaml; si no hay, lo pregunta
# o bien:
./install.sh mi-proyecto     # el argumento tiene prioridad sobre el YAML
```

El nombre del proyecto se resuelve con esta precedencia: **argumento > `nombre_proyecto` en `config/project_params.yaml` > pregunta interactiva**. Define el workspace `aidlc-light-<nombre>`, donde quedan los 6 mates (comparten knowledge base y notas entre ellos; la memoria privada de cada uno NO se comparte). El script es **idempotente**: si ya instalaste antes, reasigna el workspace con `agent update` en vez de fallar.

> El registro escribe en `~/.kiro/agents/` y corre `kirocrew agent create/update`. Por eso lo ejecutás **vos** desde tu terminal: corre con tus permisos, no con los de un agente.

Luego verifica que aparecen:

1. Recargá el dashboard de Kiro Crew.
2. Debes ver los 6 crewmates seleccionables, nombrados `<slug>-aidlc-<rol>` (donde `<slug>` es tu `nombre_proyecto` normalizado). Por ejemplo, con `nombre_proyecto: "mi-proyecto"`:
   - `mi-proyecto-aidlc-arquitecto`
   - `mi-proyecto-aidlc-builder-back`
   - `mi-proyecto-aidlc-builder-front`
   - `mi-proyecto-aidlc-inspector`
   - `mi-proyecto-aidlc-auditor`
   - `mi-proyecto-aidlc-tech-writer`

   El nombre lleva el slug del proyecto porque el nombre de un template es global a tu instalación de Kiro: así dos proyectos que usan AIDLC-Light no colisionan.

Si preferís verificar por CLI: `kirocrew agent list` debe mostrarlos con su `MEMORY_STORE` propio (`member-...`) y el workspace `aidlc-light-<nombre>`.

## Paso 2: Parametrizar tu Proyecto

Aquí defines **qué** vas a migrar y **hacia dónde**. No toques código, todo se maneja desde configuración.

1. Abre `config/project_params.yaml`.
2. Define los 3 pilares de tu migración:
   - `stack_origen`: Describe qué estás migrando (ej. PHP legacy).
   - `stack_destino`: Sé específico (ej. API en Node.js Express, Frontend en React 18, PostgreSQL).
   - `reglas_seguridad`: Reglas de tu empresa u normativas ISO que los agentes deben cumplir.
3. Define `project_dir`: la ruta absoluta a la carpeta de **tu** proyecto (ver recuadro abajo).
4. Opcional: ajusta los `modelos` por agente si quieres usar modelos diferentes (por defecto `auto`).
5. Opcional: ajusta `pipeline.max_reintentos` (default 3) y `pipeline.paralelismo` (default true).

> **La herramienta vive aparte de tu proyecto (modelo A).** Clonás AIDLC-Light una vez en un lugar fijo (ej. `~/tools/AIDLC-Light`) y la usás sobre muchos proyectos. Tu proyecto vive en SU propia carpeta y su propio repo (ej. `~/dev/reservas-turnos`). El pipeline lee de `<project_dir>/input/` y escribe en `<project_dir>/output/`, nunca dentro de la herramienta. Así podés `git pull` nuevas versiones de la metodología sin chocar con tu código generado, y tu proyecto no arrastra el historial de git de la herramienta.
>
> Si dejás `project_dir` vacío, el pipeline cae a `input_legacy/` y `output/` dentro del propio repo de la herramienta. Ese modo autocontenido es solo para **probar** AIDLC-Light, no para trabajo real.

## Paso 3: Cargar el Input

1. En la carpeta de tu proyecto, creá `<project_dir>/input/` (o `input_legacy/` dentro de la herramienta si estás en modo autocontenido de prueba).
2. Colocá ahí el código real, contratos, o historias de usuario que querés que el Arquitecto analice.

## Paso 4: Ejecución del Pipeline

Simplemente dile a Kiro en el dashboard:

> "Ejecuta el pipeline AIDLC-Light" o "Migra el código legacy"

La skill `aidlc-light` se activa automáticamente y Kiro orquesta los crewmates:

> En todo lo que sigue, `output/` significa `<project_dir>/output/` si definiste `project_dir`, o `output/` dentro de la herramienta en modo autocontenido de prueba.

### ¿Qué verás en la consola?

1. **Fase 1:** Kiro lanza al `aidlc-arquitecto` como subagente. Analiza el input y devuelve un Blueprint JSON. Se guarda en `output/blueprint.json`.

2. **Fase 2:** Kiro itera sobre cada módulo del Blueprint. Por cada módulo:
   - Lanza al Builder correspondiente (back o front) como subagente.
   - Lanza al `aidlc-inspector` para validar el código.
   - Si PASS: guarda el archivo en `output/codigo/{capa}/`.
   - Si FAIL: el Builder reintenta con el feedback del Inspector (hasta 3 veces).

3. **Fase 3:** Kiro lanza en paralelo al `aidlc-auditor` y `aidlc-tech-writer`:
   - Auditor: genera `output/02_security_iso_audit.md`.
   - Tech Writer: genera `output/CHANGELOG.md`.

## Paso 5: Resultados

Cuando el pipeline termina, ve a la carpeta `output/` de tu proyecto:

```
output/
├── blueprint.json              # Contrato inmutable generado en Fase 1
├── codigo/
│   ├── backend/                # Código backend generado
│   ├── frontend/               # Componentes frontend generados
│   └── db/
│       └── init_schema.sql     # Script de inicialización de DB
├── 02_security_iso_audit.md    # Reporte de auditoría ISO/OWASP
└── CHANGELOG.md                # Changelog de la migración
```

Si algún módulo falló 3 veces, su archivo tendrá prefijo `REVIEW_` — revíselo manualmente.

## Personalización Avanzada

### Cambiar el modelo del Inspector

Edita `config/project_params.yaml`:
```yaml
modelos:
  inspector: "gpt-4o-mini"  # Modelo rápido y barato para el juez
```

### Desactivar paralelismo

```yaml
pipeline:
  paralelismo: false
```

### Mapear skills adicionales a un agente

Desde el dashboard: **Agent Capabilities → Agent Templates → selecciona el agente → Skills**.

## Troubleshooting

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `kirocrew: command not found` al correr `install.sh` | El CLI de Kiro Crew no está instalado o no está en el PATH | Instalá/activá Kiro Crew y volvé a abrir la terminal. Verificá con `kirocrew --version`. |
| `a template is already named '<slug>-aidlc-...'` o `give this crew another name` | Ya existe un template con ESE mismo nombre de una corrida previa del MISMO proyecto (el nombre de template es global a tu instalación de Kiro) | `install.sh` ahora es idempotente: detecta el nombre existente y hace `agent update` en vez de `create`. Volvé a correr el script. Si el nombre quedó registrado a medias por una corrida vieja con el naming anterior (`aidlc-<rol>` sin slug), eliminá ese template viejo con `kirocrew agent remove aidlc-<rol>` y reinstalá. |
| `agent ... already exists` | Ya habías instalado los mates de este proyecto antes | No es un error real: `install.sh` es idempotente y reasigna el workspace con `agent update`. Corré el script de nuevo. |
| Los mates no aparecen en el dashboard | Falta recargar, o el registro no corrió | Recargá el dashboard. Verificá por CLI con `kirocrew agent list`: deben estar los 6 `<slug>-aidlc-<rol>` con su `MEMORY_STORE` (`member-...`) y el workspace `aidlc-light-<slug>`. |
| Permiso denegado al escribir en `~/.kiro/agents/` | Estás corriendo el registro desde un proceso de agente, no desde tu terminal | El registro lo corrés **vos** en tu terminal (WSL/Linux/macOS). Escribir en `~/.kiro/agents/` está reservado a tu usuario. |
| El pipeline escribe dentro de la herramienta en vez de en mi proyecto | `project_dir` quedó vacío | Definí `project_dir` en `config/project_params.yaml` con la ruta absoluta a tu proyecto. Vacío = modo autocontenido de prueba. |
| Un módulo quedó con prefijo `REVIEW_` | Falló la validación del Inspector 3 veces | Revisá ese archivo a mano. El pipeline sigue de largo (fail-fast de único sentido). |

¡Listo! Ya tienes una migración rigurosa hecha en minutos.

---

## Roadmap — v2: AIDLC-Light Mantenimiento (features y tasks in-situ)

> **Estado: planificado, NO implementado en esta versión.**

La versión actual está diseñada para **generación greenfield**: migrar un sistema entero o crear módulos/features nuevos que se escriben de cero en `output/`. Los builders generan archivos nuevos; no editan código existente.

La **v2 de mantenimiento** apunta a lo que falta: **evolucionar un repo activo** — implementar una feature o una task que *modifica* código que ya vive en el proyecto, no que lo genera desde cero. Esto va a tener su propio `install` de mantenimiento, que configura a los mismos mates (o variantes) para operar **a partir del repo existente** en vez de un `input/` aislado.

Lo que la v2 tendrá que resolver (y por qué no entra hoy):

- **Input = el repo vivo, no un `input/` curado.** El Arquitecto releva el código existente relevante al cambio, no un dump de legacy.
- **Builders que editan in-situ.** Deben leer y modificar archivos existentes (agregar un endpoint, extender un modelo), no escribir en un `output/` limpio. Es el cambio de fondo del motor.
- **Inspector que valida diffs**, no archivos nuevos: ¿el cambio cumple la task sin romper lo que ya andaba?
- **Modo explícito** (`modo: feature | task` en el YAML) que cambia qué se le pide al Arquitecto y qué contexto reciben los mates.

La idea es reutilizar el mismo núcleo conceptual (contrato rígido + juez binario + fail-fast) aplicándolo sobre un repo existente, con un instalador y una skill de mantenimiento separados de los de migración.
