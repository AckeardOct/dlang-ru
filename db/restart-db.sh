#!/bin/bash

echo "You need mongod and mongo-tools"

killall -9 mongod
rm -rf ./mongo-db
mkdir ./mongo-db

nohup mongod --dbpath ./mongo-db &

sleep 1
echo "ONE"
sleep 1
echo "TWO"
sleep 1
echo "THREE"
sleep 1
echo "FOUR"
sleep 1
echo "FIVE!"

echo "########################"
echo "Creating Admin user"
mongoimport -d server -c users --file ./minimal-base/user.json