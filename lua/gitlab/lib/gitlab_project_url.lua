return {
  parse = function(remote_uri)
    local uri = remote_uri:match('(.+)%.git$') or remote_uri
    if uri:match('^(https?)://([^/]+)') then
      return {
        full_path = uri:match('^https?://[^/]+/(.+)'),
        remote_uri = remote_uri,
      }
    elseif uri:match('^ssh://([^/]+)') then
      return {
        full_path = uri:match('^ssh://[^/]+/(.+)'),
        remote_uri = remote_uri,
      }
    elseif uri:match('^%w*:?%w+@.+:') then
      return {
        full_path = uri:match('^%w*:?%w+@.+:(.+)'),
        remote_uri = remote_uri,
      }
    end

    return { remote_uri = remote_uri }
  end,
}
