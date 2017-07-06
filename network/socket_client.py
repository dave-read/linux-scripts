import socket
import sys
import os
import numpy
import pprint
import time

SERVER="10.0.0.20"
#SERVER="10.0.1.50"
PORT=5000
PID=str(os.getpid())

total_count=0
iteration_count=0
instanceInvokeCounts={}
message_string = "X" * 1024 

start_time=time.time()
while True:
  try:
    total_count += 1
    iteration_count += 1
    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Connect the socket to the port where the server is listening
    server_address = (SERVER, PORT)
    sock.connect(server_address)
    sock.sendall(PID+","+str(total_count)+","+message_string)
    data = sock.recv(1500)
    sock.close()
    #instance=data.split(",")[0]
    #instanceInvokeCounts[instance] = instanceInvokeCounts.get(instance, 0) + 1
    if total_count % 1000 == 0:
      elapsed_time=time.time()-start_time
      print "client_id:"+PID+" iteration count:"+str(iteration_count)+" last data size:"+str(len(data))+" elapsed seconds:"+str(elapsed_time)+" req/second:"+str(iteration_count/elapsed_time)
      sys.stdout.flush()
      #print "last result size:"+str(len(data))+" data:"+str(data)
      #x=numpy.bincount(instanceInvokeCounts.values())
      #x=numpy.histogram(instanceInvokeCounts.values())
      #pp = pprint.PrettyPrinter(indent=4)
      #pp.pprint(instanceInvokeCounts.values())
      #pp.pprint(x)
      #print x
      #instanceInvokeCounts={}
      iteration_count=0
      start_time=time.time()
      
  except Exception as e:
    print "error"+str(e) 
    continue
