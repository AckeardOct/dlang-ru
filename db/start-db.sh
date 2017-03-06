#!/bin/bash

echo "You need mongod and mongo-tools"

killall -9 mongod

nohup mongod --rest --dbpath ./mongo-db &

echo "You can work!"
