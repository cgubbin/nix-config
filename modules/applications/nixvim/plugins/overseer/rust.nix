_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-overseer-rust" = { lib, ... }: {
    programs.nixvim.extraConfigLua = lib.mkAfter ''
      local overseer = require("overseer")

      local function project_root()
        return _G.overseer_project_root({ "Cargo.toml", ".git", "flake.nix" })
      end

      local function is_rust_project()
        return vim.fn.filereadable(project_root() .. "/Cargo.toml") == 1
      end

      local function register_just(name, target, tags)
        overseer.register_template({
          name = name,
          tags = tags or { "rust" },
          priority = 60,
          condition = {
            callback = function()
              return is_rust_project()
            end,
          },
          builder = function()
            local root = project_root()
            return {
              cmd = { "direnv", "exec", root, "just", target },
              cwd = root,
            }
          end,
        })
      end

      register_just("Rust: Run App", "run", { "rust", "run" })
      register_just("Rust: Build Debug", "build", { "rust", "build" })
      register_just("Rust: Build Release", "release", { "rust", "build" })
      register_just("Rust: Test All", "test", { "rust", "test" })
      register_just("Rust: Test Nextest", "nextest", { "rust", "test" })
      register_just("Rust: Coverage", "coverage", { "rust", "coverage" })
      register_just("Rust: Lint", "lint", { "rust", "lint" })
      register_just("Rust: Format", "fmt", { "rust", "format" })
      register_just("Rust: Check", "check", { "rust", "check" })
      register_just("Rust: Docs", "doc", { "rust", "docs" })
      register_just("Rust: Bacon", "bacon", { "rust", "watch" })
      register_just("Rust: Flake Check", "nix-check", { "rust", "nix" })
    '';
  };
}
