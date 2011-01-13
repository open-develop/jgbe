#!/bin/sh
cd "$1"
SVNVER=`svnversion 2> /dev/null`

if [ "${SVNVER}" = "exported" ]; then
	GITHEAD=`git rev-parse HEAD 2> /dev/null`
	GITHEAD_ORIG="${GITHEAD}"
	SVNVER=
fi

if [ "${GITHEAD}" != "" ]; then
	GITSVN=`git rev-parse git-svn 2> /dev/null`
	
	if [ "${GITSVN}" != "" ]; then
		SVNVER=`git svn find-rev ${GITSVN}`

		if [ "${GITHEAD}" != "${GITSVN}" ]; then
			SVNVER=${SVNVER}G
		fi
		GITDIFF=`git diff HEAD | cat`

		if [ "${GITDIFF}" != "" ]; then
			SVNVER=${SVNVER}M
		fi
	fi
fi

if [ "${SVNVER}" = "" ]; then
	SVNVER="unknown"
fi

if [ "${2}" != "" ]; then
	echo "#define JGBE_VERSION_STRING \"${SVNVER}\";"  > "${2}"
else
	echo $SVNVER
fi
