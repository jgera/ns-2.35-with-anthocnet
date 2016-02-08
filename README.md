# ns-2.35-with-anthocnet
ns simulator with preinstalled anthocnet

# Requirement packages

See here http://askubuntu.com/questions/467901/segmentation-fault-core-dumped-in-ns2-ubuntu-14-04
```
sudo apt-get install tcl8.5-dev tk8.5-dev gcc-4.4 g++-4.4 build-essential autoconf automake perl xgraph libxt-dev libx11-dev libxmu-dev
```

Add this to RC file
```
PATH=$PATH:/home/isysway/ns-allinone-2.35/bin:/home/wh1/workspace/ns-2.35-with-anthocnet/tcl8.5.15/unix:/home/wh1/workspace/ns-2.35-with-anthocnet/tk8.5.10/unix
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/wh1/workspace/ns-2.35-with-anthocnet/otcl-1.14:/home/wh1/workspace/ns-2.35-with-anthocnet/lib
TCL_LIBRARY=$TCL_LIBRARY:/home/wh1/workspace/ns-2.35-with-anthocnet/tcl8.5.15/library
export PATH
export LD_LIBRARY_PATH
export TCL_LIBRARY
```
