#! /bin/bash

search(){ #fonction pour verifier si une action est deja presente
	if [ $# -ne 1 ]
	then
		echo -1
			exit
	fi
	cmpt=0
	while read ligne; do #verif si action pas deja presente
		cmpt=$(($cmpt+1))
		if [ "$ligne" = $1 ]
		then
			echo $cmpt
			exit
			break
		fi
	done < ./actionsStock/actions.txt # lecture texte
			echo 0

}

a=1
recept=""
q="q"
tmp=""
ligne=""
mem=""
deja=0
while [ $a -ne 0 ] #boucle principale
do
	echo "entrez commande h pour aide ."
	read recept


	#if [ `echo $recept | cut -d ' ' -f 3` != "" ] # si la commande a plus d'un espace continue
	#then
	#	echo "erreur commande"
	#	continue
	#fi

	if [ "$recept" = "h" ] #affiche la liste des commande possible
	then
		echo "'add [nom action]' ajouter une action"	
		echo "'del [nom action]' suprimmer une action"	
		echo "'mod [nom action]' modifier frequence de recuperation"
		echo "'ls' afficher les actions ainsi que leurs frequences de recuperation de valeur"

		#__________________________________________________fin h

	elif [ "$recept" = "ls" ] # afficher fichier actions
	then	
		cat ./actionsStock/actions.txt

		#__________________________________________________fin ls

	elif [ "$recept" = "q" ] # quitter le programme
	then	
		a=0

		#__________________________________________________fin q

	elif [ `echo $recept | cut -d ' ' -f 1` = "add" ] # si 1er element="add"
	then
		mem=$(echo $recept | cut -d ' ' -f 2) # 2eme element= nom action

		recept=$(search $mem)
	echo "rec  $recept"
	echo "res  "
if [ $recept -ne 0 ]
then
			echo "action deja presente"
			echo "Annulation operation"
				deja=1
	#continue
fi

		echo "verification terminee avec succes"
		if [ $deja -ne 1   ] # si le nom de l'action est deja dans la liste
		then
			echo "transfert"
			echo "$mem" >>./actionsStock/actions.txt # inserer action dans action.txt
			echo "1/24" >> ./actionsStock/actions.txt # inserer frequence standart
		else deja=0
		fi
		#__________________________________________________fin add

	elif [ `echo $recept | cut -d ' ' -f 1` = "del" ] # si 1er element="del"
	then	
		mem=$(echo $recept | cut -d ' ' -f 2)
		recept=$(search $mem)
		echo "rece $recept"
		if [ $recept -ne 0 ]
		then
sed $recept,$(($recept+1))d -i actionsStock/actions.txt
		fi

		#__________________________________________________fin del 


	else 
		echo "erreur commande"
	fi
done
echo "fin prog"
exit


