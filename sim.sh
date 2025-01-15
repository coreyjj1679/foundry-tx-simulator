#!/bin/bash

input_file="commands.txt"

alias_names=()
alias_values=()

while IFS= read -r line; do
    # store aliases
    if [[ $line == alias* ]]; then
        alias_name=$(echo "$line" | cut -d'=' -f1 | awk '{print $2}')
        alias_value=$(echo "$line" | cut -d'=' -f2 | tr -d ' ')
        
        # Store in arrays
        alias_names+=("$alias_name")
        alias_values+=("$alias_value")
    elif [[ -n $line ]]; then 
        IFS=',' read -r command address func_and_args <<< "$line"
        if [[ " ${alias_names[@]} " =~ " ${address} " ]]; then
            # get acutal value
            for i in "${!alias_names[@]}"; do
                if [[ "${alias_names[$i]}" == "$address" ]]; then
                    address=${alias_values[$i]}
                    break
                fi
            done
        fi

        func=""
        args=""
        bracket_count=0
        found_comma=false

        # ensure it works for func(uint,uint). dun parse the comma between arg
        for (( i=0; i<${#func_and_args}; i++ )); do
            char="${func_and_args:i:1}"
            if [[ "$char" == "(" ]]; then
                ((bracket_count++))
            elif [[ "$char" == ")" ]]; then
                ((bracket_count--))
            elif [[ "$char" == "," && $bracket_count -eq 0 && $found_comma == false ]]; then
                found_comma=true
                func="${func_and_args:0:i}"
                args="${func_and_args:i+1}"   
                break
            fi
            if [[ $found_comma == false ]]; then
                func+="$char"
            fi
        done

        func=$(echo "$func" | sed 's/^ *//;s/ *$//')
        args=$(echo "$args" | sed 's/^ *//;s/ *$//')

        func="\"$func\""

        command="cast call $address $func $args --rpc-url 127.0.0.1:8088"
        echo -e "calling $command"
        eval "${command}"
    fi
done < "$input_file"