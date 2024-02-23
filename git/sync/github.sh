#!/usr/bin/env bash

sync_repos() {
  local -i cloned=0 updated=0 skipped=0 failures=0

  local week_ago=$((60 * 60 * 24 * 7)) now
  if ! now="$(date +%s)"; then
    echo 'Failed to get current time'
    return 1
  fi

  local full_name clone_url pushed_at private
  while IFS=';' read -r full_name clone_url pushed_at private; do
    echo "Sync: $full_name"
    if [[ -d "/repos/Github/$full_name" ]]; then
      if (((now - pushed_at) < week_ago)); then
        echo 'Last push less than week ago; updating'
        if cd "/repos/Github/$full_name" && git remote update --prune; then
          updated=$((updated + 1))
          echo 'Success'
        else
          failures=$((failures + 1))
          echo 'FAILURE!'
        fi
      else
        skipped=$((skipped + 1))
        echo 'Last push more than week ago; skipping'
      fi
    else
      if [[ "$private" == 'true' ]]; then
        clone_url="https://$GITHUB_TOKEN@github.com/$full_name.git"
      fi

      echo "New repository: $full_name"
      if git clone --mirror "$clone_url" "/repos/Github/$full_name"; then
        cloned=$((cloned + 1))
        echo 'Success'
      else
        failures=$((failures + 1))
        echo 'FAILURE!'
      fi
    fi
    echo
  done

  echo "Cloned: $cloned"
  echo "Updated: $updated"
  echo "Skipped: $skipped"
  echo "Failures: $failures"
  echo "Total: $((cloned + updated + skipped + failures))"

  return $failures
}

if ! repos="$(curl -L -s -H 'Accept: application/vnd.github+json' \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  https://api.github.com/user/repos |
  jq -r '.[] | select(.permissions.pull and (.fork | not)) | "\(.full_name);\(.clone_url);\(.pushed_at | fromdate);\(.private)"')"; then
  echo 'Failed to fetch Github repositories'
  exit 1
fi

echo "Number of repositories: $(echo "$repos" | wc -l)"
echo

echo "$repos" | sync_repos
