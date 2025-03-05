# Development process

## Create a local development environment

1. Install `git` to clone plenary and this project.
1. Install `neovim`.
1. Clone `plenary.vim` through your plugin manager of choice:

   - Manual installation:

     ```shell
     git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
     ```

1. Use [`plenary.test_harness`](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness) to run tests:

   - On the command line:

     ```shell
     make test
     make test SPEC=spec/gitlab/code_suggestions_spec.lua
     ```

   - Inside of Neovim:

     ```shell
     :PlenaryBustedDirectory spec/
     :PlenaryBustedFile spec/gitlab/code_suggestions_spec.lua
     ```

If you encounter issues running inside of your Neovim install, use the make test targets which start a clean session with minimal plugins on the `runtimepath`.

## Documentation

New Lua modules, and Vim options and commands should be documented in `doc/gitlab.txt`.
Refer to this [Vim helpfiles cheatsheet](https://devhints.io/vim-help) for help formatting your documentation.
