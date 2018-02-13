#!/bin/bash

LOCATION=/usr/local/bsd-scripts

if [ $1 = "copy-site" ]; then
	"${LOCATION}/bin/copy-site.sh" $2 $3
fi

exit;