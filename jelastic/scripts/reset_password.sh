#!/bin/bash

. /etc/jelastic/environment

SED=$(which sed);

function _setPassword() {
	sed -i '/password_change_required/d' /opt/repo/versions/${Version}/neo4j-${Version}/data/dbms/auth;
	generateAuthString $J_OPENSHIFT_APP_ADM_USER $J_OPENSHIFT_APP_ADM_PASSWORD;
    	service cartridge restart;
}

function generateAuthString() {
	UNAME="$1"
	PASS="$2"

	# representing the password in hex format like \xAB\x0C etc
	# HEX_PASS=$(echo -n $PASS | xxd -p | awk '{print toupper($1);}' | sed -r 's/(.{2})/\\x\1/g')
	HEX_PASS=$(echo -n $PASS | hexdump -v -e '"\\\x" 1/1 "%02X"')

	# create the salt and store it in hex format
	SALT=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
	HEX_SALT=$(echo -n $SALT | sed -r 's/(.{2})/\\x\1/g')

	# calculate the sha256 sum of the salt and password value
	# need to split the output because the output ends with a hyphen
	IFS=' '
	read -a PASSWORD_HASH_ARRAY <<< $(printf $HEX_SALT$HEX_PASS | sha256sum)
	PASSWORD_HASH="${PASSWORD_HASH_ARRAY[0]}"

	COMBINED=$(echo -n "$PASSWORD_HASH,$SALT" | awk '{print toupper($1);}')
	sed -i "/^$J_OPENSHIFT_APP_ADM_USER:SHA-256/d" /opt/repo/versions/${Version}/neo4j-${Version}/data/dbms/auth 
	echo "$UNAME:SHA-256,$COMBINED:" >> /opt/repo/versions/${Version}/neo4j-${Version}/data/dbms/auth 
}
