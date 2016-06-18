#!/bin/bash 

. /etc/jelastic/environment

SED=$(which sed);

NEO4J_WRAPPER_PROP_FILE="${OPENSHIFT_NEO4J_DIR}/versions/${Version}/neo4j-${Version}/conf/neo4j-wrapper.conf";

[ -e ${OPENSHIFT_NEO4J_DIR}/versions/${Version}/neo4j-${Version}/bin/variablesparser.sh ] && . ${OPENSHIFT_NEO4J_DIR}/versions/${Version}/neo4j-${Version}/bin/variablesparser.sh;

$SED -i "s/^#dbms.memory.heap.initial_size/dbms.memory.heap.initial_size/g" $NEO4J_WRAPPER_PROP_FILE;
$SED -i "s/^dbms.memory.heap.initial_size=.*/dbms.memory.heap.initial_size=32/" $NEO4J_WRAPPER_PROP_FILE;

$SED -i "s/^#dbms.memory.heap.max_size/dbms.memory.heap.max_size/g" $NEO4J_WRAPPER_PROP_FILE;
$SED -i "s/^dbms.memory.heap.max_size=.*/dbms.memory.heap.max_size=${XMX_VALUE}/" $NEO4J_WRAPPER_PROP_FILE;
