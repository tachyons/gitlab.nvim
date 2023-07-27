# Troubleshooting

[[_TOC_]]

It's important to confirm whether an issue still occurs in isolation from other Neovim plugins and settings.

## General

1. Enable [generate helptags](#generate-helptags).
1. Enable [debug logging](#enable-debug-logging).
1. Try to [create a minimal reproduction](#create-a-minimal-reproduction) if possible.
1. Please [report an issue](../../README.md#issues) or [leave feedback](../../README.md#issues).

### Generate helptags

If you get `E149: Sorry, no help for gitlab.txt` you will need to generate helptags before restarting Vim using either:

* `:helptags ALL`
* `:helptags doc/` from inside the plugin's root directory.

### Enable debug logging

Enable plugin log messages for `/tmp/gitlab.vim.log`:

1. Environment variables
   ```zsh
   GITLAB_VIM_DEBUG=1 GITLAB_VIM_LOGGING=1 nvim your_file.rb
   ```
1. Passing arguments to `gitlab.setup({opts})`
   ```lua
   logging = {
     enabled = true,
     debug = true,
   }`
   ```
 `:help gitlab-env`

### Create a minimal reproduction

Creating a sample configuration or project which reproduces your issue greatly improves maintainers ability to understand and resolve your issue.

Outlined below are some steps you can take to help in troubleshooting an issue with the plugin's Code Suggestions functionality.

1. Create a sample project:

   ```plaintext
   mkdir issue-25
   cd issue-25
   echo -e "def hello(name)\n\nend" > hello.rb
   ```
2. Create a new file `minimal.lua` with the following contents:

   ```lua
   vim.lsp.set_log_level('debug')
   
   vim.opt.rtp:append('$HOME/.local/share/nvim/site/pack/gitlab/start/gitlab.vim')
   
   vim.cmd('runtime plugin/gitlab.lua')
   
   require('gitlab').setup({
     -- Enable gitlab.vim's debug logging /tmp/gitlab.vim.log
     logging = {
       debug = true,
       enabled = true,
     },

     code_suggestions = {
       enabled = true,
     },
   })
   ```
3. Edit `hello.rb` under a minimal Neovim session:

   ```sh
   nvim --clean -u minimal.lua hello.rb
   ```
4. Attempt to reproduce the behaviour you experienced.
   * Adjust minimal.lua or project files as needed.
5. View recent entries in `/tmp/gitlab.vim.log`.

## Feature specific

On top of the [general](#general) troubleshooting advice the following feature specific advice can be used.

### Code Suggestions

#### Completions

1. Confirm that `omnifunc` is set to:
   ```lua
   :verbose set omnifunc?
   ```

#### LSP

1. Confirm the language server is active by entering in the neovim command line.
   ```lua
   :lua =vim.lsp.get_active_clients()
   ```
1. Look at the language server logs in `~/.local/state/nvim/lsp.log`
1. Inspect the `vim.lsp` log path for errors. Inside of Neovim run:

   ```
   :lua =vim.cmd('view ' .. vim.lsp.get_log_path())
   ```
1. Create a new issue if no existing issues match the problem you're encountering.
