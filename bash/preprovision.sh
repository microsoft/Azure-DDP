echo ###CREATING AFFINITY GROUPS, STORAGE ACCOUNTS, and VNET###
sh createagstoragevnet.sh
echo ###CREATING MANAGEMENT NODE###
sh createmgmtnode.sh
echo ###CREATING CLONE NODE###
sh createclonenode.sh
