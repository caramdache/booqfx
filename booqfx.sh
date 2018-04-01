#!/bin/bash

function echox { tput setaf $2; echo $1; tput setaf 0; }

function header {
  echo "OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:2f1fe7b3-19fd-11e8-b173-14109fe83058

<OFX>

<SIGNONMSGSRSV1>
  <SONRS>
    <STATUS>
      <CODE>0
      <SEVERITY>INFO
      <MESSAGE>SUCCESS
    </STATUS>
    <DTSERVER>$(date '+%Y%m%d%H%M%S')
    <LANGUAGE>ENG
    <INTU.BID>03101
  </SONRS>
</SIGNONMSGSRSV1>
" > ~/Downloads/boobank.qfx
}

function footer {
  echo "
</OFX>" >> ~/Downloads/boobank.qfx
}

function once_per_day {
  # Run at most once per day (useful when crontab'ed)
  LAST=$(tail -1 ~/.boobank_last_sync_date)
  TODAY=$(date '+%Y-%m-%d')
  if (( LAST == TODAY )); then
      echox "ALREADY run today." 4
      exit
  fi
}

function connectivity {
  # Leave time to wakeup from standby
  RETRIES=4
  until (( RETRIES-- == 0 )); do
    /usr/local/bin/fping -c1 -t300 8.8.8.8 2>/dev/null 1>/dev/null
    if (( $? == 0 )); then
      break
    fi
    if (( RETRIES == 0 )); then
      echox "NO network." 4
      exit
    fi

    sleep 10
  done
}

function accounts {
  if [ ! -f ~/.boobank_accounts.json ]; then
    echo "Retrieving accounts..."
    /usr/local/bin/boobank ls -f json > ~/.boobank_accounts.json
    cat ~/.boobank_accounts.json | jq '.[].id' | tr -d '"' > ~/.boobank_accountids.txt
  fi
}

function transactions {
  # Retrieve transactions for the selected accounts
  cat ~/.boobank_accountids.txt | /usr/local/bin/parallel -j0 ~/bin/boohistory.sh

  # Move credit card transactions at the end
  sed -ie '/<CREDITCARDMSGSRSV1>/,/<\/CREDITCARDMSGSRSV1>/{1h;1!H;d;};$G' ~/Downloads/boobank.qfx

  # Keep one bank and one credit card sections, or else Quicken will not import
  gsed -Ezi \
    -e 's@</BANKMSGSRSV1>[[:space:]]*<BANKMSGSRSV1>@\n\n@g' \
    -e 's@</CREDITCARDMSGSRSV1>[[:space:]]*<CREDITCARDMSGSRSV1>@\n\n@g' ~/Downloads/boobank.qfx
}

function report {
  # Report progress and update last download date
  COUNT_ACCTS=$(cat ~/Downloads/boobank.qfx | grep ACCTID | uniq | wc -l | tr -d " ")
  COUNT_TRANS=$(cat ~/Downloads/boobank.qfx | grep TRNAMT | wc -l | tr -d " ")
  if (( COUNT_TRANS > 0 )); then
    date '+%Y-%m-%d' >> ~/.boobank_last_sync_date
    echox "$COUNT_ACCTS account(s)." 3
    echox "$COUNT_TRANS transaction(s) downloaded." 2
  else
    echox "NO transaction avalaible." 4
  fi
}

#once_per_day
#connectivity

accounts

header
transactions
footer

report