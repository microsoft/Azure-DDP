#!/bin/bash
#This script deletes all the services associated with the cluster defined in cdhsetup.sh files
#It checks to see if it is running in an interactive mode. If it running in interactive mode it asks
#the user to confirm that cluster will be deleted. If the script is not running in interactive mode
#it deletes the cluster without prompting the user.
#It does not delete VNET, Storage Account and Affinity Group.
#VNET and Affinit group have no cost. Storage account may have images and ohter assets stored in it.
#It does print the instruction to delete vnet, affinity group and storage account so use can copy and paste to delete them.
source ./clustersetup.sh


#display the services that will be deleted.
printf "These are the services in this cluster that will be deleted:\n"

printf "Virtual network name %s\n" $vnetName
loopIndex=0
while [ $loopIndex -le $nodeCount ]; do
        vmName=$vmNamePrefix"$loopIndex"
        cloudServiceName=$cloudServicePrefix"$loopIndex"
        dnsName=$cloudServiceName".cloudapp.net"

        printf "Cloud Service %s, Virtual Machine %s\n" $dnsName $vmName
        let loopIndex=loopIndex+1
done

function deletecluster {
        printf "I am about to delete the cluster\n"
        local loopIndex=0
        while [ $loopIndex -le $nodeCount ]; do
                vmName=$vmNamePrefix"$loopIndex"
                cloudServiceName=$cloudServicePrefix"$loopIndex"
                dnsName=$cloudServiceName".cloudapp.net"
                printf "Cloud Service %s, Virtual Machine %s\n" $dnsName $vmName
                azure vm delete -q -b -v --json $vmName
                azure service delete -q -v --json $vmName
                let loopIndex=loopIndex+1
        done

        #we will not delete the vnet, storage account and affinity group but we
will echo these command so users can
        #copy these commands and run them manually.
        echo "azure network vnet delete -v -q $vnetName"
        echo "azure storage delete -q -v $storageAccount"
        echo "azure account affinity-group -v -q $affinityGroupName"
}

function end {
        printf "Cluster was not deleted.\n"
}

function choose {
        local defaults="$1"
        local prompt="$2"
        local choice_yes="$3"
        local choice_no="$4"
        local answer

        read -p "$prompt" answer
        [ -z "$answer" ] && answer="$default"
        case "$answer" in
                [yY1] ) eval "$choice_yes"
                        #error check
                        ;;
                [nN0] ) eval "$choice_no"
                        #error check
                        ;;
                * ) printf "%b" "Unexpected answer '$answer'!" >&2 ;;
        esac
}

#determine if you are running interactively and prompt for confirmation
case "$-" in
        *i*) choose N "Do you want to delete all the services assocaited with th
is cluster, select Y or N:" deletecluster end
        ;;
        *) deletecluster
        ;;
esac
echo "##########################################################################
###################"
echo "Script finished successfully"
echo "##########################################################################
###################"
exit 0
