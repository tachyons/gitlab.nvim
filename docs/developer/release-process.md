# Release process

To release a new version of this extension:

1. Review whether each merge request after the last release has (or requires) a changelog entry.
1. Create a new merge request to increment the plugin version.

   1. Update `PLUGIN_VERSION` in [`lua/gitlab/globals.lua`](../../lua/gitlab/globals.lua).
   1. Add a new `## vX.Y.Z` header above the previous [CHANGELOG.md](../../CHANGELOG.md) entry.

1. After the merge request is approved, merge the merge request.
1. Create a new signed Git tag off of the `main` branch.
