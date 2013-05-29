#! /bin/bash
PORT=8867
bindir=$(readlink -f "${0%/*}")

cd "$bindir"/.. || exit 1
[[ -d logs ]] || mkdir logs
plackup -s Starman -w 4 -a bin/app.pl -p $PORT -E production 2> logs/start.log
