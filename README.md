# Shell Remote Manager

Manage your connections (and other commands) to multiple lists with sub-groups and run it easily.
Support for [Teleport](https://gravitational.com/teleport/), SSH, Kubernetes, Docker and any other commands.

## License
Project is under Do What the Fuck You Want to Public License v2 (WTFPL-2.0).

## Changes
See [CHANGELOG](CHANGELOG.md) file

## Requirements
- jq
- [Oh-My-Zsh](http://ohmyz.sh/) (if you want use plugin for tab auto-completion)

## Install

### With [Oh-My-Zsh](http://ohmyz.sh/)


```Bash
# Clone git repository to ~/.remote-manager2/
$ git clone https://github.com/MHMcz/remote-manager2.git ~/.remote-manager2

# create config file
$ cd ~/.remote-manager2/
$ cp conf.json.dist conf.json
$ chmod 600 conf.json # not required, but preferable
$ nano conf.json # edit new config file and add your settings

# instal plugin for auto-install and auto-completion
$ ln -s ~/.remote-manager2/oh-my-zsh-plugin ~/.oh-my-zsh/custom/plugins/remote-manager2

# edit ~/.zshrc and turn on new plugin
# add "remote-manager2" to "plugins" variable
# like "plugins=(... remote-manager2)"
$ nano ~/.zshrc

# reload ~/.zshrc configuration
$ source ~/.zshrc

# now you can run application
$ remote-manager
$ prod # or what you have in config in .connections[].command
$ prod CONNECTION
...
````

### Without [Oh-My-Zsh](http://ohmyz.sh/)


```Bash
# Clone git repository to ~/.remote-manager2/
$ git clone https://github.com/MHMcz/remote-manager2.git ~/.remote-manager2

# create config file
$ cd ~/.remote-manager2/
$ cp conf.json.dist conf.json
$ chmod 600 conf.json # not required, but preferable
$ nano conf.json # edit new config file and add your settings

# link remote-manager.sh to you "bin" directory
$ ln -s ~/.remote-manager2/remote-manager.sh ~/bin/remote-manager # or /usr/local/bin/remote-manager or ...

# now you can run application
$ remote-manager
$ remote-manager prod web # remote-manager COMMAND CONNECTION
...
````

## Configure

- `~/.remote-manager2/conf.json`
  - JSON format with all configured connections.
  - Every possible configuration is in sample config `~/.remote-manager2/conf.json.dist`
