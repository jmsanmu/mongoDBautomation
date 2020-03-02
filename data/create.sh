#!/bin/bash
 #Bash colors
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
BLUE='\033[1;34m'

 if [ ! $2 ]; then
	echo " Param 0: $0"
	echo " Param 1: Data base name"
	echo " Param 2: Drop database true|false"
    echo " Example of use: $0 database_name false"
    exit 1
fi

database_name=$1
drop_database=$2

#For example: 00_20180903_000_consents.json
#00_20180903_000_ --> 16 chars
#.json --> 5 chars
prefix=17
extension=5


printf "${BLUE}Getting container /tmp/data folder...${NC} \n"
cd /tmp/data

#STEP 0
printf "${BLUE}Step 0: Checking database to be removed${NC} \n"
if [ "$drop_database" = true ] ; then
	printf "${RED}Database $database_name is going to be removed!!!${NC} \n"
	mongo $database_name --eval "db.dropDatabase()"
	printf "${RED}Database $database_name removed!!!${NC} \n"
else
	printf "${BLUE}$database_name not removed. Please check if you have import errors. \n"	
fi
printf "${BLUE}Step 0: Done${NC} \n\n\n"


#STEP 1
printf "${BLUE}Step 1: Import data files${NC} \n"
for f in *.json; 
do
	printf "${BLUE}\t Processing $f file...${NC} \n"
  	lenght=${#f}
 	collection_name=${f:prefix:lenght - prefix - extension} 
 	echo $collection_name
 	cmd="mongoimport --host localhost  --db $database_name --collection $collection_name --file $f --jsonArray"
 	$($cmd)
	printf "${BLUE}\t File $f processed.${NC} \n" 	
done