# Update Language Server version

## Acceptance checklist

- [ ] One of the participants on this MR has run [local integration tests](../../docs/developer/testing.md#integration-tests) against the latest commit on the source branch.

## Contributor checklist

- [ ] I have updated `lsp/package.json`.
- [ ] I have committed the resulting `lsp/package-lock.json`.
- [ ] I used a closed version constraint (like `3.11.0`, and _not_ an open one like `^1.2.3`).
  If not, I've explained why and tagged a project maintainer.

## Maintainer checklist

- [ ] The `lint-lsp-deps` job passed confirming a reproducible environment.
- [ ] End-to-end integration tests are passing with the updated LSP server version.


/label ~"Editor Extensions::Neovim" ~"Category:Editor Extensions" ~"devops::create" ~"group::editor extensions" ~"section::dev"
/assign me
