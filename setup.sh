#!/bin/bash
#Bash colors
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

projectName=$1 
docker_port=$2
host_port=$3
database_name=$4
drop_database=$5
run_import=$6

#Usage
if [ ! $6 ]; then
	printf  " ${RED}Please add the following command params: ${NC} \n"
	printf  " ${GREEN}Param 0: $0 ${NC} \n"
	printf  " ${GREEN}Param 1: project name ${NC} \n"
	printf  " ${GREEN}Param 2: mongo host port ${NC} \n"
	printf  " ${GREEN}Param 3: mongo docker port ${NC} \n"
	printf  " ${GREEN}Param 4: Database name ${NC} \n"
	printf  " ${GREEN}Param 5: Drop database true|false ${NC} \n"
	printf  " ${GREEN}Param 6: Run import true|false ${NC} \n"
    printf  " ${GREEN}Example of use: setup.sh insereg 27017 27017 devong4gdpr false false ${NC} \n"
    sleep 5
    exit 1
fi

dockerps=$(docker ps)

#STEP 0
printf "${GREEN}Checking docker service is alive...${NC} \n"
if [ -z "$dockerps" ]
then
  printf "${RED}Docker NOT running${NC} \n"
  printf "${RED}Please install docker or start the docker daemon.${NC} \n"
  sleep 5
  exit 1		
else
	printf "${GREEN}Docker running!!!${NC} \n"	
fi

printf "${GREEN}Removing temporary files...${NC} \n"
if [ -f data.tar.gz ]; then
  rm data.tar.gz
  printf "${GREEN}Removed data.tar.gz file${NC} \n"
fi
printf "${GREEN}Done${NC} \n\n\n"


#STEP 1
printf "${GREEN}Docker management${NC} \n"
container_id=$(docker ps -aqf "name=mongodb_$projectName")

if [ -z "$container_id" ]
then
	printf "${GREEN}Creating new mongo container for project $projectName...${NC} \n"
	cmd="docker run -it -d -p $docker_port:$host_port --name mongodb_$projectName mongo"	
	container_run=$($cmd)
	container_id=$(docker ps -aqf "name=mongodb_$projectName")
	printf "${GREEN}Data container mongoId: $container_id ${NC} \n"		
	printf "${GREEN}Container created: $container_run ${NC} \n"	
else
	printf "${GREEN}Mongo container already exists.: $container_id ${NC} \n"	
	printf "${GREEN}Starting container $container_id... ${NC} \n"	
	docker container start $container_id
	printf "${GREEN}Docker container $container_id started ${NC} \n"	
fi
printf "${GREEN}Done${NC} \n\n\n"
sleep 3
if [ "$run_import" = false ] ; then
	exit 1
fi


#STEP 2
printf "${GREEN}Compressing data directory to data.tar.gz${NC} \n"
tar -zcvf data.tar.gz data
printf "${GREEN}Done${NC} \n\n\n"

#STEP 3
printf "${GREEN}Deleting old data files in container $container_id  ${NC} \n"
docker exec mongodb_$projectName sh -c "rm -r /tmp/data && rm /tmp/data.tar.gz"
printf "${GREEN}Done${NC} \n\n\n"

printf "${GREEN}Copying data to container $container_id  ${NC} \n"
cmd="docker cp data.tar.gz mongodb_$projectName:/tmp/data.tar.gz"
echo $cmd
container_run=$($cmd)
printf "${GREEN}Done${NC} \n\n\n"


#STEP 4
printf "${GREEN}Decomprnesing data inside docker container...  ${NC} \n"
docker exec mongodb_$projectName sh -c "cd /tmp && tar -xvzf data.tar.gz"
printf "${GREEN}Done${NC} \n\n\n"


#STEP 5
printf "${GREEN}Setting Script grants and running mongo actions ${NC}  \n"
docker exec mongodb_$projectName sh -c "cd /tmp/data && sed -i -e 's/\r$//' create.sh"
docker exec mongodb_$projectName sh -c "cd /tmp/data && chmod +x create.sh"
docker exec mongodb_$projectName sh -c "cd /tmp/data && ./create.sh $database_name $drop_database"
printf "${GREEN}Done${NC} \n\n\n"

#STEP 6
printf "${GREEN}Removing temporary files...${NC} \n"
if [ -f data.tar.gz ]; then
  rm data.tar.gz
  printf "${GREEN}Removed data.tar.gz file${NC} \n"
fi
printf "${GREEN}Done${NC} \n\n\n"

sleep 5
exit 0