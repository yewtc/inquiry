#! /bin/bash
PORT=8867
bindir=$(readlink -f "${0%/*}")
[[ -d "$bindir"/../logs ]] || mkdir "$bindir"/../logs
plackup -s Starman -w 4 -a "$bindir"/app.pl -p $PORT -E production 2> "$bindir"/../logs/start.log
