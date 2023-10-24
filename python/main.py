#!/usr/bin/python3
# 文件名：server.py

# 导入 socket、sys 模块
import socket
import sys
import time 
import numpy as np 
# 创建 socket 对象
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 获取本地主机名
host = socket.gethostname()
ip   = socket.gethostbyname(host)
port = 31415
print('host:',host,'\nip  :', ip,'\nport:',port)

# 绑定端口号
serversocket.bind((host, port))

# 设置最大连接数，超过后排队
serversocket.listen(1)

# 用于接收的数组
state = np.ones(4,dtype=np.float32)
buf = np.zeros(0,  np.byte)

def read_state(socket, dest, buf):
    '''
    从fortran接收数组,如果传过来的是字符串直接socket.recv(1024).decode()
    '''
    blen = dest.itemsize * dest.size
    if (blen > len(buf)):
        buf.resize(blen,refcheck=False)
    bpos = 0

    while bpos < blen:
        timeout = False
        # post-2.5 version: slightly more compact for modern python versions
        try:
            bpart = 1
            bpart = socket.recv_into(buf[bpos:], blen - bpos)
        except socket.timeout:
            print(" @SOCKET:   Timeout in status recvall, trying again!")
            timeout = True
            pass
        bpos += bpart

    if np.isscalar(dest):
        return np.fromstring(buf[0:blen], dest.dtype)[0]
    else:
        return np.fromstring(buf[0:blen], dest.dtype).reshape(dest.shape, order='F')

# 建立客户端连接
clientsocket, addr = serversocket.accept()
print("Connection address: %s" % str(addr))

i = 0
while True:
    state = read_state(clientsocket,state,buf)  #用于接收数组
    #msg = clientsocket.recv(1024).decode() # 用于接收字符串
    print('stats received    :', i, state)
    i += 1
    # 根据接收的state，给出action
    action = state + 1
    print('action transmitted:', i, action)

    clientsocket.sendall(action.flatten(order='F'))
    #clientsocket.close()