# Troubleshooting

[[_TOC_]]

It's important to confirm whether an issue still occurs in isolation from other Neovim plugins and settings.

## General

1. Enable [generate helptags](#generate-helptags).
1. Run [`:checkhealth` checks](#checkhealth).
1. Enable [debug logging](#enable-debug-logging).
1. Try to [create a minimal reproduction](#create-a-minimal-reproduction) if possible.
1. Please [report an issue](../../README.md#issues) or [leave feedback](../../README.md#issues).

### Generate helptags

If you get `E149: Sorry, no help for gitlab.txt` you will need to generate helptags before restarting Vim using either:

- `:helptags ALL`
- `:helptags doc/` from inside the plugin's root directory.

### Checkhealth

Neovim users can use `:checkhealth gitlab*` to get diagnostics on their current session's configuration.
These checks aim to give advice to help users self-service configuration issues.

Maintainers may also ask for the results of certain checks to help through the troubleshooting process.

### Enable debug logging

1. Set the `vim.lsp` log level in init.lua:

   ```lua
   vim.lsp.set_log_level('debug')
   ```

### Create a minimal reproduction

Creating a sample configuration or project which reproduces your issue greatly improves maintainers ability to understand and resolve your issue.

Outlined below are some steps you can take to help in troubleshooting an issue with the plugin's Code Suggestions functionality.

1. Create a sample project:

   ```plaintext
   mkdir issue-25
   cd issue-25
   echo -e "def hello(name)\n\nend" > hello.rb
   ```

1. Create a new file `minimal.lua` with the following contents:

   ```lua
   vim.lsp.set_log_level('debug')
   
   vim.opt.rtp:append('$HOME/.local/share/nvim/site/pack/gitlab/start/gitlab.vim')
   
   vim.cmd('runtime plugin/gitlab.lua')
   
   -- gitlab.config options overrides:
   local minimal_user_options = {}
   require('gitlab').setup(minimal_user_options)
   ```

1. Edit `hello.rb` under a minimal Neovim session:

   ```shell
   nvim --clean -u minimal.lua hello.rb
   ```

1. Attempt to reproduce the behavior you experienced.
   - Adjust minimal.lua or project files as needed.
1. View recent entries in `~/.local/state/nvim/lsp.log`.
echo ~/.local/state/nvim/lsp.log

## Feature specific

On top of the [general](#general) troubleshooting advice the following feature specific advice can be used.

### Code Suggestions

#### Completions

1. Confirm that `omnifunc` is set to:

   ```lua
   :verbose set omnifunc?
   ```

#### LSP

1. Confirm the language server is active by entering in the Neovim command line.

   ```lua
   :lua =vim.lsp.get_active_clients()
   ```

1. Look at the language server logs in `~/.local/state/nvim/lsp.log`
1. Inspect the `vim.lsp` log path for errors. Inside of Neovim run:

   ```lua
   :lua =vim.cmd('view ' .. vim.lsp.get_log_path())
   ```

1. Create a new issue if no existing issues match the problem you're encountering.
