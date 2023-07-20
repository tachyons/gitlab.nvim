# GitLab Plugin for Neovim

A GitLab Neovim plugin including support [Code Suggestions](#code-suggestions).

## Usage

### Getting started

1. Install the [latest Neovim release](https://github.com/neovim/neovim/releases/latest)

    - For macOS, this can be achieved by running `brew install neovim`

1. Clone this repository into `~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim`

    ```sh
    git clone git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
    ```

1. Setup helptags using `:helptags ALL` for access to [:help gitlab.txt](doc/gitlab.txt).

To enable completion using Code Suggestions:

1. Follow the steps to enable [Code Suggestions (Beta)](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html) for your GitLab instance (SaaS or self-managed).

   1. Enable Code Suggestions for your GitLab group/user.
   1. Create a [Personal Access Token][] with the `api` scope.
   1. Install the GitLab Duo Code Suggestions [language server][].
   1. Use Omni completion's popup menu.

      ```lua
      vim.o.completeopt = 'menu,menuone'
      ```

## Development

1. Install `git` to clone plenary and this project.
2. Install `neovim`.
3. Clone plenary.vim through your plugin manager of choice:

   - Manual installation:

     ```sh
     git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
     ```

4. Use [`plenary.test_harness`](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness) to run tests:

   - Inside of Neovim:

     ```sh
     :PlenaryBustedDirectory spec/
     :PlenaryBustedFile spec/gitlab/code_suggestions_spec.lua
     ```

   - To run tests headlessly:

     ```sh
     make test
     make test SPEC=spec/gitlab/code_suggestions_spec.lua
     ```

## Support

Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap

If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing

Everyone can contribute. Consider linting and testing your code locally to save yourself and maintainer's time.

## Authors and acknowledgment

- @erran
- @ashmckenzie

## License

See [LICENSE](./LICENSE).

## Project status

If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.

[language server]: http://gitlab.com/gitlab-org/editor-extensions/experiments/gitlab-code-suggestions-language-server-experiment "GitLab Code Suggestions language server"
[Personal Access Token]: https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-in-your-gitlab-saas-account "Enable Code Suggestions with a Personal Access Token"
