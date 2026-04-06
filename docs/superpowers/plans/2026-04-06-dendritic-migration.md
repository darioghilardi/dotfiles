# Dendritic Migration (Remove Snowfall-Lib) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove `snowfall-lib` and convert the repo to the true dendritic pattern: a minimal `flake.nix` that is just an input manifest, with all outputs declared by individual flake-parts modules discovered via `import-tree`.

**Architecture:** Add `flake-parts` + `import-tree` as inputs. Create a new `flake-modules/` directory whose files are flake-parts modules — each system, home, deploy config, formatter, and devShell is its own file that declares its own flake output. `flake.nix` shrinks to a 4-line `outputs` that delegates to `flake-parts` + `import-tree`. Shared wiring logic (`mkDarwin`/`mkNixos` helpers, nixpkgs overlays, lib extension) lives in `lib/` and is imported by the per-system files. Existing `modules/`, `systems/`, `homes/` directories are kept as-is; only their snowfall-specific args are cleaned up.

**Tech Stack:** Nix flakes, flake-parts, import-tree, nix-darwin, home-manager, nixpkgs, deploy-rs, agenix, disko.

---

## The Dendritic Pattern (Why This Is Different)

In the standard manual approach, `flake.nix` is the hub — it lists all modules, calls `mkDarwin`/`mkNixos`, and wires everything. This is verbose and requires editing `flake.nix` whenever anything changes.

In the dendritic pattern:
- `flake.nix` is **only** an input manifest + a 4-line `outputs` delegation
- `flake-parts` is the module system that merges outputs across files
- `import-tree` auto-discovers every `.nix` file in `flake-modules/` as a flake-parts module
- Each system/home declares **its own** `flake.darwinConfigurations.*` or `flake.nixosConfigurations.*` output
- Adding a new machine = add one file, touch nothing else

```
flake.nix                            ← input manifest only, 4-line outputs
flake-modules/
  systems/
    DarioAir.nix                     ← declares flake.darwinConfigurations.DarioAir
    DarioBook.nix                    ← declares flake.darwinConfigurations.DarioBook
    osaka.nix                        ← declares flake.nixosConfigurations.osaka
    saturn.nix                       ← declares flake.nixosConfigurations.saturn
  homes/
    dario@DarioAir.nix               ← declares flake.homeConfigurations."dario@DarioAir"
    dario@DarioBook.nix
    dario@osaka.nix
    dario@saturn.nix
  deploy.nix                         ← declares flake.deploy
  formatter.nix                      ← declares flake.formatter
  devShells.nix                      ← declares flake.devShells
lib/
  default.nix                        ← NEW: extended nixpkgs lib (lib.dariodots.*)
  builders.nix                       ← NEW: mkDarwin / mkNixos helpers
  module/default.nix                 ← existing dariodots lib helpers
modules/                             ← existing NixOS/darwin/HM modules (unchanged)
systems/                             ← existing per-host NixOS/darwin configs (args cleaned up)
homes/                               ← existing per-user HM configs (unchanged)
overlays/                            ← existing overlays (unchanged)
shells/                              ← existing devShell (args cleaned up)
```

---

## What Snowfall-Lib Was Doing (Reference)

| Snowfall feature | Replacement |
|---|---|
| Auto-discover `systems/<arch>/<host>` → outputs | `flake-modules/systems/*.nix` — each file declares its own output |
| Auto-discover `homes/<arch>/<user>@<host>` | `flake-modules/homes/*.nix` — each file declares its own output |
| Auto-discover `modules/<type>/<name>` | `import-tree ./modules/<type>` inside each system builder |
| Merge `lib/<name>/default.nix` into `lib.dariodots.*` | `lib/default.nix` using `nixpkgs.lib.extend` |
| Pass `namespace`, `target`, `format`, `virtual`, `systems` as special args | Remove from all module signatures |
| Pass `channels-config` | Remove; `allowUnfree` set in `lib/builders.nix` |
| `outputs-builder` for per-system outputs | flake-parts `perSystem` in `formatter.nix` / `devShells.nix` |
| `lib.mkDeploy` | `flake-modules/deploy.nix` declares `flake.deploy` directly |
| Central `lib.mkFlake` | `flake-parts.lib.mkFlake` + `import-tree ./flake-modules` |

