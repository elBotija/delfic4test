#!/usr/bin/env bash
#
# AIDLC-Light — Instalador de crewmates
# ---------------------------------------
# Materializa los 6 crewmates de AIDLC-Light en tu entorno Kiro Crew.
#
# MODELO DE IDENTIDAD (importante — causa de colisiones si se ignora):
#   Kiro Crew distingue dos cosas:
#     - TEMPLATE kiro (el .json en ~/.kiro/agents/): nombre GLOBAL a tu instalación.
#       Acá es por ROL y FIJO: aidlc-arquitecto, aidlc-builder-back, ... Un solo juego,
#       compartido por TODOS los proyectos. Contiene prompt (file://...md) + tools.
#     - CREW MEMBER (lo que ves en `agent list`): se crea con `agent create --name`.
#       Acá es por PROYECTO y ÚNICO: <slug>-aidlc-<rol>, apunta al template de rol vía
#       --kiro-agent aidlc-<rol>. Cada member tiene su memory store privado.
#   Varios proyectos comparten los 6 templates de rol y registran sus propios 6 members.
#   No se pre-escribe un .json por proyecto: eso colisiona con el template global.
#
# Flujo:
#   1. Autodetecta la raíz del repo (PROJECT_ROOT).
#   2. Te pide (o recibe por argumento / YAML) el nombre del proyecto → slug.
#   3. Asegura los 6 TEMPLATES de rol en ~/.kiro/agents/ (aidlc-<rol>.json) con path
#      ABSOLUTO al .md de este clon. Si ya existen, actualiza el path al de este clon.
#   4. Crea el workspace aidlc-light-<slug> si no existe.
#   5. Registra los 6 MEMBERS <slug>-aidlc-<rol> (create si son nuevos, update si ya
#      existían — idempotente), cada uno apuntando a su template de rol.
#   6. Verifica con `kirocrew agent list`.
#
# Uso:
#   ./install.sh                 # toma el nombre de project_params.yaml; si no hay, lo pregunta
#   ./install.sh mi-proyecto     # el argumento tiene prioridad sobre el YAML
#
set -euo pipefail

# --- 1. Autodetectar la raíz del repo (el dir donde vive este script) ---
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="${PROJECT_ROOT}/.kiro/agents"
KIRO_AGENTS_DIR="${HOME}/.kiro/agents"

echo "AIDLC-Light installer"
echo "  PROJECT_ROOT detectado: ${PROJECT_ROOT}"

# --- Prechequeos ---
if ! command -v kirocrew >/dev/null 2>&1; then
  echo "ERROR: no encuentro el CLI 'kirocrew' en el PATH. Instalá/activá Kiro Crew antes de correr este instalador." >&2
  exit 1
fi
if [[ ! -d "${AGENTS_SRC}" ]]; then
  echo "ERROR: no existe ${AGENTS_SRC}. ¿Estás corriendo el script desde el clon del repo AIDLC-Light?" >&2
  exit 1
fi

# --- 2. Nombre del proyecto: argumento > YAML > interactivo ---
PARAMS_FILE="${PROJECT_ROOT}/config/project_params.yaml"
PROJECT_NAME="${1:-}"

# Lee una clave escalar de un YAML plano: valor, sin comillas envolventes ni comentario inline.
yaml_get() {
  local key="$1" file="$2"
  sed -n "s/^[[:space:]]*${key}:[[:space:]]*//p" "${file}" | head -n1 \
    | sed 's/[[:space:]]*#.*$//; s/[[:space:]]*$//' \
    | sed 's/^"\(.*\)"$/\1/; s/^'\''\(.*\)'\''$/\1/'
}

if [[ -z "${PROJECT_NAME}" && -f "${PARAMS_FILE}" ]]; then
  YAML_NAME="$(yaml_get nombre_proyecto "${PARAMS_FILE}")"
  if [[ -n "${YAML_NAME}" ]]; then
    PROJECT_NAME="${YAML_NAME}"
    echo "  Nombre leído de project_params.yaml: ${PROJECT_NAME}"
  fi
fi

# Si sigue vacío, preguntar.
if [[ -z "${PROJECT_NAME}" ]]; then
  read -r -p "Nombre del proyecto (se usará en el workspace aidlc-light-<nombre>): " PROJECT_NAME
fi

# Normalizar a kebab-case seguro: minúsculas, espacios/underscores -> guión, solo [a-z0-9-]
PROJECT_SLUG="$(echo "${PROJECT_NAME}" \
  | tr '[:upper:]' '[:lower:]' \
  | tr ' _' '--' \
  | sed 's/[^a-z0-9-]//g; s/-\{2,\}/-/g; s/^-//; s/-$//')"

if [[ -z "${PROJECT_SLUG}" ]]; then
  echo "ERROR: el nombre del proyecto quedó vacío tras normalizar. Usá letras/números." >&2
  exit 1
fi

WORKSPACE="aidlc-light-${PROJECT_SLUG}"
echo "  Slug del proyecto:     ${PROJECT_SLUG}"
echo "  Workspace objetivo:    ${WORKSPACE}"
echo "  Templates de rol:      aidlc-<rol>  (globales, compartidos entre proyectos)"
echo "  Crew members:          ${PROJECT_SLUG}-aidlc-<rol>  (únicos de este proyecto)"
echo ""

# --- Los 6 roles: rol (sufijo del .md) + tools (CSV) ---
# tools = allowedTools en todos (sin gates extra; la seguridad de commits va en el prompt).
# El ROL define el nombre del prompt .md versionado: aidlc-<rol>.md
ROLES=(
  "arquitecto|fs_read,grep,glob,code"
  "builder-back|fs_read,fs_write,grep,glob,code"
  "builder-front|fs_read,fs_write,grep,glob,code"
  "inspector|fs_read,grep,glob"
  "auditor|fs_read,fs_write,grep,glob,code"
  "tech-writer|fs_read,fs_write,grep,glob"
)

