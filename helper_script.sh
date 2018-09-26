#this helper script --
	#creates the base docker image
	#creates the application image for a particular sample
	#runs the sample
	#Command to Execute this script - 
	#sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip <optional - sample app name> <optional - sample app arguments>

#Docker clean-up commands
#=========================

#docker system prune
docker stop $(docker ps -q -a)

#Build Base Image
#=========================

if [[ $# -lt 1 ]]; then
    echo "Usage: ./helper_script.sh <path/to/bwce-runtime-2.4.0.zip> <optional - sample_application_name> <optional - sample application arguments>"
    printf "\t %s \t\t %s \n\t\t\t\t %s \n" "Location of runtime zip (bwce-runtime-<version>.zip)"
	printf "\t %s \t\t %s \n\t\t\t\t %s \n" "Optional Argument - Sample application to run; for example - rest, http, jms"
    exit 1
fi
zipLocation=$1

#./createDockerImage.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip
./createDockerImage.sh $zipLocation


if [ -z "$2"  ]; then
	cd examples/HTTP
	docker build -t bwce-http-app-nano .
	docker run -it -P -e BW_LOGLEVEL=ERROR -e MESSAGE='Welcome to BWCE 2.0 !!!' bwce-http-app-nano
fi

sampleApplication=$2

#HTTP Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip http
if [ "$sampleApplication" = "http" ]; then
	cd examples/HTTP
	docker build -t bwce-http-app-nano .
	docker run -it -P -e BW_LOGLEVEL=ERROR -e MESSAGE='Welcome to BWCE 2.0 !!!' bwce-http-app-nano
fi

#REST Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip rest
if [ "$sampleApplication" = "rest" ]; then
	cd examples/REST
	docker build -t bwce-rest-app-nano .
	docker run -it -P -e BW_LOGLEVEL=error bwce-rest-app-nano
fi

#JMS Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip jms tcp://13.56.67.132:7222
if [ "$sampleApplication" = "jms" ]; then
	url=$3
	echo $url
	cd examples/JMS
	docker build -t bwce-jms-app-nano .
	#docker run -ti -e EMS_URL="tcp://13.56.67.132:7222" -e EMS_QUEUE="jmsbasic.queue" -e REPLY_QUEUE="reply.queue" -e BW_PROFILE="docker" bwce-jms-app-nano
	docker run -ti -e EMS_URL=$url -e EMS_QUEUE="jmsbasic.queue" -e REPLY_QUEUE="reply.queue" -e BW_PROFILE="docker" bwce-jms-app-nano
fi

#Hystrix Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip hystrix
if [ "$sampleApplication" = "hystrix" ]; then
	cd examples/Hystrix
	docker build -t bwce-hystrix-app-nano .
	docker run -i -p 8081:8081 -p 8090:8090 -e BW_PROFILE="docker" -e COMMAND_NAME=WikiNews-Service -e BW_LOGLEVEL=info bwce-hystrix-app-nano
fi

#JMS with Consul Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip consul-jms http://13.57.245.44:8500/
if [ "$sampleApplication" = "consul-jms" ]; then
	url=$3
	cd examples/consul/client
	docker build -t bwce-consul-sd-client-nano .
	cd c:/bwce/bwce-docker/examples/consul/server
	docker build -t bwce-consul-sd-server-nano .
	#docker run -d -e CONSUL_SERVER_URL=http://13.57.245.44:8500/ -p 18087:8080 -e SERVICE_NAME=BWCE-HELLOWORLD-SERVICE bwce-consul-sd-server-nano:latest
	#docker run -d -e CONSUL_SERVER_URL=http://13.57.245.44:8500/ -p 18086:8080 -e SERVICE_NAME=BWCE-HELLOWORLD-SERVICE bwce-consul-sd-client-nano:latest
	docker run -d -e CONSUL_SERVER_URL=$url -p 18087:8080 -e SERVICE_NAME=BWCE-HELLOWORLD-SERVICE bwce-consul-sd-server-nano:latest
	docker run -d -e CONSUL_SERVER_URL=$url -p 18086:8080 -e SERVICE_NAME=BWCE-HELLOWORLD-SERVICE bwce-consul-sd-client-nano:latest
fi


#RestBookstore(JDBC) Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip jdbc http://13.57.245.44:8500/ nitish123 nitish456
if [ "$sampleApplication" = "jdbc" ]; then
	
	db_url=$3
	db_username=$4
	db_password=$5
	
	cd examples/JDBC
	docker build -t bwce-jdbc-app-nano .
	#docker run -p 8080:8080 -e BW_LOGLEVEL=DEBUG bwce-jdbc-app-nano [use this if vales are hardcoded in the applicatiopn/module properties]
	docker run -p 8080:8080 -e BW_LOGLEVEL=DEBUG -e DB_URL=$db_url -e DB_USERNAME=$db_username -e DB_PASSWORD=$db_password bwce-jdbc-app-nano
fi

#OData Sample Commands
#=========================

#Example Command: sh helper_script.sh ~/Desktop/nitish-files-backup/2.4.0/bwce-runtime-2.4.0.zip odata
if [ "$sampleApplication" = "odata" ]; then
	cd examples/OData
	docker build -t bwce-odata-app-nano .
	winpty docker run -it -p 8080:8080 -e BW_LOGLEVEL=DEBUG bwce-odata-app-nano
fi

