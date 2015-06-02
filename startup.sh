#!/bin/sh
# *************************************************************************

echo "Change hostname in the listener.ora"
dbhost=`uname -n`
sed -i "/(ADDRESS = (PROTOCOL = TCP)(HOST/c\      (ADDRESS = (PROTOCOL = TCP)(HOST = ${dbhost} )(PORT = 1521))" /oracle/product/11.2/db/network/admin/listener.ora

echo "Start the listener and database"
service dbora start