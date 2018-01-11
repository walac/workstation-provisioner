#!/bin/bash -e

openssl enc -e -aes-256-cbc -in $1 -out $1.enc -kfile passphrase.txt
