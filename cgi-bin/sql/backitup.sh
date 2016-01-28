#!/bin/bash
# Script to back up a single table from a mysql database

DATETIME=$(date +%Y%m%d-%T)
PASSWORD="" #if you have a password, it goes here
DATABASE="" #database name

#array of table names you'd like to back up
array=(post)
len=${#array[*]} #lenght of array
i=0 #set count to zero

#loop through the list of databases
while [ $i -lt $len ]; do
	echo "$i: ${array[$i]}"
	TABLE_TMP=${array[$i]}	#set the temp var to the current array value

	#dump the table to a txt file
	mysqldump -t -T/tmp/mysql $DATABASE $TABLE_TMP --fields-terminated-by=,
	
	#mv the file and rename it with a proper date
	mv /tmp/mysql/$TABLE_TMP.txt /var/www/cgi-bin/backitup/$TABLE_TMP$DATETIME.csv
	let i++ #increment the count
done


exit;

 
 