#!/bin/bash
#
#
echo "######## Verify Block ##########
....
"
#
block=$(bitcoin-cli getblockcount)
echo "Block number" $block
#
echo "
######## Temperature from Node ########
"
#
$HOME/./temp.sh
#
