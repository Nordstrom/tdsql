#!/bin/bash
tdsql -c "select top 10 * from non_existent_table" --stdouterr  > /dev/null
OUT=$?
if [ $OUT -eq 0 ];then
   echo "tdsql success"
else
   echo "tdsql error"
fi