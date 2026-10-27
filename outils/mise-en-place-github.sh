#!/usr/bin/env bash
# Crée le dépôt ssk-it/ssk-terrarium-cadrage sur GitHub, y pousse main, et pose ses réglages.
#
# Relançable : un dépôt déjà créé n'est pas recréé, un réglage déjà posé est
# reposé à l'identique. S'appuie sur la session `gh` déjà ouverte ; aucun
# secret n'est demandé ni affiché.
set -euo pipefail

DEPOT="ssk-it/ssk-terrarium-cadrage"
# Visibilité du dépôt : en attente de la décision de l'utilisateur (question
# ouverte du cadrage 2026-001). Un dépôt privé fait tourner ses workflows sur le
# runner auto-hébergé, un dépôt public sur ubuntu-latest : changer l'une change
# l'autre dans .github/workflows/.
VISIBILITE="${VISIBILITE:-private}"
RACINE="$(cd "$(dirname "$0")/.." && pwd)"

confirmer() {
  read -r -p "$1 [o/N] " reponse
  [[ "$reponse" == "o" || "$reponse" == "O" ]]
}

case "$VISIBILITE" in
  private|public) ;;
  *) echo "VISIBILITE vaut private ou public, pas « $VISIBILITE »." >&2; exit 1 ;;
esac

if gh repo view "$DEPOT" >/dev/null 2>&1; then
  echo "Le dépôt $DEPOT existe déjà."
else
  confirmer "Créer le dépôt $DEPOT ($VISIBILITE) et y pousser main ?" || exit 1
  gh repo create "$DEPOT" "--$VISIBILITE" \
    --description "ssk-terrarium — référentiel de cadrage SSK Canon : ce que le régulateur du terrarium doit faire, et pourquoi." \
    --source "$RACINE" --remote origin --push
fi

# Les branches fusionnées disparaissent d'elles-mêmes.
gh repo edit "$DEPOT" --delete-branch-on-merge
echo "delete_branch_on_merge : $(gh api "repos/$DEPOT" -q .delete_branch_on_merge)"

# main n'accepte que ce que les contrôles ont validé : un ensemble de règles
# (ruleset) exige leur succès, et refuse la suppression et la poussée forcée.
# Personne n'en est dispensé, administrateurs compris.
command -v jq >/dev/null || { echo "jq introuvable." >&2; exit 1; }
REGLES_NOM="Contrôles requis sur main"
CONTROLE="verifier"
# Pas de branche à jour exigée, comme sur ssk-canon : la propagation ouvre sa
# demande de fusion depuis le main du moment, et un cadrage fusionné entre-temps
# la bloquerait jusqu'à une mise à jour que personne ne fait.
A_JOUR=false
# 15368 : l'application GitHub Actions, seule à pouvoir rendre ce contrôle.
REGLES="$(jq -n --arg nom "$REGLES_NOM" --arg controle "$CONTROLE" --argjson a_jour "$A_JOUR" '{
  name: $nom, target: "branch", enforcement: "active", bypass_actors: [],
  conditions: { ref_name: { include: ["~DEFAULT_BRANCH"], exclude: [] } },
  rules: [
    { type: "deletion" },
    { type: "non_fast_forward" },
    { type: "required_status_checks", parameters: {
        do_not_enforce_on_create: false,
        strict_required_status_checks_policy: $a_jour,
        required_status_checks: [ { context: $controle, integration_id: 15368 } ] } }
  ] }')"
normaliser() { jq -S '{name, target, enforcement, bypass_actors, conditions, rules: (.rules | sort_by(.type))}'; }

ID="$(gh api "repos/$DEPOT/rulesets" --jq ".[] | select(.name == \"$REGLES_NOM\") | .id")"
if [[ -z "$ID" ]]; then
  if confirmer "Exiger « $CONTROLE » sur main de $DEPOT (branche à jour : $A_JOUR) ?"; then
    gh api -X POST "repos/$DEPOT/rulesets" --input - <<< "$REGLES" >/dev/null
  fi
elif [[ "$(gh api "repos/$DEPOT/rulesets/$ID" | normaliser)" == "$(normaliser <<< "$REGLES")" ]]; then
  echo "Règles « $REGLES_NOM » déjà en place."
elif confirmer "Les règles « $REGLES_NOM » de $DEPOT diffèrent : les remettre à l'identique ?"; then
  gh api -X PUT "repos/$DEPOT/rulesets/$ID" --input - <<< "$REGLES" >/dev/null
fi
echo "Contrôles requis sur main : $(gh api "repos/$DEPOT/rules/branches/main" \
  --jq '[.[] | select(.type == "required_status_checks") | .parameters.required_status_checks[].context] | join(", ")')"
echo "Réglages posés sur $DEPOT."
