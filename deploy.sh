#!/usr/bin/env bash

# ==============================
#  Script de déploiement Terraform
#  Modes : apply (défaut), plan, destroy
# ==============================

set -euo pipefail

########################
#  Couleurs & helpers  #
########################

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
BOLD="\033[1m"
NC="\033[0m" # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }

usage() {
  cat <<EOF
${BOLD}Usage:${NC} $0 [mode] [options]

Modes :
  apply     (défaut)  - terraform init, plan, puis apply
  plan                - terraform init, puis plan uniquement
  destroy             - terraform init, ensuite terraform destroy

Options :
  -y, --yes           - ne pas demander de confirmation pour apply/destroy
  -h, --help          - afficher cette aide

Exemples :
  $0
  $0 apply -y
  $0 plan
  $0 destroy -y
EOF
}

##################
#  Parse args    #
##################

MODE="apply"
AUTO_APPROVE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    apply|plan|destroy)
      MODE="$1"
      shift
      ;;
    -y|--yes)
      AUTO_APPROVE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Argument inconnu : $1"
      usage
      exit 1
      ;;
  esac
done

########################
#  Fonctions Terraform #
########################

run_init() {
  log_info "Exécution de: terraform init"
  terraform init
  log_ok "terraform init terminé avec succès"
}

run_plan() {
  log_info "Exécution de: terraform plan"
  terraform plan -out=tfplan
  log_ok "terraform plan terminé avec succès (plan enregistré dans tfplan)"
}

run_apply() {
  if [[ "$AUTO_APPROVE" == "true" ]]; then
    log_warn "Apply sans confirmation (mode auto-approve)"
    terraform apply -auto-approve tfplan
  else
    echo
    read -r -p "➡️  Confirmer l'application du plan ? [y/N] " answer
    case "$answer" in
      [Yy]*)
        terraform apply tfplan
        ;;
      *)
        log_warn "Apply annulé par l'utilisateur."
        return
        ;;
    esac
  fi
  log_ok "terraform apply terminé avec succès"
}

run_destroy() {
  if [[ "$AUTO_APPROVE" == "true" ]]; then
    log_warn "Destroy sans confirmation (mode auto-approve)"
    terraform destroy -auto-approve
  else
    echo
    read -r -p "⚠️  Confirmer la destruction de l'infra ? [y/N] " answer
    case "$answer" in
      [Yy]*)
        terraform destroy
        ;;
      *)
        log_warn "Destroy annulé par l'utilisateur."
        return
        ;;
    esac
  fi
  log_ok "terraform destroy terminé avec succès"
}

########################
#  Main                #
########################

echo -e "${BOLD}=============================="
echo -e "   🚀 Déploiement Terraform   "
echo -e "   Mode : ${MODE}"
echo -e "==============================${NC}"
echo

run_init   # ⛔ arrête le script automatiquement en cas d'erreur

case "$MODE" in
  plan)
    run_plan
    ;;
  apply)
    run_plan   # ⛔ si plan échoue, le script s'arrête
    run_apply
    ;;
  destroy)
    # pas de plan ici, destroy calcule son propre plan
    run_destroy
    ;;
esac

echo
log_ok "Script terminé."
