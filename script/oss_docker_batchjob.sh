#!/bin/bash

while :
do
    /bin/bash -lc 'cd /opt/application/current ; bin/rails runner -e production "require \"./lib/slide_hub/batch\"; SlideHub::Batch.execute"'
    sleep 60
done
