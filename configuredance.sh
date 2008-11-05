#!/bin/bash
#

autoconf configure.ac > configure && chmod +x configure && autoheader configure.ac && ./configure