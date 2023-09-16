#!/usr/bin/env bash
set -euo pipefail

# Fetch hash-locked versions of assets that are dynamically fetched via
# https://github.com/mempool/mempool/blob/master/frontend/sync-assets.js
# when running `npm run build` in the frontend.
#
# This file is updated by ./frontend-assets-update.sh

declare -A revs=(
    ["blockstream/asset_registry_db"]=6f5bdb4ca4f4397f409a8b64375c35a35cea094d
    ["mempool/mining-pools"]=e889230b0924d7d72eb28186db6f96ef94361fa5
    ["mempool/mining-pool-logos"]=ef7e2efdadba5ddbc4b122892e4336e079582ecf
)

fetchFile() {
    repo=$1
    file=$2
    rev=${revs["$repo"]}
    curl -fsS "https://raw.githubusercontent.com/$repo/$rev/$file"
}

fetchRepo() {
    repo=$1
    rev=${revs["$repo"]}
    curl -fsSL "https://github.com/$repo/archive/$rev.tar.gz"
}

fetchFile "blockstream/asset_registry_db" index.json > assets.json
fetchFile "blockstream/asset_registry_db" index.minimal.json > assets.minimal.json
# shellcheck disable=SC2094
fetchFile "mempool/mining-pools" pools.json > pools.json
mkdir mining-pools
fetchRepo "mempool/mining-pool-logos" | tar xz --strip-components=1 -C mining-pools
