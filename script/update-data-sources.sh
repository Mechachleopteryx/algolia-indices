#!/usr/bin/env bash

set -v            # print commands before execution, but don't expand env vars in output
set -o errexit    # always exit on error
set -o pipefail   # honor exit codes when piping
set -o nounset    # fail on unset variables

# bootstrap
git clone "https://electron-bot:$GH_TOKEN@github.com/electron/algolia-indices" module
cd module
npm ci

# update stuff
npm update electron-apps
npm update electron-i18n
npm update electron-npm-packages
npm update electron-releases

# Update electron-api.json
node ./script/update-electron-apis.js
# Buildes the indices
npm run build
npm test

# bail if nothing changed
if [ "$(git status --porcelain)" = "" ]; then
  echo "no new content found; goodbye!"
  exit
fi

# save changes in git
git config user.email electron@github.com
git config user.name electron-bot
git add .
git commit -am "feat: update data sources (auto-roll 🤖)"
git pull --rebase && git push origin master --follow-tags