# declare -A DESCRIPTIONS=(
#   [arquitecto]="AIDLC-Light: Arquitecto de Software — analiza legacy y genera Blueprint inmutable"
#   [builder-back]="AIDLC-Light: Builder Backend — escribe código backend según el Blueprint"
#   [builder-front]="AIDLC-Light: Builder Frontend — escribe componentes UI según el Blueprint"
#   [inspector]="AIDLC-Light: Inspector (LLM-as-a-Judge) — veredicto binario PASS/FAIL"
#   [auditor]="AIDLC-Light: Auditor de Seguridad — reporte ISO/OWASP del código generado"
#   [tech-writer]="AIDLC-Light: Tech Writer — genera CHANGELOG comparando legacy vs migración"
# )
get_description() {
  case "$1" in
    arquitecto)    echo "AIDLC-Light: Arquitecto de Software — analiza legacy y genera Blueprint inmutable" ;;
    builder-back)  echo "AIDLC-Light: Builder Backend — escribe código backend según el Blueprint" ;;
    builder-front) echo "AIDLC-Light: Builder Frontend — escribe componentes UI según el Blueprint" ;;
    inspector)     echo "AIDLC-Light: Inspector (LLM-as-a-Judge) — veredicto binario PASS/FAIL" ;;
    auditor)       echo "AIDLC-Light: Auditor de Seguridad — reporte ISO/OWASP del código generado" ;;
    tech-writer)   echo "AIDLC-Light: Tech Writer — genera CHANGELOG comparando legacy vs migración" ;;
    *) echo "AIDLC-Light: ${1}" ;;
  esac
}

# Convierte un CSV "a,b,c" en un array JSON ["a","b","c"]
csv_to_json_array() {
  local csv="$1" out="" item
  IFS=',' read -r -a items <<< "${csv}"
  for item in "${items[@]}"; do
    out="${out}\"${item}\","
  done
  echo "[${out%,}]"
}

mkdir -p "${KIRO_AGENTS_DIR}"

# --- 3. Asegurar los 6 TEMPLATES de rol (aidlc-<rol>.json) con path ABSOLUTO a este clon ---
# El template es por ROL y global: un solo juego compartido por todos los proyectos.
# Si ya existe, se reescribe para que el prompt apunte al .md de ESTE clon (último que instala gana).
echo "Asegurando templates de rol en ${KIRO_AGENTS_DIR} ..."
for entry in "${ROLES[@]}"; do
  role="${entry%%|*}"
  tools_csv="${entry##*|}"
  md_path="${AGENTS_SRC}/aidlc-${role}.md"          # prompt versionado, nombre fijo por rol
  template_name="aidlc-${role}"                     # template GLOBAL por rol

  if [[ ! -f "${md_path}" ]]; then
    echo "ERROR: falta el prompt ${md_path}" >&2
    exit 1
  fi

  tools_json="$(csv_to_json_array "${tools_csv}")"
  desc="$(get_description "${role}")"
  spec_path="${KIRO_AGENTS_DIR}/${template_name}.json"

  cat > "${spec_path}" <<EOF
{
  "name": "${template_name}",
  "description": "${desc}",
  "model": "auto",
  "tools": ${tools_json},
  "allowedTools": ${tools_json},
  "prompt": "file://${md_path}"
}
EOF
  echo "  + ${spec_path}"
done
echo ""

# --- 4. Crear workspace si no existe ---
echo "Asegurando workspace ${WORKSPACE} ..."
if kirocrew workspace list 2>/dev/null | grep -qw "${WORKSPACE}"; then
  echo "  workspace ${WORKSPACE} ya existe — lo reutilizo."
else
  kirocrew workspace create --name "${WORKSPACE}"
  echo "  workspace ${WORKSPACE} creado."
fi
echo ""

# --- 5. Registrar MEMBERS por proyecto (create-or-update, idempotente) ---
# Cada member <slug>-aidlc-<rol> apunta al template de rol (--kiro-agent aidlc-<rol>).
# Idempotencia robusta: intentamos create; si el member ya existe, caemos a update.
# No parseamos `agent list` (su formato es frágil): reaccionamos al resultado real del comando.
echo "Registrando crew members en el workspace ${WORKSPACE} ..."
for entry in "${ROLES[@]}"; do
  role="${entry%%|*}"
  member_name="${PROJECT_SLUG}-aidlc-${role}"       # crew member único por proyecto
  template_name="aidlc-${role}"                     # template de rol que referencia

  if create_out="$(kirocrew agent create \
        --name "${member_name}" \
        --kiro-agent "${template_name}" \
        --workspace "${WORKSPACE}" 2>&1)"; then
    echo "  + ${member_name} registrado (create)."
  elif echo "${create_out}" | grep -qiE "already|exists"; then
    echo "  ~ ${member_name} ya existía — reasigno workspace (update)."
    kirocrew agent update "${member_name}" --workspace "${WORKSPACE}"
  else
    echo "ERROR registrando ${member_name}:" >&2
    echo "${create_out}" >&2
    exit 1
  fi
done
echo ""

# --- 6. Verificación ---
echo "Verificación (kirocrew agent list):"
kirocrew agent list | grep -E "${PROJECT_SLUG}-aidlc-|MEMORY_STORE" || true
echo ""
echo "Listo. Los 6 crewmates (${PROJECT_SLUG}-aidlc-*) quedaron en el workspace ${WORKSPACE}."
echo "Recargá el dashboard de Kiro Crew para verlos seleccionables."
