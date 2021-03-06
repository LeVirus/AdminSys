#! /bin/bash

suprCron(){
	if [ $# -ne 1 ]
	then
		echo -1 # renvoie -1 en cas d'erreur argument
		exit
	fi
	cmpt=0
	if [ ! -f ./memCron ]
	then
		echo "nouveau crontab"
		$(crontab -l) > ./memCron
	fi
	while read lignee; do #verif si action pas deja presente
		cmpt=$(($cmpt+1))
		if [ "$lignee" != "" ] && [ $(echo "$lignee" | cut -f8 -d ' ') = $1 ]
		then
			sed "$cmpt d" -i "./memCron" # supr de l'ancienne ligne de commande
			break
		fi
	done < ./memCron # lecture texte
}

a=1
recept=""
q="q"
tmp=""
ligne=""
mem=""
deja=0

if [ ! -f ~/.config/memPath ]
then
echo "create fic"
	echo "$(pwd)" > ~/.config/memPath # memo chemin pour cron
fi

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
		echo "'h' afficher ce menu."	
		echo "'add [nom action]' ajouter une action"	
		echo "'del [nom action]' suprimmer une action"	
		echo "'mod [nom action]' modifier frequence de recuperation"
		echo "'val' appliquer les modifications au crontab" 
		echo "'rmall' suprimmer toutes les actions presentes (sur crontab et dans les parametre)"
		echo "'ls' afficher les actions ainsi que leurs frequences de recuperation de valeur"

		#__________________________________________________fin h

	elif [ "$recept" = "ls" ] # afficher fichier actions
	then	
		echo "contenu fichier"
		ls ./actionsStock
		echo "crontab:: $(crontab -l)"
		#__________________________________________________fin ls

	elif [ "$recept" = "rmall" ] # afficher fichier actions
	then	
		echo "supression de toutes les actions..."
		if [ ! -f ./memCron ] # si memCron n'existe pas recup de crontab -l
		then
			crontab -l > ./memCron
		fi
		for i in $(ls ./actionsStock/)
		do
			echo "$i"
			suprCron $i
		done
		crontab memCron
		rm ./memCron
			rm ./actionsStock/*
			rm -R ./grapheStock/*
		rm ./frequencesStock/*
		#__________________________________________________fin rmall

	elif [ "$recept" = "q" ] # quitter le programme
	then	
		if [ -f ./memCron ] # si fichier memCron existe les modifs n'ont pas ete validees
		then
			echo "mis a jour crontab"
			crontab memCron
		fi
		a=0

		#__________________________________________________fin q

	elif [ `echo $recept | cut -d ' ' -f 1` = "add" ] || [ `echo $recept | cut -d ' ' -f 1` = "mod" ] # si 1er element="del si 1er element="add"
	then

		if [ `echo $recept | cut -d ' ' -f 1` = "add" ]
		then
			mem=$(echo $recept | cut -d ' ' -f 2) # 2eme element= nom action

			if [ -f ./frequencesStock/$mem ]
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
					#echo "$mem" >>./frequencesStock/actions.txt # inserer action dans action.txt
					#echo "1/24" >> ./frequencesStock/actions.txt # inserer frequence standart
				fi
			fi
			deja=0
		fi


		#__________________________________________________fin add


		if [ `echo $recept | cut -d ' ' -f 1` = "mod" ]
		then
			mem=$(echo $recept | cut -d ' ' -f 2) # recup du nom de l'action
		fi
		if [ -f ./actionsStock/$mem ] # si action trouvée
		then
			granted=0
			while [ $granted -eq 0 ]
			do
				echo "entrez frequence de rafraichissement heure (1-24) (24=1 fois par heure)"
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
				echo "entrez frequence de rafraichissement en minute (1-60)"
				read min
				if [ "$(echo $min | grep "^[ [:digit:] ]*$")"  ] &&  [  $min -lt 60 ] && [ $min -gt 0 ] # verif si bonne fourchette
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

			granted=0
			while [ $granted -eq 0 ]
			do
				echo "entrez la frequence de generation de graphe (1-20)"
				read freqG
				if [ "$(echo $freqG | grep "^[ [:digit:] ]*$")"  ] &&  [  $freqG -le 20 ] && [ $freqG -gt 0 ] # verif si bonne fourchette
				then
					granted=1
				else
					echo "entrer non valide"
				fi
			done

			granted=0
			while [ $granted -eq 0 ]
			do
				echo "entrez le pourcentage de variation negative au bout duquel un mail sera envoyé pour signaleri(1-50)"
				read alertMail
				if [ "$(echo $alertMail | grep "^[ [:digit:] ]*$")"  ] &&  [  $alertMail -le 50 ] && [ $alertMail -gt 0 ] # verif si bonne fourchette
				then
					granted=1
				else
					echo "entrer non valide"
				fi
			done

			granted=0
			while [ $granted -eq 0 ]
			do
				echo "Entrez le nombre de graphe a concerver (2-10)"
				read nbrGraph
				if [ "$(echo $nbrGraph | grep "^[ [:digit:] ]*$")"  ] &&  [  $nbrGraph -le 10 ] && [ $nbrGraph -gt 1 ] # verif si bonne fourchette
				then
					granted=1
				else
					echo "entrer non valide"
				fi
			done

			# verif si adresse mail est deja entrée
			while [ ! -f ./frequencesStock/adrMail ] # fichier adrMail existe?
			do
				echo "entrez l'adresse a laquelle sera envoyé le mail de signalisation"
				read adrMail # entrer variable clavier
				# verif si variable possede un '@' et se termine par .fr ou .com
				if [ $(echo "$adrMail" | grep @ ) ] && [ $(echo "$adrMail" | grep .fr$ ) ] || [ $(echo "$adrMail" | grep .com$ ) ]
				then
					echo "$adrMail" > ./frequencesStock/adrMail # entrer de la variable dans le fichier(et creation du fichier si non existant)
				else
					echo "entrer non valide"
				fi
			done

			#
			while [ ! -d ./SAVE ] # fichier adrMail existe?
			do
				echo "Entrez la frequence (jours) de sauvegarde (incrementale) des graphes (1-30)"
				read freqMG # entrer variable clavier
				if [ "$(echo $freqMG | grep "^[ [:digit:] ]*$")"  ] &&  [  $freqMG -le 30 ] && [ $freqMG -gt 1 ] # verif si bonne fourchette
				then
				echo "$(crontab -l)" > ./memCron #ecrire le contenu du crontab dans un fichier
			echo "0 0 */$freqMG * * sh $(pwd)/saveInc.sh $mem"  >> ./memCron # ajouter la commande au fichier
			crontab memCron
			mkdir SAVE
				else
					echo "entrer non valide"
				fi
			done

			# verif si le fichier n'existe pas deja
			if [ -f "./memCron" ] #tmp
			then
				echo
			else
				echo "nouveau memCron"
				echo "$(crontab -l)" > ./memCron #ecrire le contenu du crontab dans un fichier
			fi
			suprCron $mem # suprimmer l'ancienne ligne si besoin est




			echo "*/$min */$heure */$jour * * sh $(pwd)/recupVal.sh $mem"  >> ./memCron # ajouter la commande au fichier
			echo "$heure $jour $alertMail $freqG $nbrGraph" > ./frequencesStock/$mem
		else
			echo "action non reconnue"
		fi

		#__________________________________________________fin mod 


	elif [ `echo $recept | cut -d ' ' -f 1` = "del" ] # si 1er element="del"
	then	
		mem=$(echo $recept | cut -d ' ' -f 2)

		if [ -f ./actionsStock/$mem ]
		then

			if [ ! -f "./memCron" ] #tmp
			then
				echo "nouveau memCron"
				echo "$(crontab -l)" > ./memCron #ecrire le contenu du crontab dans un fichier
			fi

			suprCron $mem
			rm ./actionsStock/$mem
			rm ./frequencesStock/$mem
			rm -R ./grapheStock/$mem
		else
			echo "action non reconnue"
		fi

		#__________________________________________________fin del 

	elif [ `echo $recept | cut -d ' ' -f 1` = "val" ]
	then
		if [ ! -f ./memCron ]
		then
			echo "rien a mettre a jour"
			continue
		fi
		crontab memCron # appliquer la commande au crontab
		rm memCron

		#__________________________________________________fin val 

	else 
		echo "erreur commande"
	fi
done
echo "fin prog"
exit
