#!/bin/bash
# Script to back up a single table from a mysql database




TBOUTPUT="/var/www/cgi-bin/packs/"$1"/grsshopper_tables.sql"
mysqldump -d -u downes -p$2 --ignore-table=$3.config --ignore-table=$3.person --ignore-table=$3.cache $3 > $TBOUTPUT
echo "Saving Table Structure for Database $3 <br>"
echo "Creating new Data Pack titled $1 <br>";

i=0
for TABLE in "$@"
do
	if [ $i -gt 2 ]
	then
		TITLE=$TABLE"_id"
		OUTPUT="/var/www/cgi-bin/packs/"$1"/grsshopper_"$TABLE".sql"
		mysqldump -u downes -p$2 --where="TRUE ORDER BY $TITLE" $3 $TABLE > $OUTPUT
		echo "mysqldump -u downes -p$2 --where=TRUE ORDER BY $TITLE $3 $TABLE > $OUTPUT<br>"
		echo "$OUTPUT"
		echo "<br>"
	fi
	

    let i++
done




exit;
