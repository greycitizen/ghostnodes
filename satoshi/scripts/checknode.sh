#!/bin/bash
#
#
echo "######## Verify MemPool ##########
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
