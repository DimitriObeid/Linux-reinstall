#!/bin/bash

SLEEP=sleep\ 2

one()
{
	echo "one"
	$SLEEP
}

two()
{
	pwd
	$SLEEP
}

three()
{
	ls
	$SLEEP
}

one
two
three
