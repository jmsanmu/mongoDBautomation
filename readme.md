--------------------------
-MONGO DB SETUP SH SCRIPT-
--------------------------

+ Usage:	
	Param 1: project name 
	Param 2: mongo host port 
	Param 3: mongo docker port 
	Param 4: Database name 
	Param 5: Drop database true|false (Not used if param 6 is set to false)
	Param 6: Run import true|false 
    Example of use: setup.sh insereg 27017 27017 devong4gdpr false false


+ Data directory
	- Put your database json files to import in this folder.
	- The filename must follow this pattern:
		
		XXX_YYYYMMDD_ZZZ_COLLECTIONNAME.json


		--> XXX: Number of script
		--> YYYYMMDD: YYYY Year in 4 digits | MM Month in 2 digits | DD Day in 2 digits
		--> ZZZ: Order of script having the same day mask.


+ Possible problems
	- Do not use if you have windows 7 on your machine.
	- If docker can not download mongo image, log out dockerhub and log in again.	


