# Dan Maas .bash_profile
# executed ONLY by the top-level (login) bash
# mainly used to set environment variables
# aliases belong in .bashrc, NOT HERE!

# If set, bash checks the window size after each command and, if
# necessary, updates the values of LINES and COLUMNS.
if [[ $BASH_VERSION != "" ]]; then
	shopt -s checkwinsize
fi

# This is a little known and very underrated shell variable. CDPATH does
# for the cd built-in what PATH does for executables. By setting this
# wisely, you can cut down on the number of key-strokes you enter per
# day.
export CDPATH=".:~"

# Set this to to avoid having consecutive duplicate commands and other
# not so useful information appended to the history list. This will cut
# down on hitting the up arrow endlessly to get to the command before
# the one you just entered twenty times.
export HISTIGNORE="&:[bf]g:exit" 

# A colon-separated list of suffixes to ignore when performing
# filename completion 
export FIGNORE=":.pyc:~"

export EDITOR="$HOME/bin/edit"
export GNU_HOST=localhost                # for gnuserv
export GNU_SECURE="$HOME/emacs/hosts"    # ditto

# use nano for commit messages, etc
export CVSEDITOR="$HOME/bin/edit"

#export TERMINAL=rxvt

# add my personal bin directory to the path
export PATH="$HOME/bin:$PATH"

# this is my home CVS repository (via the master NFS share)
if [ ! $CVSROOT ]; then
    export CVSROOT=/shared/cvs
fi
export GOPATH="${HOME}/cvs/go"

# detect operating system
DMAAS_OS=$(uname)

# canonicalize OS name
if [ "$DMAAS_OS" = "Linux" ]; then
	DMAAS_OS="linux"
elif [ "$DMAAS_OS" = "Darwin" ]; then
	DMAAS_OS="macosx"
elif [ "$DMAAS_OS" = "CYGWIN" ]; then
	DMAAS_OS="cygwin"
elif [ "$DMAAS_OS" = "IRIX64" ]; then
	DMAAS_OS="IRIX"
fi

export DMAAS_OS

# Linux-specific

if [ "$DMAAS_OS" = "linux" ]; then
    # xterm doesn't always work due to a backwards incompatibility
    # in Debian's libncurses4 with old Emacs binaries.
    #export TERM=rxvt 
    sleep 0
fi

# Cygwin-specific
if [ "$DMAAS_OS" = "cygwin" ]; then
	export HOME=/home/dmaas
fi

# OSX-specific
if [ "$DMAAS_OS" = "macosx" ]; then
	# set up Fink environment
	if [ -f /sw/bin/init.sh ]; then
		. /sw/bin/init.sh
	fi
	# not sure why this isn't being set by OSX
	# necessary for emacs terminal colors
	#export TERM=xterm-color
	# enable X!
	#export DISPLAY=:0

    # databases
	PATH="/usr/local/mongodb/bin:/usr/local/mysql/bin:/Applications/Postgres.app/Contents/Versions/latest/bin:${PATH}"

    # PATH for Python 3 installs
    #PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
    #PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"

    # Java SDK on OSX
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home

    # Google cloud SDK
    PATH="${PATH}:${HOME}/google-cloud-sdk/bin"

    # Android SDK
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    PATH="${PATH}:${ANDROID_HOME}/platform-tools"

    export PATH

    # raise maxfiles - mainly for MongoDB
    ulimit -n 4096
fi

# set gamma for the Hitachi monitors
export GAMMA=2.0

# set Fotokem Cineon density standards
export DMIN=70
export DWHITE=720
export FILM_GAMMA=0.6

# set interp path (only for running under gdb, this is not required
# for normal use thanks to the wrapper scripts)
export INTERP_HOME="/usr/local/interp"
if [ `hostname` = "mbp15.local" ]; then
    export PROJ="/Volumes/PNY128GB/shared/proj" # laptop
else
    export PROJ="/shared/proj"
fi

# DJM hack for 2013 projects
export RMANTREE='/Applications/Pixar/RenderMan.app/Versions/RenderManProServer-16.5'
export PATH="${PATH}:${RMANTREE}/bin"

# re-enable Python DeprecationWarnings, but ignore some spurious ones
PYTHONWARNINGS="once::DeprecationWarning:"
PYTHONWARNINGS+=",ignore:the sets module:DeprecationWarning:"
PYTHONWARNINGS+=",ignore:Python 2.6 is no longer supported:DeprecationWarning:"
PYTHONWARNINGS+=",ignore:twisted.internet.interfaces.IStreamClientEndpointStringParser:DeprecationWarning:"
export PYTHONWARNINGS

# Run .bashrc
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# start ssh-agent
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
#ssh-add -l > /dev/null || ssh-add

# if we're SSHing in, then try to chdir to the directory
# specified by the client.
# otherwise go to home directory, following symlinks
if [ -n "$SSH_CHDIR_DMAAS" ]; then
    cd "$SSH_CHDIR_DMAAS"
elif [ -f /etc/spinpunch ]; then
    cd `(. /etc/spinpunch && echo $GAME_DIR)`/gameserver
elif [ -d ~/temp ]; then
    cd ~/temp
    #cd ~/personal/asia2006
fi
