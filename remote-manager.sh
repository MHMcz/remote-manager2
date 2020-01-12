#!/bin/bash
# Copyright © 2020 Jan Markup <mhmcze@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING file for more details.

source "$HOME/.remote-manager2/functions.sh"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

CONFIG="$HOME/.remote-manager2/conf.json"
COMMAND="$1"
CONNECTION="$2"

COMMAND_ID="-1"
GROUP_ID="-1"
CONNECTION_ID="-1"

if [ "$COMMAND" == "" ]; then
  echo -e "\033[1;32mCOMMANDS\033[0m"
  for i in $(jq -r ".connections[].command" "$CONFIG"); do
    echo -e " - \033[1;31m$i\033[0m"
  done
  echo ""
  echo -n "Select command [Name]: "
  read COMMAND
fi

COMMAND_ID=$(($(jq ".connections[].command" "$CONFIG" -r | grep -nx "$COMMAND" | cut -f1 -d:) - 1))

if [ "$COMMAND_ID" -ge "0" ]; then
  GROUPS_COUNT=$(jq -r ".connections[$COMMAND_ID].groups | length" "$CONFIG")

  if [ "$CONNECTION" == "" ]; then
    INT_IDENTIFY=$(rm_get_next_free_id $COMMAND_ID 0)
    for (( i=0; i<$GROUPS_COUNT; i++ )); do
      GROUP_NAME=$(jq -r ".connections[$COMMAND_ID].groups[$i].name" "$CONFIG")
      echo -e "\033[1;32m$GROUP_NAME\033[0m"

      CONNECTIONS_COUNT=$(jq -r ".connections[$COMMAND_ID].groups[$i].connections | length" "$CONFIG")
      for (( e=0; e<$CONNECTIONS_COUNT; e++ )); do
        CONN_NAME=$(jq -r ".connections[$COMMAND_ID].groups[$i].connections[$e].name" "$CONFIG")
        COMMAND_CONFIG=$(jq ".connections[$COMMAND_ID].groups[$i].connections[$e]" "$CONFIG")
        COMMAND_TO_RUN=$(rm_final_command "$COMMAND_CONFIG")
        echo -e " - [\033[1;31m$INT_IDENTIFY\033[0m] \033[1;31m$CONN_NAME\033[0m / $COMMAND_TO_RUN"
        INT_IDENTIFY=$(rm_get_next_free_id $COMMAND_ID $INT_IDENTIFY)
      done
    done

    echo ""
    echo -n "What do you want to run? [ID/Name]: "
    read CONNECTION
  fi

  if [ "$CONNECTION" != "" ]; then
    INT_IDENTIFY=$(rm_get_next_free_id $COMMAND_ID 0)
    for (( i=0; i<$GROUPS_COUNT; i++ )); do
      CONNECTIONS_COUNT=$(jq -r ".connections[$COMMAND_ID].groups[$i].connections | length" "$CONFIG")
      for (( e=0; e<$CONNECTIONS_COUNT; e++ )); do
        CONN_NAME=$(jq -r ".connections[$COMMAND_ID].groups[$i].connections[$e].name" "$CONFIG")

        if [ "$CONNECTION" == "$CONN_NAME" ] || [ "$CONNECTION" == "$INT_IDENTIFY" ]; then
          GROUP_ID=$i
          CONNECTION_ID=$e
        fi

        INT_IDENTIFY=$(rm_get_next_free_id $COMMAND_ID $INT_IDENTIFY)
      done
    done
  fi

  if [ "$CONNECTION_ID" -ge "0" ]; then
    trueend=1
    FINAL_CONFIG=$(jq ".connections[$COMMAND_ID].groups[$GROUP_ID].connections[$CONNECTION_ID]" "$CONFIG")
    rm_connect "$FINAL_CONFIG"
  fi
fi

IFS=$SAVEIFS

if [ "$trueend" != "1" ]; then
  echo "Not valid connection selected." 1>&2
  exit 1
fi