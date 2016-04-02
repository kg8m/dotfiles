ls -l ~/.tmux/resurrect/last | awk '{print $NF}' | egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' -o | sed -e 's/T/ /' | sed -e 's/-/\//g'
