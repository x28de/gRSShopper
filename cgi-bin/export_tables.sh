#!/bin/bash
# Script to back up a single table from a mysql database


PASSWORD="Vitt&enstein"
DATABASE="course"

TBOUTPUT="/var/www/cgi-bin/packs/"$DATABASE"/grsshopper_tables.sql"
mysqldump -d -u downes -p$PASSWORD $DATABASE > $TBOUTPUT
echo "tables"

array=(page view box template optlist)
len=${#array[*]} 
i=0 

while [ $i -lt $len ]; do


	TABLE=${array[$i]}
	TITLE=$TABLE"_id"
	OUTPUT="/var/www/cgi-bin/packs/"$DATABASE"/grsshopper_"$TABLE".sql"

	mysqldump -u downes -p$PASSWORD --where="TRUE ORDER BY $TITLE" course $TABLE > $OUTPUT
	echo "$i: ${array[$i]} : $OUTPUT"
	let i++
done

exit;