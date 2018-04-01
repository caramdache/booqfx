#!/bin/bash

function echox { tput setaf $2; echo $1; tput setaf 0; }

~/bin/booqfx.sh
open ~/Downloads/boobank.qfx

sleep 10