# Development Process

1. Install `git` to clone plenary and this project.
2. Install `neovim`.
3. Clone plenary.vim through your plugin manager of choice:

   - Manual installation:

     ```sh
     git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
     ```

4. Depending on your `~/.config/nvim/init.lua`, you may need to run `nvim --clean -c` comment out some config as it can cause issues.
5. Use [`plenary.test_harness`](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness) to run tests:

   - On the command line:

     ```sh
     make test
     make test SPEC=spec/gitlab/code_suggestions_spec.lua
     ```

   - Inside of Neovim:

     ```sh
     :PlenaryBustedDirectory spec/
     :PlenaryBustedFile spec/gitlab/code_suggestions_spec.lua
     ```
