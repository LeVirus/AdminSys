#! /bin/bash

suprCron(){
	if [ $# -ne 1 ]
	then
		echo -1 # renvoie -1 en cas d'erreur argument
		exit
	fi
	cmpt=0
	while read lignee; do #verif si action pas deja presente
		cmpt=$(($cmpt+1))
		if [ $(echo "$lignee" | cut -f8 -d ' ') = $mem ]
		then
			sed "$cmpt d" -i "./memCron" # supr de l'ancienne ligne de commande
			break
		fi
	done < ./memCron # lecture texte
}

search(){ #fonction pour verifier si une action est deja presente
	if [ $# -ne 1 ]
	then
		echo -1 # renvoie -1 en cas d'erreur argument
		exit
	fi
	cmpt=0
	while read ligne; do #verif si action pas deja presente
		cmpt=$(($cmpt+1))
		if [ "$ligne" = $1 ]
		then
			echo $cmpt # renvoie le numero de la ligne si l'action est deja presente
			exit
			break
		fi
	done < ./actionsStock/actions.txt # lecture texte
	echo 0 # renvoie 0 si l'action n'est pas presente
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
		echo "'val' appliquer les modifications au crontab" 
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

	elif [ `echo $recept | cut -d ' ' -f 1` = "add" ] || [ `echo $recept | cut -d ' ' -f 1` = "mod" ] # si 1er element="del si 1er element="add"
	then

		if [ `echo $recept | cut -d ' ' -f 1` = "add" ]
		then
			mem=$(echo $recept | cut -d ' ' -f 2) # 2eme element= nom action

			recept=$(search $mem)
			echo "rec  $recept"
			echo "deja:: $deja "
			if [ $recept -ne 0 ]
			then
				echo "action deja presente"
				echo "Annulation operation"
				deja=0
				continue
			fi

			if [ $deja -ne 1 ]
			then
				echo "nouvelle action..."
				echo "verif si action existe sur la toile..."
				sh recupVal.sh $mem testt
				if [ -f ./actionsStock/$mem ] #si le fichier a ete cree l'action existe sur le site
				then
					echo "action existante transfert"
					echo "$mem" >>./actionsStock/actions.txt # inserer action dans action.txt
					echo "1/24" >> ./actionsStock/actions.txt # inserer frequence standart
				fi
			fi
			deja=0
		fi


		#__________________________________________________fin add


		#elif [ `echo $recept | cut -d ' ' -f 1` = "mod" ] # si 1er element="del"
		#then	
		if [ `echo $recept | cut -d ' ' -f 1` = "mod" ]
		then
			mem=$(echo $recept | cut -d ' ' -f 2) # recup du nom de l'action
		fi
		recept=$(search $mem)
		echo "rece $recept"
		if [ $recept -ne 0 ] # si action trouvée
		then
			granted=0
			while [ $granted -eq 0 ]
			do
				echo "entrez frequence de rafraichissement heure (1-24) (24=1 fois par jour)"
				read heure
				if [ "$(echo $heure | grep "^[ [:digit:] ]*$")"  ] &&  [  $heure -lt 30 ] && [ $heure -gt 0 ]
				then
					granted=1
				else
					echo "entrer non valide"
				fi
			done
			granted=0
			while [ $granted -eq 0 ]
			do
				echo "entrez frequence de rafraichissement jour (1-30)"
				read jour
				if [ "$(echo $jour | grep "^[ [:digit:] ]*$")"  ] &&  [  $jour -lt 30 ] && [ $jour -gt 0 ] # verif si bonne fourchette
				then
					granted=1
				else
					echo "entrer non valide"
				fi
			done
 # verif si le fichier n'existe pas deja
 if [ ! -f "./memCron" ] #tmp
			then
				echo
			else
				echo "nouveau memCron"
				echo "$(crontab -l)" > ./memCron #ecrire le contenu du crontab dans un fichier
			fi
			suprCron $mem




			echo "0 */$heure */$jour * * sh $(pwd)/recupVal.sh $mem"  >> ./memCron # ajouter la commande au fichier
		else
			echo "action non reconnue"
		fi

		#__________________________________________________fin mod 


	elif [ `echo $recept | cut -d ' ' -f 1` = "del" ] # si 1er element="del"
	then	
		mem=$(echo $recept | cut -d ' ' -f 2)
		recept=$(search $mem)
		echo "rece $recept"
		if [ $recept -ne 0 ]
		then
			sed $recept,$(($recept+1))d -i actionsStock/actions.txt # supr des 2 lignes correspondantes a l'action

 if [ -f "./memCron" ] #tmp
			then
				echo
			else
				echo "nouveau memCron"
				echo "$(crontab -l)" > ./memCron #ecrire le contenu du crontab dans un fichier
			fi

			suprCron $mem
		else
			echo "action non reconnue"
		fi

		#__________________________________________________fin del 

	elif [ `echo $recept | cut -d ' ' -f 1` = "val" ]
	then
		if [ -f ./memCron ]
		then
			echo
		else
			echo "rien a mettre a jour"
			continue
		fi
		crontab memCron # appliquer la commande au crontab
rm memCron
	else 
		echo "erreur commande"
	fi
done
rm memCron
echo "fin prog"
exit
