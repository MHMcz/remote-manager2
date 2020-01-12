# Copyright © 2020 Jan Markup <mhmcze@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING file for more details.

_RM_SH="$HOME/.remote-manager2/remote-manager.sh"

remote-manager() {
  eval "$_RM_SH $@"
}

_rm_commands() {
  local COMMAND="${words[2]}"
  _arguments '*:: :->subcmds' && return 0

  if (( CURRENT == 1 )); then
    _describe -t commands "remote-manager subcommands" _RM_COMMANDS
    return
  fi
  if (( CURRENT == 2 )); then
    _describe -t commands "remote-manager subcommands" _RM_COMMANDS_$COMMAND
    return
  fi
}

local SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

local CONFIG="$HOME/.remote-manager2/conf.json"

local POS="0"
local -a _RM_COMMANDS
for COMMAND in $(jq -r ".connections[].command" "$CONFIG"); do
  _RM_COMMANDS+=( "$COMMAND" )
  alias $COMMAND="remote-manager $COMMAND"

  local -a "_RM_COMMANDS_$COMMAND"
  for SUBCOMMAND in $(jq -r ".connections[$POS].groups[].connections[].name" "$CONFIG"); do
    eval "_RM_COMMANDS_$COMMAND+=( \"$SUBCOMMAND\" )"
  done

  POS=$(($POS + 1))
done
IFS=$SAVEIFS

compdef "_rm_commands" "remote-manager"
