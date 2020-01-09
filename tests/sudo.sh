#!/bin/bash

echo $SUDO_USER
whoami

echo ""
echo ""
echo ""
echo ""

if [ $SUDO_USER ]; then 
    user=$SUDO_USER 
else 
    user=`whoami`
fi
echo $user

echo ""
echo ""
echo ""
echo ""

[ $SUDO_USER ] && user2=$SUDO_USER || user2=`whoami`
echo $user2