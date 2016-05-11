#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root" 
   echo "USAGE: sudo bash upgrade_art.sh -p OLD_ARTIFACTORY_HOME"
   exit 1
fi

echo "IMPORTANT NOTES:
1. This upgrade script is only for SA installation
2. We highly recommend performing a full system export before the upgrade

Would you like to proceed?"

 select yn in "Yes" "No"; do
    case $yn in
        Yes ) NOTICE=true; echo "y"; break;;
        No ) NOTICE=false; echo "n"; break;;
    esac
done

if [ "$NOTICE" = true ] ; then
  echo "Deploying new version"
else
  echo "Stopping upgrade process"
  exit 1
fi

parse_options() {
    while getopts "w:s:S:v:c:ChRdVunfrEGi:p:P" opt; do
	   case $opt in
        p)
          ARTIFACTORY_HOME=$OPTARG
          ;;
        :)
          echo "ERROR: Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
      esac
    done
}
 
parse_options $@

if [ -z "$ARTIFACTORY_HOME" ]; then
    echo "Please specify your OLD_ARTIFACTORY_HOME using -p"
    echo "Usage: bash upgrade_ver.sh -p OLD_ARTIFACTORY_HOME"
    exit 1
fi

SERVERXML="$ARTIFACTORY_HOME/server.xml"
WEBAPPS_ART="$ARTIFACTORY_HOME/webapps/artifactory.war"
TOMCAT_DIR="$ARTIFACTORY_HOME/tomcat"
BIN_DIR="$ARTIFACTORY_HOME/bin"
NEW_VER_DIR="$(pwd)/"

if [[ (! -f $NEW_VER_DIR/README.txt) || (! -d $NEW_VER_DIR/webapps) || (! -d $NEW_VER_DIR/bin) || (! -d $NEW_VER_DIR/etc) ]]; then
  echo "ERROR: Please run the upgrade script from the new package folder"
  exit 1
fi

echo "Using $ARTIFACTORY_HOME as ARTIFACTORY_HOME"

cp "$SERVERXML" "/tmp"
echo "Copied server.xml to a temporary location"

echo "Start detleting old version"
rm "$WEBAPPS_ART"
echo "Deleted $WEBAPPS_ART"

rm -r "$TOMCAT_DIR"
echo "Deleted $TOMCAT_DIR" 

rm -r "$BIN_DIR"
echo "Deleted $BIN_DIR"

echo "Start copying new version"
cp -R "$NEW_VER_DIR/bin" "$ARTIFACTORY_HOME"
echo "Copied $NEW_VER_DIR/bin to $ARTIFACTORY_HOME"

cp -R "$NEW_VER_DIR/tomcat" "$ARTIFACTORY_HOME"
echo "Copied $NEW_VER_DIR/tomcat to $ARTIFACTORY_HOME"

cp "$NEW_VER_DIR/webapps/artifactory.war" "$ARTIFACTORY_HOME/webapps"
echo "Copied $NEW_VER_DIR/webapps/artifactory.war to $ARTIFACTORY_HOME/webapps"

cp "/tmp/server.xml" "$SERVERXML"
echo "Copied server.xml back to $ARTIFACTORY_HOME"

sh "$ARTIFACTORY_HOME/bin/artifactory.sh"
  echo "New artifactory is up and running"
fi
