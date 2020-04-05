#!/bin/bash
(cd ./svr-master1 && vagrant up)
(cd ./svr-worker1 && vagrant up)
(cd ./svr-worker2 && vagrant up)