#! /bin/bash

a=1
recept=""
q="q"
tmp=""
ligne=""
mem=""
while [ $a -ne 0 ]
do
deja=0
	echo "entrez commande h pour aide ."
	read recept


	#if [ `echo $recept | cut -d ' ' -f 3` != "" ] # si la commande a plus d'un espace continue
	#then
	#	echo "erreur commande"
	#	continue
	#fi

	if [ "$recept" = "h" ] #affiche la liste des commande possible
	then
		echo "add [nom action] ajouter une action"	
		echo "del [nom action] suprimmer une action"	
		echo "mod [nom action] modifier frequence de recuperation"	

		#__________________________________________________fin h

	elif [ "$recept" = "ls" ] # afficher fichier actions
	then	
		cat ./actionsStock/actions.txt

		#__________________________________________________fin ls

	elif [ "$recept" = "q" ] # quitter le programme
	then	
		a=0

		#__________________________________________________fin add

	elif [ `echo $recept | cut -d ' ' -f 1` = "add" ] # si 1er element="add"
	then
		mem=$(echo $recept | cut -d ' ' -f 2)

		echo "mem"
		echo "$mem"
		echo "sdd"


		while read ligne; do #verif si action pas deja presente
			echo "$ligne"
			if [ "$ligne" = "$mem" ]
			then
				echo "deja present"
				deja=1
				break
			fi
		done < ./actionsStock/actions.txt # lecture texte

		echo "fin boucle verif"
		if [ $deja -ne 1   ] # si le nom de l'action est deja dans la liste
		then
			echo "transfert"
			echo "$mem" >>./actionsStock/actions.txt # inserer action dans action.txt
			echo "1/24" >> ./actionsStock/actions.txt # inserer frequence standart
		fi
		#__________________________________________________fin add

	elif [ `echo $recept | cut -d ' ' -f 1` = "del" ] # si 1er element="del"
	then	
		mem=$(echo $recept | cut -d ' ' -f 2)
		echo "modifier frequence de recuperation"	
		sed '1,2d' ./actionsStock/actions.txt

		#__________________________________________________fin del 


	else 
		echo "erreur commande"
	fi
done
echo "fin prog"
exit
