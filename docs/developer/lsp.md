# Language Server Integration

`gitlab.vim` integrates with the
[GitLab Language Server for Code Suggestions](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp)
by installing the `@gitlab-org/gitlab-lsp` package and using the `node` interpreter.

## Dependencies

1. Refer to `package.json` for the latest supported language server version.
1. Refer to `package-lock.json` to verify dependency versions and checksums.

## Upgrading language server version

1. Install a Node version roughly matching the left most version under `nodejs` in `.tool-versions` usually through [asdf](https://asdf-vm.com).
1. Change into this plugin's root directory.
1. Set the `@gitlab-org/gitlab-lsp` dependency to the specific `MAJOR.MINOR.PATCH` version in `package.json`.

   ```json
   {
     "dependencies": {
       "@gitlab-org/gitlab-lsp": "3.10.0"
     }
   }
   ```

   > [!warning]
   > Avoid using [open version constraints](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues/56#note_1591643547)
   > such as `^3.10`.

1. Run `make package-lock.json` to install the updated dependencies.
1. Commit changes:

   ```shell
   git commit -m 'Upgrade @gitlab-org/gitlab-lsp to v3.10.0' -- package.json package-lock.json
   ```

1. Create a merge request using the [Update Language Server version](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/blob/main/.gitlab/merge_request_templates/Update%20Language%20Server%20version.md)
   merge request template.
1. Confirm MR pipeline tests are passing.
1. Configure and run [local integration tests](testing.md#integration-tests).
