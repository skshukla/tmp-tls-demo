
#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJ_DIR=/Users/sachin/work/workspaces/ws/tlsdemo

CERT_DIR=$PROJ_DIR/work/certs

rm -rf $PROJ_DIR/work/certs/*.*
rm -rf $PROJ_DIR/src/main/resources/*.jks
rm -rf $PROJ_DIR/src/main/resources/*.p12

# Generate Certs
#------------------------------------------------------
echo -e 'SG\nSG\nSG\nZMYORG\nZMYORGUNIT\napi-ca.skshukla.com\na@a.com' | openssl req -x509 -sha256 -days 3650 -newkey rsa:4096 -keyout $CERT_DIR/rootCA.key -out $CERT_DIR/rootCA.crt -passout pass:12345678

echo -e 'SG\nSG\nSG\nZMYORGS\nZMYORGUNITS\napi-server.skshukla.com\na@a.com\n12345678\n12345678' | openssl req -new -newkey rsa:4096 -keyout $CERT_DIR/server.key -out $CERT_DIR/server.csr -passout pass:12345678



echo 'authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = api-server.skshukla.com' > $CERT_DIR/server.ext

openssl x509 -req -CA $CERT_DIR/rootCA.crt -CAkey $CERT_DIR/rootCA.key -in $CERT_DIR/server.csr -out $CERT_DIR/server.crt -days 365 -CAcreateserial -extfile $CERT_DIR/server.ext -passin pass:12345678


#openssl x509 -in $CERT_DIR/server.crt -text


openssl pkcs12 -export -out $CERT_DIR/server.p12 -name "api-server.skshukla.com" -inkey $CERT_DIR/server.key -in $CERT_DIR/server.crt -passin pass:12345678 -password pass:12345678


echo -e '12345678\n12345678\n12345678' | keytool -importkeystore -srckeystore $CERT_DIR/server.p12 -srcstoretype PKCS12 -destkeystore $CERT_DIR/myserver_keystore.jks -deststoretype JKS




echo -e '12345678\n12345678' | keytool -import -trustcacerts -noprompt -alias ca -ext san=dns:api-server.skshukla.com,ip:127.0.0.1 -file $CERT_DIR/rootCA.crt -keystore $CERT_DIR/myserver_truststore.jks



# CLIENT
echo -e 'SG\nSG\nSG\nZMYORGC\nZMYORGUNITC\napi-client.skshukla.com\na@a.com\n12345678\n12345678' | openssl req -new -newkey rsa:4096 -keyout $CERT_DIR/client.key -out $CERT_DIR/client.csr -passout pass:12345678

openssl x509 -req -CA $CERT_DIR/rootCA.crt -CAkey $CERT_DIR/rootCA.key -in $CERT_DIR/client.csr -out $CERT_DIR/client.crt -days 365 -CAcreateserial -passin pass:12345678


openssl pkcs12 -export -out $CERT_DIR/client.p12 -name "client" -inkey $CERT_DIR/client.key -in $CERT_DIR/client.crt -passin pass:12345678 -password pass:12345678




cp -rf $CERT_DIR/*.jks $PROJ_DIR/src/main/resources
cp -rf $CERT_DIR/server.p12 $PROJ_DIR/src/main/resources