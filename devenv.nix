{ pkgs, lib, ... }:
let
  # godot/ggg.toml is the single source for the Godot version.
  gggConfig = builtins.fromTOML (builtins.readFile ./godot/ggg.toml);
  godot = pkgs.godot_4_7;
  godotBin = lib.getExe godot;

  # Built from source so it runs on NixOS (release binaries are generic glibc builds).
  ggg = pkgs.rustPlatform.buildRustPackage rec {
    pname = "ggg";
    version = "0.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "godotneers";
      repo = "ggg";
      rev = "v${version}";
      hash = "sha256-UgCHh3uj53ZI7eWH1KIhWW1hLC5eWF0i2wYbQLRUiJk=";
    };
    cargoHash = "sha256-loJPh3r0xq68Pf0XmO8zIOD7r6CforDa5QdHLCSMg9I=";
    doCheck = false; # upstream tests need network mocks
  };
in
{
  assertions = [
    {
      assertion = godot.version == gggConfig.project.godot;
      message = "nixpkgs Godot is ${godot.version} but godot/ggg.toml pins ${gggConfig.project.godot}. Update nixpkgs (devenv update) or godot/ggg.toml.";
    }
  ];

  packages = with pkgs; [
    godot
    ggg
    just
    prek
    git-lfs
    typos
    zizmor
    jq
    gh
    butler
    gdscript-formatter
    python3 # project layout hook
  ];

  env = {
    GODOT = godotBin;
    GGG_GODOT_EXECUTABLE = godotBin;
  };

  enterShell = ''
    # git-lfs first: prek then keeps its pre-push hook as pre-push.legacy and runs it on every push.
    if [ ! -f .git/hooks/pre-push.legacy ]; then
      rm -f .git/hooks/pre-push
      git lfs install --local
    fi
    git lfs pull >/dev/null 2>&1 || echo "warning: git lfs pull failed (offline or no remote?)"
    prek install
    (cd godot && ggg sync)
  '';
}
