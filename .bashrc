# Dan Maas .bashrc
# executed by EVERY interactive bash
# mainly used for aliases
# environment variables belong in .bash_profile, NOT HERE!
# (except for $PS1)

# disable Ctrl-S "terminal stop" command which I keep hitting
# by accident
if [ "$PS1" ]; then # interactive shells only
	stty stop undef > /dev/null 2>&1
fi

# load completions
if [ "$PS1" ] && echo $BASH_VERSION | grep -q '^2' \
   && [ -f ~/.bash_completion ]; then # interactive shell
        # Source completion code
        . ~/.bash_completion
fi

# detect shell flavor
if [[ $ZSH_VERSION != "" ]]; then
    SHELL_FLAVOR="zsh"
    setopt HIST_IGNORE_DUPS
else
    SHELL_FLAVOR="bash"
fi

if [ $SHELL_FLAVOR = "zsh" ]; then
RED="%F{red}"
YELLOW="%F{yellow}"
GREEN="%F{green}"
GRAY="%F{236}"
PINK="%F{201}"
LIGHT_GRAY="%F{250}"
CYAN="%F{6}"
LIGHT_CYAN="%F{14}"
NO_COLOR="%f"
else
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
GRAY="\[\033[1;30m\]"
PINK="\[\033[0;35m\]"
LIGHT_GRAY="\[\033[0;37m\]"
CYAN="\[\033[0;36m\]"
LIGHT_CYAN="\[\033[1;36m\]"
NO_COLOR="\[\033[0m\]"
fi

# my prompt

# necessary to show git branch in prompt
function dmaas_parse_git_branch () {
    if [ -d '.git' ] && [ -x "$(command -v "git")" ]; then
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
    else
        echo -n
    fi
}

if [ "$TERM" = "dumb" ]; then
    export PS1="> "
elif [ "$UID" -eq 0 ]; then
    if [ $SHELL_FLAVOR = "zsh" ]; then	
	export PS1="$RED[\u@\h \w]$NO_COLOR "
    else
	export PS1="%F{red}[\u@\h \w]%f "
    fi
else
    if [ "$DMAAS_OS" = macosx ]; then
  	COLOR="$PINK"
    else
	COLOR="$YELLOW"
    fi

    if [ $SHELL_FLAVOR = "zsh" ]; then
	setopt PROMPT_SUBST
	export PS1='%F{201}[%n@%m %~%F{green}$(dmaas_parse_git_branch)%F{201}]%f '
    else
	export PS1="$COLOR[\u@\h \w$GREEN\$(dmaas_parse_git_branch)$COLOR]$NO_COLOR "
    fi
    unset COLOR
fi

# default perms = rwx rwx r-x
umask 002

# make ls pretty
if [ "$DMAAS_OS" = "IRIX" ]; then
    alias ls='ls -lh'
elif [ "$DMAAS_OS" = cygwin ]; then
    alias ls='ls -l'
elif [ "$DMAAS_OS" = macosx ]; then
	alias ls='ls -lFh'
else
    alias ls='ls -lh --color=auto'
fi

alias grep='grep --color=always --exclude-dir=\*.svn\*'
alias grpe='grep' # misspelling
alias date='date -u' # always show date in UTC

# PS - show all procs, show wait info, show vm data
# VSZ = total VM size (KB), RSS = resident size (incl DLLs/shm)
if [ "$DMAAS_OS" = "IRIX" ]; then
    alias ps='ps -Af -o pid,user,vsz,rss,time,args'
elif [ "$DMAAS_OS" = macosx ]; then
    alias ps='ps ax -o pid,user,vsize,rss,time,stat,command'
else
    alias ps='ps afx -o pid,user,vsize,rss,time,stat,command'
fi

# I like these utils to read in KB, MB, etc
# instead of UNIX "blocks"
alias df='df -h'
alias du='du -h'
alias free='free -m'

if [ ! "$UID" -eq 0 ]; then
	# do not tell SSH to forward X by default
	alias ssh='ssh -q'
else
	alias ssh='ssh -q'
fi

# supress GDB annoyance
alias gdb='gdb -quiet'

# tell wget to resume all downloads, and retry forever
alias wget='wget -t 0 -c'

alias lynx='lynx -force_secure -nopause -image_links'

# make BC into a useful calculator by loading the math library
alias bc='bc -l'

# sane options for a2ps
alias a2ps='a2ps -o - --portrait -1 --no-header --borders no'

alias h='check-image -h -v'
alias v='viewer'
alias nt="nano $HOME/Dropbox/Personal/todo.txt"

alias mgd='./make-gamedata.sh -u && kill -HUP `cat server_*.pid` `cat proxyserver.pid`'
rs() { # restart sandbox server and tail exceptions
 kill `cat server_default.pid`; ./server.py --skip default && tail -f logs/`date +%Y%m%d`-exceptions.txt;
}
alias tssh='$HOME/cvs/battlehouse-infra/scripts/tssh.sh'
alias tsql='$HOME/cvs/battlehouse-infra/scripts/tsql.sh'
alias csql='$HOME/cvs/coreplane-infra/scripts/csql.sh'

alias kc='kubectl'
# get status of GKE cluster autoscaler
alias kscale='kubectl describe -n kube-system configmap cluster-autoscaler-status'

# rename JPEG files according to date/time from EXIF header
# alias jheadtime='jhead -n%Y%m%d'

# non-Linux shells sometimes don't support 'which'
# alias which='type -path'

# Cygwin-specific
if [ "$DMAAS_OS" = cygwin ]; then
	cd $HOME
else
	# Everything BUT Cygwin

	# ls colors
	if [ "$DMAAS_OS" != "macosx" ] && [ $SHELL_FLAVOR = "bash" ]; then
		eval `dircolors ~/.dir_colors`
	fi

	# Iconify:
	function  ic  { echo -en "\033[2t"; }

	# Restore:
	function  re  { echo -en "\033[1t"; }
	## try:  ic; make a_lot; re


	# magic commands to alter xterm/Terminal.app window titles
	if [ -n "$SSH_TTY" ] || [ -n "$DISPLAY" ]; then # set PROMPT_COMMAND:

	    TAPP="$(hostname | cut -d. -f1)";

	    # on OSX, system PROMPT_COMMAND already shows the working directory, so omit that part
	    if [ "$DMAAS_OS" != "macosx" ]; then
		PROMPT_COMMAND_CWD=":\`dirs +0\`"
	    else
		PROMPT_COMMAND_CWD=""
	    fi

	    PROMPT_COMMAND="echo -ne '\033]0;'$TAPP$PROMPT_COMMAND_CWD'\007';$PROMPT_COMMAND"

	    TPC="$PROMPT_COMMAND"; # original prompt command
	    # 'pp arg' sets title to arg
	    # 'pp' resets title to default
	    function pp
	    {
		if test -z "$1"; then
		    PROMPT_COMMAND=$TPC;
		else
		    unset PROMPT_COMMAND;
		    echo -ne '\033]0;' $@ '\007';
		fi
	    }

	    function xs  ## cd to dir and set title,  'xs .' just puts dirname into title
	    {
		cd $1;  pp ${PWD##*/}
	    }
	fi
	# =========== end xterm window title voodoo
fi

