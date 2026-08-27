#!/bin/sh

set -eu

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

repo=${1:-kshakirov/ChainDb}
issues_dir=context/issues
wiki_dir=context/wiki
issues_md_dir=$issues_dir/markdown
wiki_md_dir=$wiki_dir/markdown

mkdir -p "$issues_md_dir" "$wiki_md_dir"

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login -h github.com" >&2
  exit 1
fi

echo "Exporting issues from $repo..."
gh issue list \
  --repo "$repo" \
  --state all \
  --limit 10000 \
  --json number,title,state,stateReason,author,assignees,labels,milestone,createdAt,updatedAt,closedAt,url,body,comments,reactionGroups \
  > "$issues_dir/issues.json"

find "$issues_md_dir" -type f -name '*.md' -delete

jq -c '.[]' "$issues_dir/issues.json" | while IFS= read -r issue; do
  number=$(printf '%s' "$issue" | jq -r '.number')
  output="$issues_md_dir/$number.md"

  printf '%s' "$issue" | jq -r '
    "# #\(.number): \(.title)\n\n" +
    "- State: \(.state)\n" +
    "- Author: \(.author.login // "unknown")\n" +
    "- Created: \(.createdAt)\n" +
    "- Updated: \(.updatedAt)\n" +
    "- URL: \(.url)\n\n" +
    "## Description\n\n" +
    (.body // "") + "\n\n" +
    (if (.comments | length) == 0 then ""
     else "## Comments\n\n" +
       ([.comments[] |
         "### \(.author.login // "unknown") — \(.createdAt)\n\n\(.body)\n"] |
        join("\n"))
     end)
  ' > "$output"
done

wiki_tmp=$(mktemp -d)
trap 'rm -rf "$wiki_tmp"' EXIT HUP INT TERM

echo "Exporting wiki from $repo..."
if git clone -q "https://github.com/$repo.wiki.git" "$wiki_tmp/wiki" 2>/dev/null; then
  find "$wiki_md_dir" -type f -name '*.md' -delete
  find "$wiki_tmp/wiki" -type f -name '*.md' -exec cp {} "$wiki_md_dir/" \;

  pages_tmp=$wiki_tmp/pages.ndjson
  : > "$pages_tmp"
  find "$wiki_md_dir" -type f -name '*.md' -print | sort | while IFS= read -r page; do
    jq -Rn \
      --arg path "${page#context/wiki/}" \
      --arg title "$(basename "$page" .md)" \
      --rawfile content "$page" \
      '{path: $path, title: $title, content: $content}' >> "$pages_tmp"
  done
  jq -s '.' "$pages_tmp" > "$wiki_dir/pages.json"
else
  echo "No accessible GitHub wiki found for $repo; leaving the wiki archive unchanged." >&2
fi

echo "GitHub context snapshot updated."
