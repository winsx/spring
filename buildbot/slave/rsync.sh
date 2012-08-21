#!/bin/bash
set -e
. buildbot/slave/prepare.sh

REMOTE_HOST=springrts.com
REMOTE_USER=buildbot
REMOTE_BASE=/home/buildbot/www
RSYNC="rsync -avz --chmod=D+rx,F+r --bwlimit 4000"
REMOTE_RSYNC="nice -19 ionice -c3 rsync" #prevent QQ about rsync killing server

umask 022

# use old files as base to reduce upload
RSYNC="${RSYNC} --fuzzy"
#RSYNC="${RSYNC} --compare-dest="

# cleanup installed files before rsyncing
rm -rf ${TMP_BASE}/inst/

# Rsync archives to a world-visible location.
if [ ${REMOTE_HOST} = localhost ] && [ -w ${REMOTE_BASE} ]; then
	${RSYNC} ${TMP_BASE}/ ${REMOTE_BASE}/
else
	${RSYNC} --rsync-path="${REMOTE_RSYNC}" ${TMP_BASE}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/
fi

# Clean up.
rm -rf ${TMP_BASE}/*
