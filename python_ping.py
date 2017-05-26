from multiprocessing import Queue
from threading import Lock,Thread,current_thread
from subprocess import call,STDOUT
import socket
import os
import platform

NBTHREADS = 40

domains = ['devops.ad.ypg.com','db.ad.ypg.com','itops.ad.ypg.com','intranet.ypg.com','ad.ypg.com','ypg.com','docs.voltdir.com','voltdir.com','docs.ypgapps.com','ypgapps.com','docs.ypgus.com','ypgus.com','mtl.tdpub.com','on.bell.ca','scr.tdpub.com','tdpub.com','tas.telus.com','tsl.telus.com','ypgngw.cwshs.com','iamdominion.com','test.local','yourcb-test.com','dom.ads','domdir.com']

def resolve(host):
    for d in domains:
        try:
            ip = socket.gethostbyname(host+"."+d)
            return (ip, d)
        except:
            pass
    return ('', None)

l = Lock()
q = Queue()

d = open('C:\\Users\\RBoudet1\\Desktop\\toPing.txt', 'r')
total = 0
for line in d:
    total += 1
    q.put(line.strip())
d.close()

done = 0

out = open('C:\\temp\\pinginscomp.csv', 'w')
out.write('name,domain,ip,ping,log-8081\n')
devnull = open(os.devnull, 'w');

def get_ver():
    global l,q,done
    name = current_thread().name
    file1 = open('C:\Users\Rboudet1\Desktop\pingable.txt', 'w')
    file2 = open('C:\Users\Rboudet1\Desktop\NotPingable.txt', 'w')
    while not q.empty():
        dev = q.get()
        ip, domain = resolve(dev)
        if len(ip) > 0:
            if platform.system().lower()=="windows":
                r = call(['ping', '-n', '1', ip], stdout=devnull, stderr=devnull)
            else:
                r = call(['ping', '-c', '1', ip], stdout=devnull, stderr=devnull)
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            try:
                s.connect((ip, 8081))
                s.shutdown(2)
                a = True
            except:
                a = False
        with l:
            done += 1
            pingable = "no"
            if len(ip) == 0:
                out.write('%s,,,N,N\n' % (dev,))
            else:
                out.write('%s,%s,%s,' % (dev, domain, ip))
                if r == 0:
                    out.write('Y,')
                    pingable = "yes"
                else:
                    out.write('N,')
                if a:
                    pingable = "yes"
                    out.write('Y\n')
                else:
                    out.write('N\n')
            print("{%s} [%d/%d] %s %s" % (name, done, total, dev, pingable))
            if(pingable == "yes"):
                file1.write(dev + '/n')
            else:
                file2.write(dev + '/n')
                
            
        #Sq.task_done()


for i in range(NBTHREADS):
    t = Thread(target=get_ver, name='t-%02d'%(i,))
    t.start()

q.join()
out.close()
devnull.close()
file1.close()
file2.close()