---

## Snowfall Special Args — Files to Clean Up

The following files declare snowfall-specific args that must be removed. This is unchanged from the original plan.

**NixOS modules** (use `namespace` in body via `lib.${namespace}`):
- `modules/nixos/services/tailscale/default.nix`
- `modules/nixos/services/restic/default.nix`
- `modules/nixos/services/samba/default.nix`
- `modules/nixos/services/borgbackup/default.nix`

**Darwin modules** (declare `target, format, virtual, systems` but never use them):
- `modules/darwin/homebrew/default.nix`
- `modules/darwin/base/default.nix`
- `modules/darwin/nix/default.nix`
- `modules/darwin/system/default.nix`

**Home modules** (declare `target, format, virtual, systems` but never use them):
- `modules/home/apps/kitty/default.nix`
- `modules/home/apps/wezterm/default.nix`
- `modules/home/packages/default.nix`

**System configs**:
- `systems/aarch64-linux/osaka/default.nix` — `namespace, system, target, format, systems, disko`; uses `with lib.${namespace}`
- `systems/x86_64-linux/saturn/default.nix` — `namespace, system, target, format, systems`; uses `with lib.${namespace}`
- `systems/aarch64-darwin/DarioBook/default.nix` — `channels-config`

**Shell**:
- `shells/default/default.nix` — `mkShell, system` (snowfall-passed)

---

## Task 1: Create `lib/default.nix` and `lib/builders.nix`

**Files:**
- Create: `lib/default.nix`
- Create: `lib/builders.nix`

These two helpers are imported by the per-system flake-modules files. They replace snowfall's lib-merging and the central `mkDarwin`/`mkNixos` helpers.

- [ ] **Step 1: Create `lib/default.nix`**

```nix
# lib/default.nix
# Returns nixpkgs lib extended with lib.dariodots.* helpers.
{ inputs }:
inputs.nixpkgs.lib.extend (final: _prev: {
  dariodots = import ./module/default.nix { lib = final; };
})
```

- [ ] **Step 2: Create `lib/builders.nix`**

```nix
# lib/builders.nix
# Returns { mkDarwin, mkNixos, mkPkgs } helpers used by flake-modules/systems/*.nix
{ inputs }:
let
  lib = import ./default.nix { inherit inputs; };

  overlays = [
    (import ../overlays/devenv inputs)
    (import ../overlays/direnv inputs)
  ];

  mkPkgs = system:
    import inputs.nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

  homeModules = [
    (inputs.import-tree ../modules/home)
    inputs.mac-app-util.homeManagerModules.default
    inputs.nixCats.homeModule
  ];

  mkHomeManagerConfig = { username, system, hostname }: [
    inputs.home-manager.darwinModules.home-manager or inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs lib; };
      home-manager.sharedModules = homeModules;
      home-manager.users.${username} = import ../homes/${system}/${username}@${hostname};
      home-manager.backupFileExtension = "backup";
    }
  ];

  mkDarwin = { system, hostname, username ? "dario" }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      pkgs = mkPkgs system;
      specialArgs = { inherit inputs lib; };
      modules =
        [
          (inputs.import-tree ../modules/darwin)
          inputs.mac-app-util.darwinModules.default
          ../systems/${system}/${hostname}
          inputs.home-manager.darwinModules.home-manager
        ]
        ++ [
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs lib; };
            home-manager.sharedModules = homeModules;
            home-manager.users.${username} = import ../homes/${system}/${username}@${hostname};
            home-manager.backupFileExtension = "backup";
          }
        ];
    };

  mkNixos = { system, hostname, username ? "dario" }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = mkPkgs system;
      specialArgs = { inherit inputs lib; };
      modules =
        [
          (inputs.import-tree ../modules/nixos)
          inputs.agenix.nixosModules.default
          inputs.disko.nixosModules.disko
          inputs.vscode-server.nixosModules.default
          ../systems/${system}/${hostname}
          inputs.home-manager.nixosModules.home-manager
        ]
        ++ [
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs lib; };
            home-manager.sharedModules = homeModules;
            home-manager.users.${username} = import ../homes/${system}/${username}@${hostname};
            home-manager.backupFileExtension = "backup";
          }
        ];
    };
in
  { inherit mkDarwin mkNixos mkPkgs; }
```

