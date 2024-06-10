cat star_zesco_co_zm.crt DigiCertCA.crt > certificate_chain.crt

openssl x509 -in mycert.crt -out mycert.pem -outform PEM

openssl x509 -in certificate_chain.crt -out certificate_chain.pem -outform PEM

