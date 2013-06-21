## PATH editing

add_path() {
    local new_elt=$1
    local want_force=$2
    local e found

    # if the path is not a directory, no need
    [ -d "$new_elt" ] || return

    # check for an existing path element, unless force is nonempty, in
    # which case, prepend it anyway
    IFS=':'
    found=false
    if [ -z "$want_force" ]; then
        for e in $PATH; do
            if [ "$e" = "$new_elt" ]; then
                found=true
                break
            fi
        done
    fi
    unset IFS

    if ! $found; then
        PATH="$new_elt:$PATH"
    fi
}

export PATH
add_path "/Library/Frameworks/Python.framework/Versions/Current/bin"
add_path "/usr/local/bin"
add_path "/opt/local/sbin"
add_path "/opt/local/bin" force ## forced since path_helper sometimes orders it after /usr/bin
add_path "$HOME/bin"

export LANG=en_US.UTF-8

export EDITOR=vim
export PYTHONPATH="$HOME/lib/python2.5/site-packages/"

# history stuff
export HISTCONTROL=erasedups
export HISTIGNORE='ls:cd'
export HISTSIZE=2000

alias rgrep="find . -name .svn -prune -o -name .git -prune -o -name '*.swp' -prune -o -type f -print0 | xargs -0 grep --color"
alias cdt='test -n "$DEV_PROJECT" && cd "$DEV_PROJECT/t/$(basename $DEV_PROJECT)"'
alias vi='vim'

activate() { eval `dev virtualenv activate `; }

# rvm activation is funny - don't do anything until rvm is invoked
rvm() {
    unset -f rvm
    add_path "$HOME/.rvm/bin"
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
    rvm "${@}"
}

# edit patch rejections
rej() {
    test $# -eq 1 || {
        echo "Only one file at a time, please"
        exit 1
    }   
    vi -O $1.rej $1
}

# from the Gentoo /etc/bash/bashrc
# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
                eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
                eval $(dircolors -b /etc/DIR_COLORS)
        fi  
fi  

# set up the nice colored prompt
bash_color='01;34'
test -f ~/.bashrc-ps1-color && bash_color=$(<~/.bashrc-ps1-color)
if [[ ${EUID} == 0 ]] ; then
        PS1='\[\033[01;31m\]\h\[\033['${bash_color}'m\] \W \$\[\033[00m\] '
else
        PS1='\[\033[01;32m\]\u@\h\[\033['${bash_color}'m\] \w \$\[\033[00m\] '
fi  
unset bash_color

# http://henrik.nyh.se/2008/12/git-dirty-prompt
# http://www.simplisticcomplexity.com/2008/03/13/show-your-git-branch-name-in-your-prompt/
#   username@Machine ~/dev/dir [master] $   # clean working directory
#   username@Machine ~/dev/dir [master*] $  # dirty working directory
# djmitche: *edit* an existing PS1 to add the git information
# djmitche: only invoke 'git' and 'sed' once (each) for each prompt

function __git_info {
  local status dirty branch
  status=$(git status 2> /dev/null)
  test -z "$status" && return
  [[ "$status" =~ "working directory clean" ]] || dirty="*"
  if [[ "$status" =~ "Not currently on any branch" ]]; then
    branch="NO BRANCH";
  else
    branch=$(sed '1{s/.*branch \(.*\).*/\1/g;q
}' <<<"$status")
  fi
  echo " [$branch$dirty]"
}

# append git info to the current prompt
export PS1=`echo "$PS1"|sed 's!\\\\w!\\\\w$(__git_info 2>/dev/null)!g'`

# project-specific stuff
if [ "$DEV_PROJECT" ]; then
    project=`basename $DEV_PROJECT`
    echo "loading $project config"
    [ -e $DEV_PROJECT/.bashrc ] && source $DEV_PROJECT/.bashrc
fi

