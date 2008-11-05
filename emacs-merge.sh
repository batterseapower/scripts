#!/bin/sh
#
# 3 way merge using emacs from the command line
# http://wiki.darcs.net/DarcsWiki/CategoryEmacs

amacs --eval="(ediff-merge-files-with-ancestor \"$1\" \"$2\" \"$3\" nil \"$4\")"