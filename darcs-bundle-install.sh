#!/bin/sh

LC_CTYPE=en_US.UTF-8
SVN=`which svn`

echo Changing to Bundles directory...
mkdir -p /Library/Application\ Support/TextMate/Bundles
cd /Library/Application\ Support/TextMate/Bundles

if [ -d /Library/Application\ Support/TextMate/Bundles/Darcs.tmbundle ]; then
	echo Darcs bundle already exists - updating...
	$SVN up Darcs.tmbundle
else
	echo Checking out Darcs bundle...
	$SVN --username anon --password anon co http://macromates.com/svn/Bundles/trunk/Bundles/Darcs.tmbundle/
fi

echo Reloading bundles in TextMate...
osascript -e 'tell app "TextMate" to reload bundles'