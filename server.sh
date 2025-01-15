#!/bin/bash

# colors
RED="\033[31m"
BOLDGREEN="\033[1;32m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
ORANGE="\033[0;33m"
ENDCOLOR="\033[0m"

# constants
DEFAULT_PORT=8545


print_help()
{
   echo "Usage: $0 -f <endpoint> -a <address> [-p port_number] [OPTIONS]"
   echo -e "\t-f endpoint to be forked"
   echo -e "\t-a address to be impersonated"
   echo -e "\t-p port number (optional)"
}

eval_background() {
    eval "$@" &>/dev/null & disown;
}

print_port() {
   if [ -n "$port_number" ]
   then 
      echo -e "port: $port_number"
   fi 
}

anvil_node() {
   echo -e "${ORANGE}" 
   echo -e "Start forking network using anvil..."

   sleep 1

   # Set to default if port number is not specified
   [ -n "$port_number" ] &&  true || port_number=$DEFAULT_PORT;

   echo -e "[anvil]" 
   echo -e "fork-url: $endpoint"
   print_port
   echo -e "impersonate_account: $impersonate_addr"

   sleep 1

   # save output to temp file
   temp_file2=$(mktemp)
   

   anvil --block-time 10 --fork-url $endpoint --port $port_number> "$temp_file2" 2>&1 &
   anvil_pid=$!

   sleep 5
   if ps -p $anvil_pid > /dev/null; then
      echo "Anvil is running with PID $anvil_pid"
   else
      echo -e "${RED}Failed to start Anvil."
      cat $temp_file2 
      exit 1
   fi

   rm "$temp_file2"
}

host_server() {
   echo -e "${CYAN}"
   echo -e "[devtunnel]"
   # eval_bg not works for this, need to store endpoint into temp file
   temp_file=$(mktemp)
   devtunnel host -p $port_number --allow-anonymous> "$temp_file" 2>&1 &
   
   # save pid
   tunnel_pid=$!

   sleep 5
   if ps -p $tunnel_pid > /dev/null; 
   then
      # ignore the inspect one 
      forwarded_endpoint=$(grep -o 'https://[a-zA-Z0-9-]*\.\(use\|asse\)\.devtunnels\.ms\|https://[a-zA-Z0-9-]*\.devtunnels\.ms' "$temp_file" | grep -v 'inspect')
      if [ -n "$forwarded_endpoint" ]; then
         echo -e "forwarded $local_node to $forwarded_endpoint${ENDCOLOR}"
      else
         echo -e "${RED}failed to retrieve the endpoint${ENDCOLOR}"
         echo -e "output from devtunnel:"
         cat $temp_file
         exit 1
      fi
   else
      echo -e "${RED}failed to start tunnel${ENDCOLOR}"
      echo -e "output from devtunnel:"
      cat $temp_file
      exit 1
   fi
   
   # rm the temp file
   rm "$temp_file"
}

impersonate() {
   echo -e "${ORANGE}"
   echo -e "[anvil]" 
   echo -e "impersonating account: $impersonate_addr"
   cast rpc anvil_impersonateAccount $impersonate_addr --rpc-url $local_node

   sleep 2
}


# parse arg
while getopts "f:a:p:h:" opt
do
   case "$opt" in
      f ) endpoint="$OPTARG" ;;
      a ) impersonate_addr="$OPTARG" ;;
      p ) port_number="$OPTARG" ;;
   esac
done

if [ -z "$endpoint" ] || [ -z "$impersonate_addr" ]
then
   print_help
   exit 1
fi


local_node="127.0.0.1:$port_number"

# run anvil node
anvil_node

echo -e "forked $endpoint, listening on $local_node in background..."

# forward to a public https endpoint
host_server

impersonate