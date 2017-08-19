#!/bin/bash

cd /opt/dspace-6.1-src-release/dspace/target/dspace-installer

psql -h postgres -p 5432 --username=postgres dspace -c "CREATE EXTENSION pgcrypto;"

ant fresh_install

/opt/apache-tomcat-9.0.0.M26/bin/catalina.sh