function execute_with_echo {
  cmd=$1;

  echo "----- ${cmd} ---------------";
  eval ${cmd};
}

function sdiff {
  execute_with_echo "svn diff --diff-cmd /usr/bin/diff -x '-U 10' | view -c 'set filetype=diff' -";
}

function slog {
  if (($# == 1)) then
    _limit=$1;
  else
    _limit="10";
  fi

  execute_with_echo "svn log -r HEAD:1 --limit ${_limit}";
}

function diffb {
  date=`date +"%y%m%d"`;

  if (($# == 1)) then
    rev=$1;
    filename="${date}_@${rev}_${APP_NAME}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/branches/ -c ${rev} > ${filename}";
  elif (($# == 3)) then
    branch=$1;
    rev_from=$2;
    rev_to=$3;
    filename="${date}_@${rev_from}-${rev_to}_${APP_NAME}_${branch}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/branches/${branch}/ -r ${rev_from}:${rev_to} > ${filename}";
  fi

  execute_with_echo ${cmd}
  execute_with_echo "vim -c ':e ++enc=utf-8' ${filename}";
}

function difft {
  date=`date +"%y%m%d"`;

  if (($# == 1)) then
    rev=$1;
    filename="${date}_@${rev}_${APP_NAME}_trunk.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/trunk/ -c ${rev} > ${filename}";
  elif (($# == 2)) then
    rev_from=$1;
    rev_to=$2;
    filename="${date}_@${rev_from}-${rev_to}_${APP_NAME}_trunk.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/trunk/ -r ${rev_from}:${rev_to} > ${filename}";
  fi

  execute_with_echo ${cmd}
  execute_with_echo "vim -c ':e ++enc=utf-8' ${filename}";
}

function logb {
  branch=$1;
  rev_from=$2;
  rev_to=$3;

  execute_with_echo "svn log ${TARGET_REPOSITORY_URL}/branches/${branch}/ -r ${rev_from}:${rev_to}";
}

function logt {
  rev_from=$1;
  rev_to=$2;

  execute_with_echo "svn log ${TARGET_REPOSITORY_URL}/trunk/ -r ${rev_from}:${rev_to}";
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

  execute_with_echo "mysql -u root ${dbname}";
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
