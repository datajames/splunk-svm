# Splunk environment helper for Macs
# Version 1.3

# Fixes in 1.1
# - fixed svm started, used to break if - or . was in the Splunk instance name

# Features new in 1.2
# - svm stop-all
# ---  stop all running Splunk instances
# - svm stop-others
# ---  stop all running Splunk instances except the current select Splunk instance



# Features new in 1.3
# - svm restart-all
# --- restarts all splunk instances 
# - svm rebase
# --- resets SPLUNK_BASE to the current directory
# - svm cmd-all <cmd>
# --- runs cmd in all splunk instances 
# - svm cmd-started <cmd>
# --- runs cmd in running splunk instances 
# - tab completion semi-fixes (still some TODO)

# Feature requests not implemented
# - svm install
# --- this should install a new Splunk instance from config zip file location and assign new web/managment ports
#     , the name of the splunk instance will be a command line arg



# Change these 2 things if needed, plus maybe the PS1 setting
# towards the bottom (depending on terminal color)
SPLUNK_DEFAULT=splunk_overview
SPLUNK_BASE=/Users/jhodge/SplunkDemo/demos

# Tab completion for svm
_svm() {
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="list li"
  insts=$(\ls $SPLUNK_BASE/*/bin/splunk | while read path; do
    echo "$(echo $path | sed "s|$SPLUNK_BASE/\([^\/]*\)/bin/splunk|\1|")"
  done)

  case "$prev" in
    list|li)
      COMPREPLY=($(compgen -W "home started latest stop-all stop-others restart-all" -- $cur))
      return 0
      ;;
    *)
      COMPREPLY=($(compgen -W "started latest stop-all stop-others restart-all cmd-all cmd-started list $insts" -- $cur))  
      return 0
      ;;
  esac
}

get_item() {
  regex="$1"
  path="$2"
  result=$(grep "$regex" $path/etc/system/local/web.conf 2>/dev/null)

  if [[ -z $result ]]; then
    result=$(grep "$regex" $path/etc/system/default/web.conf 2>/dev/null)
  fi

  echo "$result"
}

get_web_port() {
  get_item "^httpport *=" $1 | awk '{print $3}'
}

get_mgmt_port() {
  get_item "^mgmtHostPort *=" $1 | awk -F: '{print $2}'
}

svm_header() {
  printf "%-20s %-20s %-10s %-10s\n" "Name" "Version" "WebPort" "MgmtPort"
  printf "%-20s %-20s %-10s %-10s\n" "====" "=======" "=======" "========"
}


svm() {
  if [[ $1 == list || $1 == li ]]; then

    if [[ -z $2 || $2 == installed ]]; then

      if [[ $1 == list ]]; then
        svm_header
      fi

      \ls $SPLUNK_BASE/*/bin/splunk | while read path; do
        webport=$(get_web_port $(dirname $(dirname $path)))
        mgmtport=$(get_mgmt_port $(dirname $(dirname $path)))

        printf "%-20s %-20s %-10s %-10s\n" \
          "$(echo $path | sed "s|$SPLUNK_BASE/\([^\/]*\)/bin/splunk|\1|")" \
          "$($path version 2>/dev/null | sed "s/Splunk \([^ ]*\) (build \([^)]*\))/splunk-\1-\2/")" \
          $webport $mgmtport
      done

    elif [[ $2 == sourced ]]; then
      basename $SPLUNK_HOME 2>/dev/null
      
    elif [[ $2 == running ]]; then
      #ps -ef | awk -F/ '/\/[s]plunkd/ {print $4}' | sort -u
      # grab the management port from the process list
      ps -ef | grep "\[splunkd" | grep -v grep | grep -v search | awk '//{print $12}' | sort -u 
      
   
    fi
    
   elif [[ $1 == started ]]; then
	ps auxwwe | grep "\[splunkd" | grep -v search | grep -v grep | perl -wlne 'print $3 if /(SPLUNK_HOME=\/(\w+\/)*([\w\-\.]+))/'
    
    elif [[ $1 == latest ]]; then
      curl http://www.splunk.com/page/release_rss 2>/dev/null | xmllint --xpath "//channel/item[1]/title/text()" -   
    
  elif [[ $1 == open ]];then
  
  	  result=$(svm started | grep "$(svm list sourced)")
      if [[ $result = "" ]];then
        echo "Splunk not running - run command 'splunk start && svm open'"
      else
        webport=$(get_web_port $SPLUNK_HOME)
        SSL=$(splunk btool web list | grep enableSplunkWebSSL | awk '//{print $3}')
        [[ $SSL = "true" ]] && PROTO="https" || PROTO="http"
        open $PROTO://localhost:$webport
	  fi
 
  elif [[ $1 == "stop-all" ]];then
      CURRENT=$(svm list sourced)
      for splunk in $(svm started)
      do
          svm $splunk
          splunk stop
      done
      svm $CURRENT
   
  elif [[ $1 == "stop-others" ]];then
          CURRENT=$(svm list sourced)
          for splunk in $(svm started)
          do
              if [ "$splunk" != "$CURRENT" ]; then
                  svm $splunk
                  splunk stop
              fi
          done
          svm $CURRENT
  
  elif [[ $1 == "rebase" ]];then
	  SPLUNK_BASE=`pwd`

  elif [[ $1 == "cmd-started" ]];then
      CURRENT=$(svm list sourced)

      for splunk in $(svm started)
      do
          svm $splunk
          ${@:2}
      done
      svm $CURRENT

  elif [[ $1 == "cmd-all" ]];then
      CURRENT=$(svm list sourced)

      insts=$(\ls $SPLUNK_BASE/*/bin/splunk | while read path; do
         echo "$(echo $path | sed "s|$SPLUNK_BASE/\([^\/]*\)/bin/splunk|\1|")"
      done)
      for splunk in $insts
      do
          svm $splunk
          ${@:2}
      done
      svm $CURRENT
  elif [[ $1 == "restart-all" ]];then
      CURRENT=$(svm list sourced)
      for splunk in $(svm started)
      do
          svm $splunk
          splunk restart
      done
      svm $CURRENT
  elif [[ $1 == home && -n $SPLUNK_HOME ]]; then
    cd $SPLUNK_HOME

  elif [[ -n $1 && -d $SPLUNK_BASE/$1 ]]; then
    stripped_path=$(echo $PATH | sed "s|$SPLUNK_BASE/[^:]*:*||g")
    export SPLUNK_HOME=$SPLUNK_BASE/$1
    export PATH=$SPLUNK_HOME/bin:$stripped_path
    export CDPATH=.:~:$SPLUNK_BASE:$SPLUNK_HOME:$SPLUNK_HOME/etc:$SPLUNK_HOME/etc/apps

  else
    echo "Usage: svm instance_name"
    echo "Or:  "
    echo ""
    echo "svm <instance_name>   : switch selected instance"
    echo "svm list              : show a list of all installed splunk instances in demo dir"
    echo "svm home              : change current dir to SPLUNK_HOME"
    echo "svm started           : show currently started Splunk instances"
    echo "svm latest            : check the internet for the latest release of Splunk"
    echo "svm open              : open the currently selected splunk instance in the default browser"
    echo "svm stop-all          : stop all running Splunk instances"
    echo "svm stop-others       : stop all other running Splunk instances"
    echo "svm restart-all       : restarts all splunk instances"
    echo "svm rebase            : resets SPLUNK_BASE to the current directory"
    echo "svm cmd-all <cmd>     : runs cmd in all splunk instances"
    echo "svm cmd-started <cmd> : runs cmd in running splunk instances"

  fi
}


#creates a list of running management ports
active_sids() {
  svm list running | sed -e :a -e '$!N; s/\n/,/; ta'
}

show_hidden() {
  arg=TRUE
  [[ $1 == no || $1 == false ]] && arg=FALSE
  defaults write com.apple.finder AppleShowAllFiles $arg
  killall Finder
}

set -o vi

# completion for svm (i.e. svm d<TAB> -> svm demo)
complete -F _svm svm 

# for dark terminals
export PS1="\n\[\e[0;40m\]\u:\[\e[0m\]\[\e[35;40m\](\$(active_sids))\[\e[0m\]\[\e[34;40m\][\$(svm list sourced)]\[\e[0m\]\[\e[0;40m\]:\w\[\e[0m\]> "
# for light terminals
#export PS1="\n\[\e[30;47m\]\u:\[\e[30m\]\[\e[35;47m\](\$(active_sids))\[\e[0m\]\[\e[34;47m\][\$(svm list sourced)]\[\e[0m\]\[\e[30;47m\]:\W\[\e[0m\]> "

# Change "demo" to your default instance
[[ -z $SPLUNK_HOME ]] && svm $SPLUNK_DEFAULT

alias ls="ls -F"
