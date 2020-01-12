#!/bin/bash
# Copyright © 2020 Jan Markup <mhmcze@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING file for more details.

rm_get_next_free_id() {
  local connections=$(jq -r ".connections[$1].groups[].connections[].name" "$CONFIG")
  local id=$(( $2 + 1 ))

  while [ $(echo "$connections" | grep -cx "$id") -gt 0 ]; do
    id=$(( $id + 1 ))
  done

  echo "$id"
}

rm_get_teleport_config() {
  local teleport=$(echo "$1" | jq -r ".config.teleport // empty")
  if [ "$teleport" != "" ]; then
    jq ".config.teleport.$teleport // empty" "$CONFIG"
  fi
}

rm_check_teleport_and_login() {
  if [ "$1" != "" ]; then
    local proxy=$(echo "$1" | jq -r ".proxy // empty")
    local user=$(echo "$1" | jq -r ".user // empty")
    local ttl=$(echo "$1" | jq -r ".ttl // empty")
    local cluster=$(echo "$1" | jq -r ".cluster // empty")
    local command="tsh --proxy \"$proxy\" --user \"$user\" --ttl \"$ttl\" login \"$cluster\""

    echo -e "> \033[1;32m$command\033[0m"
    eval $command
  fi
}

rm_check_teleport_and_logout() {
  if [ "$1" != "" ]; then
    echo -n "Do you want to logout teleport session(s)? [y/n]: "
    read tsh_logout
    if [ "$tsh_logout" == "y" ]; then
      echo -e "> \033[1;32mtsh logout\033[0m"
      tsh logout
    fi
  fi
}

rm_command_kube() {
  local namespace=$(echo "$1" | jq -r ".namespace // empty")
  local pod=$(echo "$1" | jq -r ".pod // empty")
  local container=$(echo "$1" | jq -r ".container // empty")
  local command=$(echo "$1" | jq -r ".command // empty")

  echo "kubectl exec -n \"$namespace\" -ti \"$pod\" -c \"$container\" \"$command\""
}

rm_command_ssh() {
  local host=$(echo "$1" | jq -r ".host // empty")
  local user=$(echo "$1" | jq -r ".user // empty")
  local params=$(echo "$1" | jq -r ".params // empty")

  echo "ssh $user@$host $params"
}

rm_command_docker() {
  local container=$(echo "$1" | jq -r ".container // empty")
  local command=$(echo "$1" | jq -r ".command // empty")

  echo "docker exec -ti \"$container\" /bin/sh -c \"$command\""
}

rm_final_command() {
  local config=$(echo "$1" | jq -r ".config // empty")
  local type=$(echo "$config" | jq -r ".type // empty")

  case $type in
    "kubernetes")
      echo $(rm_command_kube "$config")
      ;;

    "ssh")
      echo $(rm_command_ssh "$config")
      ;;

    "docker")
      echo $(rm_command_docker "$config")
      ;;

    "raw")
      echo "$config" | jq -r ".command // empty"
      ;;
  esac
}

rm_connect_raw() {
  echo -e "> \033[1;31m$1\033[0m"
  eval "$1"
}

rm_connect() {
  local teleport_config=$(rm_get_teleport_config "$1")
  rm_check_teleport_and_login "$teleport_config"

  local command=$(rm_final_command "$1")
  rm_connect_raw "$command"

  rm_check_teleport_and_logout "$teleport_config"
}