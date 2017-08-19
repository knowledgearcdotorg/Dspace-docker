#!/bin/bash

psql -h postgres -p 5432 --username=postgres dspace -c "CREATE EXTENSION pgcrypto;"

/opt/apache-tomcat-9.0.0.M26/bin/catalina.sh