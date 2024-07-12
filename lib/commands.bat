# Convert a crt certifcate to pem
openssl x509 -in mycert.crt -out mycert.pem -outform PEM

rtpengine --table=0 --interface=10.43.0.55 --listen-http  2224\
  --listen-udp=10.43.0.55:22222 --listen-ng=10.43.0.55:2223 --tos=184 \
  --pidfile=/run/rtpengine.pid