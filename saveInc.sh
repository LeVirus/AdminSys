#! /bin/bash


FICHIER_STATUS=/etc/save.state

if [ -f ./SAVE/save.tar.gz ]
then
	#save incrementale
	find ./grapheStock/ -newer ./SAVE/save.tar.gz | tar -cvzf ./SAVE/save$(DATE).tar.gz
else
	# save complete si premiere fois
	tar -cvzf ./SAVE/save$(DATE).tar.gz ./grapheStock/
fi

