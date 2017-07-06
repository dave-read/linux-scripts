
import sys
import socket
from time import sleep

if  len(sys.argv) != 3:
    print "usage listen_host listen_port"
    exit(1)

HOST = sys.argv[1]
PORT = int(sys.argv[2])
MAX_RECV=1500

HOST_PORT=HOST+","+str(PORT)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    s.bind((HOST,PORT))
except socket.error as msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit(1)

s.listen(0) # only one request at a time
print "listening on:"+HOST_PORT 
counter=0
while True:
    counter += 1
    conn, addr = s.accept()
    data = conn.recv(MAX_RECV)
    if not data:
      print "No data for count:"+str(counter)+" on:"+HOST_PORT
      continue
    #sleep(0.1)    
    conn.sendall(HOST+","+str(counter)+","+data)
    conn.close()
s.close()
