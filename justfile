set windows-shell := ["pwsh", "-NoLogo", "-NoProfile", "-Command"]

# Godot binary: devenv sets GODOT; without Nix, ggg runs the pinned engine.
godot := env("GODOT", "ggg run")

# List recipes
default:
    @just --list

# Import the project headless (class cache)
[working-directory("godot")]
import:
    {{ godot }} --headless --editor --quit-after 300

# Open the Godot editor detached from the shell (log in the repo-root reports/editor.log)
[unix]
[working-directory("godot")]
edit:
    mkdir -p ../reports && nohup {{ godot }} --editor --path . > ../reports/editor.log 2>&1 &

# GDScript tests (GdUnit4), headless. Extra args go to Godot.
# Reports go to the repo-root reports/, outside res://.
[working-directory("godot")]
test-gd *ARGS="--headless --ignoreHeadlessMode": import
    bash addons/gdUnit4/runtest.sh --godot_binary "$GODOT" -a res://test -c -rd ../reports {{ ARGS }}

# Format all code
fmt:
    -gdscript-formatter $(git ls-files '*.gd' ':!godot/addons')

# Run all pre-commit hooks on every file
lint:
    prek run --all-files

# All tests: GDScript + engine tests
test: test-gd

# Everything CI runs
check: lint test

# Apply repo ruleset and merge settings (needs a GitHub remote and gh auth)
gh-setup:
    gh api --method POST "repos/{owner}/{repo}/rulesets" --input .github/rulesets/main.json
    gh api --method PATCH "repos/{owner}/{repo}" -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false -F delete_branch_on_merge=true -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

# Export a preset (Linux | Windows | macOS) to the repo-root build/<preset>/ (outside res://)
[unix]
[working-directory("godot")]
export preset: import
    mkdir -p ../build/{{ preset }}
    {{ godot }} --headless --export-release "{{ preset }}"

[windows]
[working-directory("godot")]
export preset: import
    New-Item -ItemType Directory -Force ../build/{{ preset }} | Out-Null; {{ godot }} --headless --export-release "{{ preset }}"

# One-shot setup right after "Use this template" + clone: LFS and labels. Safe to re-run. Never pushes.
[unix]
init:
    #!/usr/bin/env bash
    set -euo pipefail
    gh auth status >/dev/null 2>&1 || { echo "gh is not logged in: run 'gh auth login' first" >&2; exit 1; }
    git remote get-url origin >/dev/null 2>&1 || { echo "no 'origin' remote: create the repo from the template and clone it first" >&2; exit 1; }

    if grep -q '^# lfs-template:start' .gitattributes; then
        just lfs-adopt
        # The setup commit lands on main before the ruleset and feature-branch flow exist.
        SKIP=no-commit-to-branch git commit -m "build: move Kenney assets into Git LFS"
    else
        echo "Kenney assets already in LFS, skipping"
    fi

    # Labels dependabot applies (dependabot.yml `labels: [a, b]` lines)
    grep -h 'labels:' .github/dependabot.yml | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n' | tr -d ' ' | sort -u \
        | while read -r label; do gh label create "$label" --force; done

    cat <<'EOF'

    Done. Next steps, in order:
      1. git push (puts the setup commit on main)
      2. just gh-setup (ruleset and merge settings; run once, after the push)
      3. Create the GitHub App and set APP_CLIENT_ID / APP_PRIVATE_KEY (README, Releasing, step 2)
      4. just itch-setup <user> <game>
      5. Rename the game: config/name in godot/project.godot, application/bundle_identifier in godot/export_presets.cfg
    EOF

# One-shot: move the Kenney packs into Git LFS (the template ships them as plain git)
[unix]
lfs-adopt:
    sed -i.bak '/^# lfs-template:start/,/^# lfs-template:end/d' .gitattributes && rm .gitattributes.bak
    awk 'NF{for(;n>0;n--)print "";print;next}{n++}' .gitattributes > .gitattributes.new && mv .gitattributes.new .gitattributes
    git add .gitattributes && git add --renormalize godot/assets/kenney
    @echo "now commit: git commit -m 'build: move Kenney assets into Git LFS'"

# Store itch.io credentials for the release workflow (needs gh). Create a key at https://itch.io/user/settings/api-keys
itch-setup user game:
    gh secret set BUTLER_API_KEY
    gh variable set ITCH_USER --body "{{ user }}"
    gh variable set ITCH_GAME --body "{{ game }}"
