#! /bin/bash -e
bindir=$(readlink -f "${0%/*}")
rm -rf "$bindir"/../{inquiry,logs,sessions}.old
[[ -f "$bindir"/../inquiry.db ]] && \
    mv "$bindir"/../inquiry.db "$bindir"/../inquiry.old
[[ -d "$bindir"/../logs ]] && \
    mv "$bindir"/../logs "$bindir"/../logs.old
[[ -d  "$bindir"/../sessions ]] && \
    mv "$bindir"/../sessions "$bindir"/../sessions.old

exit 0
