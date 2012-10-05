#! /bin/bash
bindir=$(readlink -f "${0%/*}")
plackup -s Starman -w 4 -a "$bindir"/app.pl -p 8867 -E production 2> "$bindir"/../logs/start.log
