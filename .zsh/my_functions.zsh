function execute_with_echo {
  cmd_with_arguments=$@;

  echo "----- ${cmd_with_arguments} ---------------";
  eval ${cmd_with_arguments};
}

function execute_commands_with_echo {
  for command in $@; do
    execute_with_echo $command
    echo
  done
}

function sdiff {
  _sdiff "-b -B"
}

function sdiff_all {
  _sdiff
}

function _sdiff {
  execute_with_echo "svn diff --diff-cmd /usr/bin/diff -x '-U 10 $1' | view -c 'set filetype=diff' -";
}

function slog {
  if (($# == 1)) then
    _limit=$1;
  else
    _limit="10";
  fi

  execute_with_echo "svn log -r HEAD:1 --limit ${_limit} --stop-on-copy";
}

function diffb {
  date=`date +"%y%m%d"`;

  if ! (($# == 1 || $# == 3)) then
    echo 'diffb: create a diff file for a branch and open it by Vim'
    echo 'Usage (1): `diffb {revision_number}`'
    echo 'Usage (2): `diffb {branch_name} {revision_number_from} {revision_number_to}`'
    return
  elif (($# == 1)) then
    rev=$1;
    filename="${date}_${APP_NAME}_@${rev}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10 -b -B' ${TARGET_REPOSITORY_URL}/branches/ -c ${rev} > ${filename}";
  elif (($# == 3)) then
    branch=$1;
    rev_from=$2;
    rev_to=$3;
    filename="${date}_${APP_NAME}_${branch}_@${rev_from}-${rev_to}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10 -b -B' ${TARGET_REPOSITORY_URL}/branches/${branch}/ -r ${rev_from}:${rev_to} > ${filename}";
  fi

  execute_with_echo ${cmd}
  execute_with_echo "vim -c ':e ++enc=utf-8' ${filename}";
}

function difft {
  date=`date +"%y%m%d"`;

  if ! (($# == 1 || $# == 2)) then
    echo 'difft: create a diff file for the trunk and open it by Vim'
    echo 'Usage (1): `difft {revision_number}`'
    echo 'Usage (2): `difft {revision_number_from} {revision_number_to}`'
    return
  elif (($# == 1)) then
    rev=$1;
    filename="${date}_${APP_NAME}_@${rev}_trunk.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10 -b -B' ${TARGET_REPOSITORY_URL}/trunk/ -c ${rev} > ${filename}";
  elif (($# == 2)) then
    rev_from=$1;
    rev_to=$2;
    filename="${date}_${APP_NAME}_trunk_@${rev_from}-${rev_to}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10 -b -B' ${TARGET_REPOSITORY_URL}/trunk/ -r ${rev_from}:${rev_to} > ${filename}";
  fi

  execute_with_echo ${cmd}
  execute_with_echo "vim -c ':e ++enc=utf-8' ${filename}";
}

function logb {
  branch=$1;
  rev_from=$2;
  rev_to=$3;

  execute_with_echo "svn log ${TARGET_REPOSITORY_URL}/branches/${branch}/ -r ${rev_from}:${rev_to} --stop-on-copy";
}

function logt {
  rev_from=$1;
  rev_to=$2;

  execute_with_echo "svn log ${TARGET_REPOSITORY_URL}/trunk/ -r ${rev_from}:${rev_to} --stop-on-copy";
}

function migrate {
  if (($# == 1)) then
    cmd="rake db:migrate VERSION=$1";
  else
    cmd="rake db:migrate";
  fi

  execute_with_echo ${cmd};
  execute_with_echo "rake db:test:clone_structure";
}

function mysql_current {
  base_dirname='branch'
  dirname=`basename \`pwd\``

  if [ "${dirname}" = "${base_dirname}" ]; then
    dbname="${APP_NAME}"
  else
    dbname="${APP_NAME}_${dirname}"
  fi

  execute_with_echo "mysql -u root ${dbname} $@";
}

function separated_rake_test {
  if (($# == 0)); then
    targets=(unit functional integration)
  else
    eval "targets=($@)"
  fi

  for target in $targets ; do
    echo "----- test test/${target}/**/*_test.rb ----------"

    for f in `/bin/ls test/${target}/**/*_test.rb`; do
      execute_with_echo "ruby $f"
    done
  done
}

function watch_memused {
  if (($# == 1)) then
    sleep=$1
  else
    sleep=15
  fi

  init='i = 0; last_notified = Time.now'
  header='"\n  " + [["time", 19], ["used%", 6], ["graph (used / all)", 0]].map{|name, width| name.to_s.ljust(width) }.join("   ")'
  put_header_or_not='i.modulo(25).zero?'
  get_memused='all, used = `free -o`.split(/\s+/).values_at(8, 9); racio = used.to_f / all.to_f * 100'
  line='"  " + [Time.now.strftime("%Y/%m/%d %H:%M:%S"), sprintf("%5.2f%", racio), "#" * (racio / 3).to_i + " (#{used} / #{all})"].join("   ")'
  notify='if racio > 90 && (Time.now - last_notified > 60); `ssh main "echo '\''(#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}) memused: #{sprintf(%Q!%5.2f%!, racio)} @#{ENV[%Q!APP_NAME!]}\n\n#{`ps aux --sort -rss | head -n 2`}'\'' | growlnotify -n '\''ZSH MemUsed Watcher'\'' --appIcon iTerm"`; last_notified = Time.now; end'
  prepare_for_next="sleep ${sleep}; i += 1"

  ruby -e "${init}; while true; puts ${header} if ${put_header_or_not}; ${get_memused}; puts ${line}; ${notify}; ${prepare_for_next}; end"
}

function tmux_setup_default {
  tmux new-session -d -s default
  tmux new-window -t default:2
  tmux new-window -t default:3
  tmux new-window -t default:4

  tmux split-window -h -t default:1
  tmux split-window -h -t default:1
  tmux split-window -h -t default:1
  tmux select-layout -t default:1 even-horizontal

  tmux split-window -h -t default:2
  tmux select-layout -t default:2 main-vertical

  tmux select-window -t default:2
  tmux attach-session -t default
}

function attach_or_new_tmux {
  if (($# == 0)); then
    session_name='default'
  else
    session_name=$1
  fi

  tmux has-session -t $session_name &> /dev/null

  if [ $? != 0 ]; then
    read response?'Create new session in directory `'$( pwd )'` with session name `'$( echo $session_name )'`? [y/n]: '

    if [[ $response =~ ^y ]]; then
      if [ $session_name = 'default' ]; then
        tmux_setup_default
      else
        tmux new-session -d -s $session_name

        if (($# == 2)); then
          tmux send-keys -t $session_name:1 "$2" Enter
        fi
      fi
    else
      echo 'Not created.'
    fi
  fi

  tmux attach -t $session_name
}

# http://d.hatena.ne.jp/itchyny/20130227/1361933011
function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -dc $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

function color_pallet() {
  execute_with_echo 'for c in {000..255}; do echo -n "\e[38;05;${c};48;05;000m $c" ; [ $(($c%16)) -eq 15 ] && echo; done; echo "\e[38;05;255;48;05;000m"'
  execute_with_echo 'for c in {000..255}; do echo -n "\e[38;05;255;48;05;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo; done; echo "\e[38;05;255;48;05;000m"'
  execute_with_echo 'for c in {000..255}; do echo -n "\e[38;05;000;48;05;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo; done; echo "\e[38;05;255;48;05;000m"'
}

function viack() {
  vi `ack $@ -l`
}

function viag() {
  vi `ag $@ -l --nocolor`
}

function vipt() {
  vi `pt $@ -l --nocolor`
}
