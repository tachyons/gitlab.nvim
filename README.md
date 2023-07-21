# GitLab Plugin for Neovim

A Lua based plugin for Neovim that offers [GitLab Duo Code Suggestions](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html).

All feedback can be submitted in the [[Feedback] GitLab for Neovim](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues/22) issue.

If you're interested in contributing check out the [development process](docs/developer/development-process.md).

## Requirements

| Software | Version |
| -------- | ------- |
| [GitLab SaaS](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-on-gitlab-saas) | 16.1+ |
| [GitLab self-managed](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-on-self-managed-gitlab) | 16.1+ |
| [Neovim](https://neovim.io/) | 0.9+ |

## Setup

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
   1. Configure [Omni completion](https://neovim.io/doc/user/insert.html#compl-omni-filetypes)'s popup menu:

      ```lua
      vim.o.completeopt = 'menu,menuone'
      ```

   1. Use `ctrl-x ctrl-o` to open the Omni completion popup menu inside of supported filetypes.

## Features

### GitLab Duo Code Suggestions (Beta)

Write code more efficiently by using generative AI to suggest code while you’re developing. To learn more about this feature, see the
[GitLab Duo Code Suggestions documentation](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-in-vs-code)

This feature is in
[Beta](https://docs.gitlab.com/ee/policy/experiment-beta-support.html#beta)
GitLab Duo Code Suggestions is a generative artificial intelligence (AI) model. GitLab currently leverages [Google Cloud’s Vertex AI Codey API models](https://cloud.google.com/vertex-ai/docs/generative-ai/code/code-models-overview)

No new additional data is collected to enable this feature. Private non-public GitLab customer data is not used as training data.
Learn more about [Google Vertex AI Codey APIs Data Governance](https://cloud.google.com/vertex-ai/docs/generative-ai/data-governance)

Beta users should read about the [known limitations](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#known-limitations)

#### Supported Languages

Languages supported by GitLab Duo Code Suggestions can be found in the [documentation](https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#supported-languages).

#### Usage
See [doc/gitlab.txt](./doc/gitlab.txt) or run `:help gitlab.txt` to read usage information without leaving your editor.

If you get `E149: Sorry, no help for gitlab.txt` you will need to generate helptags before restarting Vim using either:

* `:helptags ALL`
* `:helptags doc/` from inside the plugin's root directory.

##### Keymaps

If using `gitlab.code_suggestions` with the builtin LSP client and Omni completion:
- `ctrl-x ctrl-o` requests completions from GitLab Duo Code Suggestions

#### Status Bar

A status icon is displayed in the status bar. It provides the following:

1. A button that can quickly disable/enable code suggestions.
1. Display a code suggestion in progress icon.
1. Display an error icon and provide an error message as tooltip.
1. Before the extension has been configured, the error icon will be shown with a message about configuration.

Report issues in the
[feedback issue](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues/22).

## Contributing

This extension is open source and [hosted on GitLab](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git). Contributions are more than welcome. Feel free to fork and add new features or submit bug reports. See [CONTRIBUTING](./CONTRIBUTING.md) for more information.

[A list of the great people](./CONTRIBUTORS.md) who contributed this project, and made it even more awesome, is available. Thank you all! 🎉

- @erran
- @ashmckenzie

## License

See [LICENSE](./LICENSE).

[language server]: http://gitlab.com/gitlab-org/editor-extensions/experiments/gitlab-code-suggestions-language-server-experiment "GitLab Code Suggestions language server"
[Personal Access Token]: https://docs.gitlab.com/ee/user/project/repository/code_suggestions.html#enable-code-suggestions-in-your-gitlab-saas-account "Enable GitLab Duo Code Suggestions with a Personal Access Token"
