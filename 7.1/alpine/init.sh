#!/bin/sh
SOLR_HOME_TEMPLATE="/opt/solr/server/solr"
DEFAULT_SOLR_DATA_HOME="/solr_data_home"
DEFAULT_SOLR_HOME="/solr_home"

function init_app() {
	echo "Solr initialisation"
	if [ -z "$SOLR_HOME" ]; then
		export SOLR_HOME=$DEFAULT_SOLR_DATA_HOME
	fi
	
	if [ -e "$SOLR_HOME/solr.xml" ]; then
		echo "Found existing Solr home at ${SOLR_HOME}, not touching it"
	else
		init_solr_home
	fi
	
	#TODO: Solr data
}

function init_solr_home() {
	if [ ! -e "${SOLR_HOME}/solr.xml" ]; then
		#Solr home does not yet exist, try to import
		echo "Solr home directory $SOLR_HOME does not exist or is empty"
		import_solr_home
	fi
	
	if [ ! -e "${SOLR_HOME}/solr.xml" ]; then
		echo "No solr home content was imported"
		init_solr_home_from_template
	fi
}

function import_solr_home() {
	if [ -d "/docker-entrypoint-initsolr.d/solr_home" ]; then
		echo "Found a Solr home to import"
		purge_solr_home
		cp -r "/docker-entrypoint-initsolr.d/solr_home"/* "$SOLR_HOME"
		chown -R $SOLR_USER:$SOLR_GROUP "$SOLR_HOME"
		echo "Initialised Solr home in ${SOLR_HOME}"
	fi
}

function init_solr_home_from_template() {
	if [ "$SOLR_HOME" != "$SOLR_HOME_TEMPLATE" ]; then
		echo "Initialising Solr home with default Solr home content"
		purge_solr_home
		cp -r "${SOLR_HOME_TEMPLATE}"/* "$SOLR_HOME"
		chown -R $SOLR_USER:$SOLR_GROUP "$SOLR_HOME"
		echo "Initialised Solr home in ${SOLR_HOME}"
	fi
}

function purge_solr_home() {
	if [ -d "$SOLR_HOME" ]; then
		echo "Removing original Solr home content at ${SOLR_HOME}"
		rm -rf "${SOLR_HOME}"/*
	else
		mkdir -p "$SOLR_HOME"
	fi
}

init_app
