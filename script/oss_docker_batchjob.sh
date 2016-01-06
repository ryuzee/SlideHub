#!/bin/bash

while :
do
    /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bin/rails runner -e production Batch.execute'
    sleep 60
done
