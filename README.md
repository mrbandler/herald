# godot-template

An opinionated Godot 4.7 project template with GDScript, test-driven from the first commit, with automated builds and releases to itch.io. It is built for
my own desktop games (Windows, Linux, macOS) and shared in case it is useful to you; expect strong
defaults rather than a blank slate.

- TDD: GdUnit4 behind one `just test`.
- Static typing enforced in `godot/project.godot` (untyped and unsafe warnings are errors; `:=` is fine).
- Addons pinned and locked with [ggg](https://github.com/godotneers/ggg) (`godot/ggg.toml`, `godot/ggg.lock`).
- Reproducible dev environment with [devenv](https://devenv.sh) and direnv.
- Git hooks via prek: conventional commits, formatters, linters, tests before push.
- release-please versioning and changelog, per-OS exports pushed to itch.io with butler.

## Contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Everyday workflow](#everyday-workflow)
- [Commands](#commands)
- [Layout](#layout)
- [Testing](#testing)
- [Assets](#assets)
- [Addons](#addons)
- [Releasing](#releasing)
- [License](#license)

## Requirements

Recommended: [Nix](https://nixos.org), [devenv](https://devenv.sh) and [direnv](https://direnv.net).
The devenv shell provides everything else (Godot, ggg, just, prek, git-lfs, butler, linters).

Also needed:

- git with git-lfs (the devenv shell provides git-lfs).
- [GitHub CLI](https://cli.github.com) (`gh`), logged in with `gh auth login`, for `just init`, `just gh-setup` and `just itch-setup`.

### Without Nix

Install [just](https://just.systems), git-lfs, [ggg](https://github.com/godotneers/ggg) and Python 3, then:

```sh
git lfs install && git lfs pull
(cd godot && ggg sync)
```

Tests need devenv: `just test-gd` uses `$GODOT`, which only devenv sets.

## Getting started

For a new project created from the template:

1. Click **Use this template** on GitHub, then clone it.
2. In the clone: `direnv allow` (or `devenv shell`). This installs the tools, the git hooks, pulls LFS files and runs `ggg sync` in `godot/`.
3. `just init` (needs `gh auth login` and the `origin` remote; safe to re-run after a failure). It:
   - runs `just lfs-adopt` and commits the result (Kenney packs move into Git LFS),
   - creates the dependabot labels,
   - prints the next steps. It never pushes and does not apply the ruleset.

   `init` and `lfs-adopt` need a Unix shell (macOS, Linux, or WSL/Git Bash on Windows).
4. `just test` to check the setup.
5. `git push` (puts the setup commit on main), then `just gh-setup` (ruleset and squash-only merges; run once, after the push, because the ruleset requires PRs).
6. `cd godot && ggg edit` (or `godot -e --path godot`) to open the editor.
7. Rename the game: `config/name` in `godot/project.godot` and `application/bundle_identifier` in `godot/export_presets.cfg`.
8. Finish the manual steps in [Releasing](#releasing) (GitHub App, `just itch-setup`).

`just lfs-adopt` and `just gh-setup` also work on their own.

## Everyday workflow

Adding a feature, say `inventory`:

1. Branch off `main` (commits to `main` are blocked): `git switch -c feat/inventory`.
2. Scene and its own assets in `godot/game/inventory/`, script in `godot/scripts/inventory/`
   (same relative path), test in `godot/test/inventory/`. Write the test first.
3. `just test` until green; the `project-layout` hook tells you if a file is in the wrong place.
4. Commit with a conventional message (`feat: add inventory`). Hooks format, lint and check it;
   if a formatter changes files, review them and `git add` again.
5. Push and open a PR. The PR title must be conventional too (the `PR Title` check), and
   `CI Success` must pass. Merge with squash.
6. release-please keeps a release PR open; merging it tags a version and publishes the builds
   (see [Releasing](#releasing)).

## Commands

`just` lists them; all run from the repo root.

| Recipe | What it does |
|---|---|
| `just import` | Import the project headless (class cache) |
| `just test` | All tests: GDScript and engine tests |
| `just test-gd` | Import, then GdUnit4 (extra args go to Godot) |
| `just fmt` | Format all GDScript |
| `just lint` | Run all pre-commit hooks on every file |
| `just check` | Everything CI runs: `lint` then `test` |
| `just export <preset>` | Export `Linux`, `Windows` or `macOS` to `build/<preset>/` |
| `just init` | One-shot setup after "Use this template" and clone (LFS, labels); safe to re-run, never pushes |
| `just lfs-adopt` | Move the Kenney packs into Git LFS (run by `init`) |
| `just gh-setup` | Apply the repo ruleset and squash-only merge settings (needs a GitHub remote and gh auth) |
| `just itch-setup <user> <game>` | Store the itch.io credentials for the release workflow |

## Layout

The Godot project lives in `godot/` (`res://` is `godot/`), so the editor only sees the game.
Tooling and raw assets stay at the repo root, outside `res://`.

| Path | Content |
|---|---|
| `godot/project.godot`, `godot/export_presets.cfg` | Godot project; Windows, Linux, macOS presets |
| `godot/ggg.toml`, `godot/ggg.lock` | Godot version, export templates, addons (run `ggg` in `godot/`) |
| `godot/addons/` | Installed by `ggg sync`. Never edit. Three vendored addons are in git (see Addons) |
| `godot/game/` | Features: scenes plus the feature's own assets (e.g. `game/room/room.tscn`) |
| `godot/game/data/` | Shared data instances sorted by type: `atoms/`, `models/`, `passes/`, `commands/`, `input/` |
| `godot/scripts/` | All GDScript, at the same relative path as its feature in `game/` (`game/characters/player/player.tscn` uses `scripts/characters/player/player.gd`). Scene-less reusable code goes in `scripts/components/`, singletons in `scripts/autoloads/`, gameplay-neutral building blocks (atoms, interaction) in `scripts/core/<subdir>/` |
| `godot/test/` | GdUnit4 tests, mirroring `scripts/` (`scripts/pass/pass_clock.gd` is tested by `test/pass/pass_clock_test.gd`) |
| `godot/assets/` | Only content shared across features (Kenney packs); a feature's own assets live next to its scene in `game/` |
| `raw/` | Source assets (Blender, Aseprite, Krita, audio projects), stored via Git LFS; outside `res://`, so Godot never scans it |
| `devenv.nix`, `justfile`, `.pre-commit-config.yaml`, `tools/` | Tooling |
| `build/`, `reports/` | Export output and GdUnit4 reports (gitignored, outside `res://`) |
| `.github/` | Workflows, dependabot, repo ruleset |

The `project-layout` hook (`tools/check_layout.py`, tracked files only) enforces, inside `godot/`: `.gd` files
live under `scripts/` or `test/`, `.tscn` files under `game/`, every `scripts/<p>/` with scripts (except
`components/`, `autoloads/`, `core/`) has a `game/<p>/` folder, and paths are lowercase snake_case (`assets/kenney/`
keeps its third-party names as shipped, `addons/` is not checked). `.gd` and `.tscn` files outside `godot/` fail.

`docs/` is local-only.

## Testing

Models and helpers are unit tested directly; nodes are driven through their public methods; each scene
has a `*_scene_test.gd` that checks its wiring without running it.

```sh
just test        # everything
just test-gd     # import, then GdUnit4
just check       # prek on all files, then just test (what CI runs)
```

### Git hooks

| Stage | What runs |
|---|---|
| commit-msg | Conventional commit check |
| pre-commit | Formatters in fix mode (commit stops, review the changes, `git add` again), linters (gdscript lint, typos, zizmor) |
| pre-push | `just test` |

Commits to `main` are blocked; work on a branch.

## Assets

### Git LFS

Binary and raw assets (images, audio, video, fonts, 3D and paint sources, Godot binary resources)
are tracked with Git LFS; `.gitattributes` lists the formats. Text formats (`.tscn`, `.tres`,
`.gd`, `.svg`, `.gltf`) stay in plain git so they diff and merge.

- The devenv shell sets LFS up. Without Nix run `git lfs install` (Git for Windows ships git-lfs).
- Keep sources in `raw/` (outside `res://`) and export game-ready files into `godot/`.
- **Use this template** on GitHub cannot copy files stored with Git LFS, so the template ships no LFS
  files: the Kenney packs under `godot/assets/kenney/` are plain git (`.gitattributes` overrides the LFS rules
  there). Your own assets use LFS as described above.
- Check GitHub's LFS storage and bandwidth limits before committing a lot of large assets.

### Included assets

[Kenney](https://kenney.nl) assets, CC0 (public domain), each pack keeps its `License.txt`.

| Path | Content | License |
|---|---|---|
| `godot/assets/kenney/prototype_textures/` | Prototype Textures: 6 colours x 13 grid textures with a ready `texture_NN.tres` material each | CC0 |
| `godot/assets/kenney/prototype_kit/` | Prototype Kit: 145 greyboxing GLB models (walls, floors, doors, props); `Textures/` holds the colormap and variation-a/b/c | CC0 |
| `godot/assets/kenney/cursors/` | Cursor Pack: basic default-style mouse cursors (182 images) | CC0 |

Drag a `texture_NN.tres` onto a mesh, CSG or Cyclops block. The materials use world-space
triplanar mapping, so 1 grid cell = 1 m and neighbouring blocks line up.

Fonts, UI sounds, particles and more Kenney packs are per project, at <https://kenney.nl>.

## Addons

Managed by ggg and installed by `ggg sync` (run in `godot/`).

| Addon | Purpose | Source |
|---|---|---|
| GdUnit4 | Tests, mocks, scene runner | ggg, git tag |
| Phantom Camera | Camera follow, framing, transitions | ggg, git tag |
| LimboConsole | In-game dev console | ggg, release archive |
| G.U.I.D.E | Input contexts, rebinding, prompts | ggg, git tag |
| LimboAI | Behaviour trees and state machines (GDExtension) | ggg, release archive |
| YARD | Resource registries and table editor | ggg, git tag |
| Better Tooltips | Editor doc tooltips and previews | ggg, Asset Store |
| Cyclops Level Builder | In-editor level blockout and greyboxing | ggg, release archive |
| Broken Reference Finder, Todo Tracker, Unused Resource Finder | Editor audits (v1.1.0, kurtis-klay) | Godot Asset Store, vendored in git |

The last three are vendored because ggg 0.5.0 cannot parse their store entries
(`min_godot_version` is null). Update them by hand.

Add an addon:

```sh
cd godot
ggg add git <url> --name <name>
ggg add asset-store publisher/slug
ggg sync
```

### Recommended per project

Not installed; add what the game needs.

| Plugin | Use |
|---|---|
| Dialogue Manager | Branching dialogue |
| Expose Them Properties | Inspector exposure of properties |
| GodotGAS | Gameplay ability system |

### Rejected

| Plugin | Reason |
|---|---|
| GUT | GdUnit4 covers it |
| Orchestrator | Not needed |
| Unibuilder | Proprietary |
| Asset Manager | GPL |
| Log.gd | Built-in `Logger` since Godot 4.5 |
| GATE | Not needed |

## Releasing

Setup, once per repository created from the template:

1. `just init` created the dependabot labels; after `git push`, `just gh-setup` applies the `main` ruleset and merge settings.
2. **GitHub App** for release-please (create once per account, install on each repo). Actions run
   with the built-in `GITHUB_TOKEN`, and GitHub deliberately does not start other workflows from
   events that token causes. With it, CI would never run on the release PR (so the required
   checks never pass and it can't be merged) and the release tag would never trigger
   `release.yml`. A token from your own App does trigger workflows.
   - Settings, Developer settings, GitHub Apps, New GitHub App. No webhook needed.
     Repository permissions: *Contents* and *Pull requests* read/write.
   - Generate a private key, then install the App on this repo.
   - Add the secrets: `gh secret set APP_CLIENT_ID` (the App's Client ID) and
     `gh secret set APP_PRIVATE_KEY < key.pem`.
3. `just itch-setup <user> <game>` stores `BUTLER_API_KEY` (create a key at
   <https://itch.io/user/settings/api-keys>) and the `ITCH_USER` / `ITCH_GAME` variables.

Flow:

- Conventional commits on `main` keep a release PR open (`CHANGELOG.md`; `version.txt` is the only
  version). Merging it tags `vX.Y.Z`.
- `release.yml` builds on Ubuntu, Windows and macOS, stamps the
  `godot/project.godot` version from `version.txt`, exports and pushes with butler.
- Tags push the `windows`, `linux` and `macos` channels; pushes to `main` push `windows-dev`,
  `linux-dev` and `macos-dev`.
- The itch.io push is skipped when `ITCH_USER` / `ITCH_GAME` are unset. Nothing releases from the
  template repository itself.

Versioning: conventional commits drive the bump (`fix` is a patch, `feat` a minor, a breaking
change is a minor while below 1.0). Nobody edits versions by hand. To cut a specific version, e.g.
1.0.0, push an empty commit and release-please opens the PR for it:

```sh
git commit --allow-empty -m "chore: release 1.0.0" -m "Release-As: 1.0.0"
```

On itch.io, hide the `-dev` channels once. Whether new channels are public by default is
unverified: check the game's page after the first push.

macOS builds are universal (arm64 and x86_64) and ad-hoc signed, so on first launch use
right-click, Open.
