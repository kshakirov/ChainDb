# GitHub wiki archive

This directory is a repository-local snapshot of the GitHub wiki.

- `pages.json` contains page names, paths, and complete Markdown contents.
- `markdown/` contains the original Wiki Markdown pages.
- `drafts/` contains local Wiki drafts that must survive snapshot refreshes until they are explicitly published.

Refresh the snapshot from the repository root with:

```sh
scripts/sync-github-context.sh
```
