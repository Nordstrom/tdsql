curl -x webproxy.nordstrom.net:80 -v -o tdsql.zip https://codeload.github.com/Nordstrom/tdsql/zip/master
unzip -o tdsql.zip
mv tdsql-master/* .
rm -Rf tdsql-master
rm tdsql.zip