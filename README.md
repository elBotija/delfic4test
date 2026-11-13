# KiroCrew AIDLC-Light (AI Development Life Cycle - Lean)

## 1. Origen y Motivación del Proyecto
El desarrollo de software asistido por Inteligencia Artificial ha madurado, pero las herramientas corporativas diseñadas para orquestar estos procesos (como los frameworks tradicionales de AIDLC) han heredado los peores vicios de la burocracia empresarial.

El origen de **KiroCrew AIDLC-Light** nace de una frustración directa con los frameworks de migración "Enterprise":
* **El "Impuesto" de la Interacción:** Tiempos de ejecución ridículos por "discoverys" infinitos.
* **Degradación de Contexto (Context Drift):** Los LLMs olvidan las reglas iniciales y rompen contratos si se les pide todo en un solo prompt.
* **Over-engineering:** Uso innecesario de bases vectoriales para contextos que entran perfectamente en la RAM.

**Nuestra premisa es simple:** El código generado por IA en entornos de producción no necesita más "conversaciones de descubrimiento", necesita **contratos rígidos, validación cruzada asíncrona y rigor documental**.

## 2. Objetivo
Proporcionar un marco de trabajo (framework) **determinista, ágil y auditable** para la migración y creación de software mediante agentes de IA. Reducir el tiempo de ejecución a minutos, minimizando el gasto de tokens y garantizando estándares de seguridad (ISO/OWASP) de forma automática.

## 3. Filosofía y Lógica Arquitectónica
1. **Convención sobre Configuración:** La IA no hace preguntas de diseño durante la ejecución; asume el stack y avanza.
2. **Chunking de Contexto:** Fragmentamos el sistema en micro-tareas aisladas inyectando solo el contexto estrictamente necesario.
3. **Pipeline de Único Sentido (Fail-Fast):** El flujo avanza hacia adelante. Si un agente comete un error, un Inspector lo intercepta y lo obliga a reintentar.

## 4. Mecanismos Implementados
* **Contratos Rígidos (Schema Estricto):** El diseño inicial (Blueprint) es un JSON inmutable validado por schema.
* **Patrón "LLM-as-a-Judge" (El Inspector):** Un modelo rápido evalúa de forma binaria (PASS/FAIL) cada fragmento de código generado antes de guardarlo.
* **Auditoría y Trazabilidad Nativas (ISO-Ready):** Agentes *SecOps* y *Tech Writers* que generan reportes de seguridad y Changelogs automáticamente.
* **Crewmates Nativos de Kiro Crew:** Cada rol del pipeline es un agente custom de Kiro Crew con su propio system prompt, tools y permisos.

## 5. Arquitectura basada en Kiro Crew

AIDLC-Light se ejecuta sobre la capa de orquestación de Kiro Crew. Cada rol es un crewmate (agente custom):

| Rol | Qué hace | Prompt (versionado) | Nombre registrado |
|-----|----------|---------------------|-------------------|
| arquitecto | Analiza legacy → genera Blueprint inmutable | `.kiro/agents/aidlc-arquitecto.md` | `<slug>-aidlc-arquitecto` |
| builder-back | Escribe código backend según Blueprint | `.kiro/agents/aidlc-builder-back.md` | `<slug>-aidlc-builder-back` |
| builder-front | Escribe componentes frontend según Blueprint | `.kiro/agents/aidlc-builder-front.md` | `<slug>-aidlc-builder-front` |
| inspector | Juez binario PASS/FAIL (LLM-as-a-Judge) | `.kiro/agents/aidlc-inspector.md` | `<slug>-aidlc-inspector` |
| auditor | Auditoría de seguridad ISO/OWASP | `.kiro/agents/aidlc-auditor.md` | `<slug>-aidlc-auditor` |
| tech-writer | Genera CHANGELOG comparando legacy vs migración | `.kiro/agents/aidlc-tech-writer.md` | `<slug>-aidlc-tech-writer` |

> El **prompt** de cada crewmate (`.md`) se versiona en el repo con nombre fijo por rol. El **spec** (`.json`) lo genera `install.sh` con los paths absolutos de tu clon y un **nombre único por proyecto** (`<slug>-aidlc-<rol>`, donde `<slug>` sale de `nombre_proyecto`), y lo registra en Kiro Crew — no se versiona (está en `.gitignore`). El nombre único evita que dos proyectos que usan la herramienta colisionen, porque el nombre de un template es global a tu instalación de Kiro. Instalación: `./install.sh <nombre-proyecto>` (ver [Manual de Uso](docs/MANUAL_DE_USO.md)).

La skill de orquestación (`.kiro/skills/aidlc-light/SKILL.md`) coordina las 3 fases:

### Fase 1: Discovery Rígido
El Arquitecto analiza el legacy y genera un Blueprint JSON con schema estricto. El Blueprint es el contrato inmutable que guía todo el resto del pipeline.

### Fase 2: Construcción Dinámica con Juez (Fail-Fast)
Por cada módulo del Blueprint:
1. El Builder correspondiente (frontend o backend) genera el código.
2. El Inspector evalúa el código contra el contrato → PASS o FAIL.
3. Si FAIL, el Builder reintenta (máximo 3 veces).
4. Si PASS, el código se guarda en `output/codigo/{capa}/`.

### Fase 3: Auditoría ISO y Changelog
El Auditor y el Tech Writer corren en paralelo:
- Auditor: revisa el código real generado y produce `output/02_security_iso_audit.md`.
- Tech Writer: compara legacy con migración y produce `output/CHANGELOG.md`.

## 6. Uso y Parametrización (Stack Agnostic)
KiroCrew AIDLC-Light no está atado a ningún lenguaje. Todo se inyecta por configuración en `config/project_params.yaml`.

### Ejecución del pipeline
Simplemente dile a Kiro: "Ejecuta el pipeline AIDLC-Light" o "Migra el código legacy".

La skill `aidlc-light` se activa automáticamente y orquesta los crewmates.

### Modelo de uso: herramienta aparte del proyecto
AIDLC-Light es una **herramienta** que clonás una vez y reutilizás en muchos proyectos. Tu proyecto vive en su propia carpeta y su propio repo; el pipeline lee de `<project_dir>/input/` y escribe en `<project_dir>/output/` (configurás `project_dir` en `config/project_params.yaml`). Así actualizás la metodología con `git pull` sin mezclarla con tu código generado.

## 7. Roadmap

- **v1 (actual):** generación greenfield — migración de sistemas o creación de features/módulos nuevos escritos de cero.
- **v2 (planificado):** *AIDLC-Light Mantenimiento* — evolucionar un repo activo (features y tasks que **modifican** código existente in-situ), con un instalador y una skill de mantenimiento propios que configuran a los mates para operar a partir del repo existente. Detalle en el [Manual de Uso](docs/MANUAL_DE_USO.md#roadmap--v2-aidlc-light-mantenimiento-features-y-tasks-in-situ).

---
**📖 Para instrucciones de instalación y ejecución, lee el [Manual de Uso](docs/MANUAL_DE_USO.md).**
