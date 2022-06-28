#!/bin/bash

# set -x


flag=flag1=flag2=flag3=true

#Check if all pods are in running / completed state
function check-pod-status(){
    podStatus=$(kubectl get po -A | awk '{print$4}' | sed '1d')
    arrPodStatus=(`echo ${podStatus}`)
    podName=$(kubectl get po -A -o=jsonpath={.items[*].metadata.name})
    arrPodName=(`echo ${podName}`)
    podCount=$(kubectl get po -A -o json | jq -j '.items | length')
    flag=true
    echo -e "\n===============Pods which are not in Running / Completed state======================================================="
    for (( i = 0; i < $podCount; i++ ));
    do
        if [[ "${arrPodStatus[i]}" != Running && "${arrPodStatus[i]}" != Completed ]]; then
          echo "Pod ${arrPodName[i]} is in ${arrPodStatus[i]} state"
        #   exit 1
          flag=false
        fi
    done
    if [[ "${flag}" == true ]]; then
        echo -e "All Pods are in running State\n"
    fi
}
check-pod-status

#Check if all helm charts are in deployed state
function check-helm-status(){
    helm_status=$(helm ls -aA | awk '{print$8}' | sed '1d')
    helmChartStatus=(`echo ${helm_status}`)
    chart_name=$(helm ls -aA | awk '{print$1}' | sed '1d')
    helmChartName=(`echo ${chart_name}`)
    flag1=true
    echo -e "\n===============Checking if all helm charts are in deployed state====================================================="
    for (( i = 0; i < ${#helmChartStatus[@]}; i++ ))
    do
        if [[ "${helmChartStatus[i]}" != deployed ]]; then
            echo " ${helmChartName[i]} Chart is not in deployed state "
            # exit 1
            flag1=false
        fi
    done
    if [[ "${flag1}" == true ]]; then
        echo -e "All Helm Charts are in Deployed State\n"
    fi
}
check-helm-status

#Check if the Nodes in the setup are in ready state
function node-status(){
    nodeStatus=$(kubectl get nodes | awk '{print$2}' | sed '1d')
    arrNodeStatus=(`echo ${nodeStatus}`)
    nodeName=$(kubectl get nodes | awk '{print$1}' | sed '1d')
    arrNodeName=(`echo ${nodeName}`)
    flag2=true
    echo -e "\n===============Nodes are in Ready state or not======================================================================="
    for (( i = 0; i < ${#arrNodeName[@]}; i++ ));
    do
        if [[ "${arrNodeStatus[i]}" != Ready ]]; then
          echo "Pod ${arrNodeName[i]} is in ${arrNodeStatus[i]} state"
        #   exit 1
          flag2=false

        fi
    done
    if [[ "${flag2}" == true ]]; then
        echo -e "All Nodes are in Ready State\n"
    fi
}
node-status

if [[ "${flag}" == true && "${flag1}" == true && "${flag2}" == true ]]; then
 echo "==========Everything Looks Good Please Move Ahead====================================================================\n"
else
 echo "==========Please check above and look for errors=====================================================================\n"
 exit 1
fi
