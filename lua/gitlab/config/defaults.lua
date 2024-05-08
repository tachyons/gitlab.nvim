return {
  gitlab_url = 'https://gitlab.com',
  statusline = {
    enabled = true,
  },
  resource_editing = {
    enabled = false,
  },
  minimal_message_level = 0,
  code_suggestions = {
    auto_filetypes = {
      'c', -- C
      'cpp', -- C++
      'csharp', -- C#
      'go', -- Golang
      'java', -- Java
      'javascript', -- JavaScript
      'javascriptreact', -- JavaScript React
      'kotlin', -- Kotlin
      'markdown', -- Markdown
      'objective-c', -- Objective-C
      'objective-cpp', -- Objective-C++
      'php', -- PHP
      'python', -- Python
      'ruby', -- Ruby
      'rust', -- Rust
      'scala', -- Scala
      'sql', -- SQL
      'swift', -- Swift
      'terraform', -- Terraform
      'typescript', -- TypeScript
      'typescriptreact', -- TypeScript React
      'sh', -- Shell scripts
      'html', -- HTML
      'css', -- CSS
    },
    enabled = true,
    fix_newlines = true,
    lsp_binary_path = 'node',
    offset_encoding = 'utf-16',
    redact_secrets = true,
  },
  language_server = {
    workspace_settings = {
      codeCompletion = {
        enableSecretRedaction = true,
      },
      telemetry = {
        enabled = true,
        trackingUrl = nil,
      },
    },
  },
}
