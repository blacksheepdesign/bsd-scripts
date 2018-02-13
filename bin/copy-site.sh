#!/bin/bash
echo
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [DOMAIN] [OUTDIR] -- will copy a site (DOMAIN) from our production server to your local (OUTDIR)...

	[DOMAIN]	must be the name of the site on the production server
	[OUTDIR]	directory to copy to, also uses the directory name as the local site name
	-h, --help  display this help and exit

EOF
}

## Set some variables
SITE=$1
FILE=$2
REMOTE=blacksheepdesign@202.37.129.249

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color
# SLUG=basename $PATH

while :; do
	case $1 in
		-h|-\?|--help)
			show_help    # Display a usage synopsis.
			exit
			;;
		--)              # End of all options.
			shift
			break
			;;
		-?*)
			printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
			;;
		*)               # Default case: No more options, so break out of the loop.
			break
	esac

	shift
done

if [ -z "$1" ]
  then
    echo "Please specify the site you would like to sync"
    exit 0
fi

if [ -z "$2" ]
  then
    echo "No location given. Please specify where you'd like to copy the site to."
    exit 0
fi

if [ -d "$FILE" ]; then
	if [ "$(ls -A $FILE)" ]; then
		cd $FILE
		echo "Target directory $PWD is not empty. Exiting ..."
		exit 0
	else
		cd $FILE
	fi
else
	mkdir -p $FILE
	cd $FILE
fi

SLUG=$(basename $PWD)

printf "# ${GREEN}Copying files ...${NC}\n"
rsync -r blacksheepdesign@202.37.129.249:/var/www/$SITE/site_files/htdocs/ $PWD/html
echo

if [[ -f html/wp-config.php ]]; then
	printf "# ${GREEN}Copying database ...${NC}\n"
	DB_NAME=$( cat html/wp-config.php | grep DB_NAME | cut -d \' -f 4 )
	DB_USER=$( cat html/wp-config.php | grep DB_USER | cut -d \' -f 4 )
	DB_PASSWORD=$( cat html/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4 )

	ssh $REMOTE "mysqldump $DB_NAME -u $DB_USER -p$DB_PASSWORD > /var/www/${SITE}/site_files/htdocs/prod-database-transfer.sql"
	scp "$REMOTE:/var/www/${SITE}/site_files/htdocs/prod-database-transfer.sql" .
	ssh $REMOTE "rm /var/www/${SITE}/site_files/htdocs/prod-database-transfer.sql"

	mv prod-database-transfer.sql dev-database.sql
	echo
fi

printf "# ${GREEN}Initialising Vagrant ...${NC}\n"
curl -sL https://github.com/blacksheepdesign/vagrant-bsd/archive/master.tar.gz | tar xz
mv vagrant-bsd-master/* .
rm -rf vagrant-bsd-master/

vagrant box update

vagrant up > /dev/null

vagrant ssh -c "cd /var/www/html/ && wp search-replace www.${SITE} ${SLUG}-local.bsd.nz" > /dev/null
vagrant ssh -c "cd /var/www/html/ && wp search-replace ${SITE} ${SLUG}-local.bsd.nz" > /dev/null

SEARCH="{{ domain }}"

sed -i "" "s/${SEARCH}/${SLUG}/g" hosts-up.sh
sed -i "" "s/${SEARCH}/${SLUG}/g" hosts-down.sh

cat << EOF
Site downloaded (${SLUG}-local.bsd.nz)! Just run the following to get started:

	cd ${FILE}
	sudo ./hosts-up

You may also need to configure permalinks before the site works correctly.

EOF
