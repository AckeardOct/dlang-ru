#!/bin/bash

#start postfix
sudo docker run -d -p 25:25 -e POSTFIX_myhostname=dlang.ru mwader/postfix-relay

#start mongo
sudo docker run -d -p 27017:27017 mongo

echo "You can work! Mongo and Postfix is loaded!"