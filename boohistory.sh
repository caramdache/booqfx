#!/bin/bash

function save {
  # Replace dot by commas (Quicken won't import otherwise)
  # Remove individual headers and footers
  sed -E \
    -e 's@<TRNAMT>(-?[[:digit:]]+)\.@<TRNAMT>\1,@g' \
    -e 's@<BALAMT>(-?[[:digit:]]+)\.@<BALAMT>\1,@g' \
    -e 's@</OFX>@@' | \
  tail -n +13 >> ~/Downloads/boobank.qfx
}

function history {
  /usr/local/bin/boobank -q history $1 -f ofx -n 30 -q | save
}

function coming {
  /usr/local/bin/boobank -q coming $1 -f ofx -n 30 -q | save
}

function loan {
  echo "NOT IMPLEMENTED"
}

function unknown {
  echo "NOT IMPLEMENTED"
}

function account_type {
  cat ~/.boobank_accounts.json | jq --arg account $1 '.[]|select(.id == $account)|.type'
}

echo "$1..."
ACCOUNT_TYPE=$(account_type $1)
case $ACCOUNT_TYPE in
  1) history $1;;
  2) history $1;;
  8) history $1;;
  4) loan $1;;
  7) coming $1;;
  *) unknown $1;;
esac
