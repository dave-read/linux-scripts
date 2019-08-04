FROM ubuntu:16.04

RUN apt update
RUN apt install netcat-openbsd net-tools python2.7 iproute2 -y 
RUN ln -s /usr/bin/python2.7 /usr/bin/python

WORKDIR /app
#COPY udp_server /app
COPY socket_server /app

#CMD ["/app/udp_server"]
CMD ["/app/socket_server"]

