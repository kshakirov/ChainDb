# GitHub issues archive

This directory is a repository-local snapshot of GitHub issues.

- `issues.json` contains the complete machine-readable export produced by `gh`.
- `markdown/` contains one readable Markdown file per issue.

Refresh the snapshot from the repository root with:

```sh
scripts/sync-github-context.sh
```

