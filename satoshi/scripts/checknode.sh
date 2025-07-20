#!/bin/bash
#
#
echo "######## Verify Block ##########
....
"
#
block=$(bitcoin-cli getblockcount)
echo "Bloco n." $block
#
echo "
######## Temperature from Node ########
"
#
$HOME/./temp.sh
#