- [ ] **Step 3: Commit**

```bash
git add lib/default.nix lib/builders.nix
git commit -m "feat: add lib/default.nix (extended lib) and lib/builders.nix (system helpers)"
```

---

## Task 2: Fix NixOS Modules (`namespace` → hardcoded `dariodots`)

**Files:**
- Modify: `modules/nixos/services/tailscale/default.nix`
- Modify: `modules/nixos/services/restic/default.nix`
- Modify: `modules/nixos/services/samba/default.nix`
- Modify: `modules/nixos/services/borgbackup/default.nix`

Remove `namespace` from the arg list; replace every `${namespace}` with the literal `dariodots`.

- [ ] **Step 1: Fix `tailscale/default.nix`** — replace the header:

```nix
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.services.tailscale;
in {
  options.dariodots.services.tailscale = with types; {
```

*(Body is unchanged.)*

- [ ] **Step 2: Fix `restic/default.nix`** — replace the header:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.services.restic;
in {
  options.dariodots.services.restic = with types; {
```

- [ ] **Step 3: Fix `samba/default.nix`** — replace the header:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.services.samba;
in {
  options.dariodots.services.samba = with types; {
```

- [ ] **Step 4: Fix `borgbackup/default.nix`** — replace the header:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; let
  cfg = config.dariodots.services.borgbackup;
  user = "borgbackup";
  group = "borgbackup";
in {
  options.dariodots.services.borgbackup = with types; {
```

- [ ] **Step 5: Commit**

```bash
git add modules/nixos/services/
git commit -m "refactor: remove snowfall namespace arg from nixos modules"
```

---

## Task 3: Fix System Configs and Darwin/Home Modules (Remove Snowfall Special Args)

**Files:**
- Modify: `systems/aarch64-linux/osaka/default.nix`
- Modify: `systems/x86_64-linux/saturn/default.nix`
- Modify: `systems/aarch64-darwin/DarioBook/default.nix`
- Modify: `modules/darwin/homebrew/default.nix`
- Modify: `modules/darwin/base/default.nix`
- Modify: `modules/darwin/nix/default.nix`
- Modify: `modules/darwin/system/default.nix`
- Modify: `modules/home/apps/kitty/default.nix`
- Modify: `modules/home/apps/wezterm/default.nix`
- Modify: `modules/home/packages/default.nix`

- [ ] **Step 1: Fix `osaka/default.nix`** — replace the top signature:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; {
```

- [ ] **Step 2: Fix `saturn/default.nix`** — same replacement:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
with lib;
with lib.dariodots; {
```

- [ ] **Step 3: Fix `DarioBook/default.nix`** — remove `channels-config`:

```nix
{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.dariodots; {
```

- [ ] **Step 4: Fix all four darwin modules**

For `modules/darwin/{homebrew,base,nix,system}/default.nix`, strip the snowfall-annotated comment block (`system, target, format, virtual, systems`) and their explanatory comments. New minimal header for each:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
```

*(Each file's body is unchanged — those args were declared but never used.)*

- [ ] **Step 5: Fix three home modules**

For `modules/home/apps/{kitty,wezterm}/default.nix` and `modules/home/packages/default.nix`, same strip. New header:

```nix
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
```

- [ ] **Step 6: Commit**

```bash
git add systems/ modules/darwin/ modules/home/apps/ modules/home/packages/
git commit -m "refactor: remove snowfall special args from system configs and modules"
```

---

## Task 4: Update `shells/default/default.nix`

**Files:**
- Modify: `shells/default/default.nix`

- [ ] **Step 1: Rewrite**

```nix
# shells/default/default.nix
{ inputs, pkgs, ... }:
let
  inherit (pkgs) system;
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
  agenix = inputs.agenix.packages.${system}.default;
in
  pkgs.mkShell {
    packages = with pkgs; [
      jq
      deploy-rs
      agenix
    ];
  }
```

- [ ] **Step 2: Commit**

```bash
git add shells/default/default.nix
git commit -m "refactor: update default shell to not require snowfall special args"
```

---

## Task 5: Create `flake-modules/` — Per-System and Per-Output Files

**Files:**
- Create: `flake-modules/systems/DarioAir.nix`
- Create: `flake-modules/systems/DarioBook.nix`
- Create: `flake-modules/systems/osaka.nix`
- Create: `flake-modules/systems/saturn.nix`
- Create: `flake-modules/homes/dario@DarioAir.nix`
- Create: `flake-modules/homes/dario@DarioBook.nix`
- Create: `flake-modules/homes/dario@osaka.nix`
- Create: `flake-modules/homes/dario@saturn.nix`
- Create: `flake-modules/deploy.nix`
- Create: `flake-modules/formatter.nix`
- Create: `flake-modules/devShells.nix`

Each file is a flake-parts module (receives `{ inputs, ... }` from flake-parts) and declares a slice of the flake outputs under `flake.*` or `perSystem.*`.

- [ ] **Step 1: Create `flake-modules/systems/DarioAir.nix`**

```nix
{ inputs, ... }:
let builders = import ../../lib/builders.nix { inherit inputs; };
in {
  flake.darwinConfigurations.DarioAir = builders.mkDarwin {
    system = "aarch64-darwin";
    hostname = "DarioAir";
  };
}
```

- [ ] **Step 2: Create `flake-modules/systems/DarioBook.nix`**

```nix
{ inputs, ... }:
let builders = import ../../lib/builders.nix { inherit inputs; };
in {
  flake.darwinConfigurations.DarioBook = builders.mkDarwin {
    system = "aarch64-darwin";
    hostname = "DarioBook";
  };
}
```

- [ ] **Step 3: Create `flake-modules/systems/osaka.nix`**

```nix
{ inputs, ... }:
let builders = import ../../lib/builders.nix { inherit inputs; };
in {
  flake.nixosConfigurations.osaka = builders.mkNixos {
    system = "aarch64-linux";
    hostname = "osaka";
  };
}
```

- [ ] **Step 4: Create `flake-modules/systems/saturn.nix`**

```nix
{ inputs, ... }:
let builders = import ../../lib/builders.nix { inherit inputs; };
in {
  flake.nixosConfigurations.saturn = builders.mkNixos {
    system = "x86_64-linux";
    hostname = "saturn";
  };
}
```

- [ ] **Step 5: Create four `flake-modules/homes/*.nix` files**

```nix
# flake-modules/homes/dario@DarioAir.nix
{ inputs, ... }:
let
  inherit (import ../../lib/builders.nix { inherit inputs; }) mkPkgs;
  lib = import ../../lib { inherit inputs; };
  homeModules = [
    (inputs.import-tree ../../modules/home)
    inputs.mac-app-util.homeManagerModules.default
    inputs.nixCats.homeModule
  ];
in {
  flake.homeConfigurations."dario@DarioAir" =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "aarch64-darwin";
      extraSpecialArgs = { inherit inputs lib; };
      modules = homeModules ++ [ ../../homes/aarch64-darwin/dario@DarioAir ];
    };
}
```

Repeat the same pattern for `dario@DarioBook.nix` (`aarch64-darwin`), `dario@osaka.nix` (`aarch64-linux`), and `dario@saturn.nix` (`x86_64-linux`) — only the key, system, and homes path change per file.

- [ ] **Step 6: Create `flake-modules/deploy.nix`**

```nix
{ inputs, ... }: {
  flake.deploy = {
    nodes = {
      saturn = {
        hostname = "saturn";
        remoteBuild = true;
        interactiveSudo = false;
        sshUser = "root";
        sshOpts = [ "-p" "2222" ];
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            inputs.self.nixosConfigurations.saturn;
        };
      };
      osaka = {
        hostname = "osaka";
        remoteBuild = true;
        interactiveSudo = false;
        sshUser = "root";
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos
            inputs.self.nixosConfigurations.osaka;
        };
      };
    };
  };
}
```

- [ ] **Step 7: Create `flake-modules/formatter.nix`**

```nix
{ ... }: {
  perSystem = { pkgs, ... }: {
    formatter = pkgs.alejandra;
  };
}
```

- [ ] **Step 8: Create `flake-modules/devShells.nix`**

```nix
{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = import ../shells/default { inherit inputs pkgs; };
  };
}
```

- [ ] **Step 9: Commit**

```bash
git add flake-modules/
git commit -m "feat: add flake-modules/ — each system, home, and output as its own flake-parts module"
```

---

## Task 6: Rewrite `flake.nix` (The Minimal Version)

**Files:**
- Modify: `flake.nix` (complete rewrite)

- [ ] **Step 1: Write the new minimal `flake.nix`**

```nix
{
  description = "Dario's nix system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./flake-modules);
}
```

That's the entire outputs block — 3 lines.

- [ ] **Step 2: Verify the flake evaluates**

```bash
cd ~/dotfiles
nix flake show 2>&1 | head -50
```

Expected: tree of outputs including `darwinConfigurations`, `nixosConfigurations`, `homeConfigurations`, `deploy`, `formatter`, `devShells`. No evaluation errors.

- [ ] **Step 3: Commit**

```bash
git add flake.nix
git commit -m "feat: replace snowfall-lib with minimal dendritic flake.nix (flake-parts + import-tree)"
```

---

## Task 7: Build and Verify Each Configuration

**Files:** none (verification only)

- [ ] **Step 1: Build DarioAir (darwin + home-manager)**

```bash
nix build .#darwinConfigurations.DarioAir.system --dry-run
```

Expected: prints derivation paths, no evaluation errors.

- [ ] **Step 2: Build DarioBook**

```bash
nix build .#darwinConfigurations.DarioBook.system --dry-run
```

- [ ] **Step 3: Evaluate osaka**

```bash
nix eval .#nixosConfigurations.osaka.config.system.build.toplevel.drvPath
```

- [ ] **Step 4: Evaluate saturn**

```bash
nix eval .#nixosConfigurations.saturn.config.system.build.toplevel.drvPath
```

- [ ] **Step 5: Check standalone home configs**

```bash
nix eval .#homeConfigurations."dario@DarioAir".activationPackage.drvPath
nix eval .#homeConfigurations."dario@osaka".activationPackage.drvPath
```

- [ ] **Step 6: Check devShell**

```bash
nix develop --command echo ok
```

- [ ] **Step 7: Check formatter**

```bash
nix fmt -- --check flake.nix
```

- [ ] **Step 8: Clean up — remove old files no longer needed**

```bash
git rm lib/deploy/default.nix       # inlined in flake-modules/deploy.nix
nix flake lock                      # drops snowfall-lib + flake-utils-plus from lock
git add flake.lock
git commit -m "chore: remove dead deploy lib, drop snowfall-lib from lock"
```

---

## Gotchas & Notes

### `import-tree` only scans `flake-modules/`
The `flake.nix` only passes `./flake-modules` to import-tree. The `modules/`, `systems/`, `homes/` directories are still imported the traditional way (by `lib/builders.nix`). This is intentional — those are NixOS/HM modules, not flake-parts modules.

### Adding a new machine in the future
Create `flake-modules/systems/NewHost.nix` with 5 lines. No other file changes needed.

### `perSystem` and nixpkgs
flake-parts provides `pkgs` inside `perSystem` by default using the `nixpkgs.follows` input. However, since our `mkPkgs` applies custom overlays, `formatter.nix` and `devShells.nix` use `pkgs` from flake-parts which may not have our overlays. If that matters, pass a custom pkgs via `perSystem = { system, ... }: let pkgs = mkPkgs system; in { ... }` — but for formatter and devShell it likely doesn't matter.

### `homeConfigurations` for osaka/saturn
`homes/aarch64-linux/dario@osaka/default.nix` has `home.username` and `home.homeDirectory` commented out. Standalone `home-manager switch --flake .#dario@osaka` will fail until uncommented. The embedded usage via `nixosConfigurations.osaka` is fine.

### Overlay calling convention
Both overlays use snowfall's `inputs: final: prev:` curried form. `lib/builders.nix` calls them as `(import ../overlays/devenv inputs)` which is correct.

### `deploy.nix` references `inputs.self`
`flake-parts` passes `inputs.self` automatically. The `inputs.self.nixosConfigurations.saturn` reference in `deploy.nix` works because flake-parts wires `self` before evaluating modules.
