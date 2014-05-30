#! /bin/bash

modVerif=0 #variable determinant si il faut verifier l'action sur le site ou recuperer l'action
if [ $# -ne 1 ] && [ $# -ne 2 ]
then
	echo "erreur receptAct nombre arguments non valide"
	exit
fi

if [ $# -eq 2 ] && [ $2 = "testt" ] #si 
then
	modVerif=1
fi

page=$(curl -L http://www.boursorama.com/recherche/index.phtml?q=$1)
a=$(echo "$page" | grep cotation | grep EUR | cut -d '>' -f 3  | cut -d '<' -f 1) # premiere tentative
teste=$( echo "$a" | cut -f1 -d '.')

if [ "$(echo $teste | grep "^[ [:digit:] ]*$")" ] # test si la variable est bien numérique
then 
	echo "ok A $a"
	teste=$( echo "$a" | cut -f2 -d '.')
	if [ "$(echo $teste | grep "^[ [:digit:] ]*$")" ] # test si la variable est bien numérique
	then
		echo "ok confirm"
	else
		a=$(echo "$a" | cut -f1 -d ' ') #correction du EUR a la fin de l'expression
		echo "modif mais ok $a"
	fi
	if [ $modVerif -eq 1 ] # si simple verification
	then
		echo "action valide"
		touch ./actionsStock/$1
	else 
			# verif si ecart entre derniere valeur et la nouvelle est <= n%
			ancien=$(tail -n1 actionsStock/$1 | cut -f2 -d ' ')
			#faire calcul avec $a

			echo "$(date +%d/%m/%Y/%H:%M) $a" >> ./actionsStock/$1 #ajout de la date a laquelle l'action a ete pushee
			#test nombre de ligne du fichier de stockage du cours de l'action modulo la frequence de generation des graphes(fichier config)
			#si -eq 0 generation du graphe

			opA=$(wc -l ./actionsStock/$1 | cut -f1 -d ' ') # recup nombre de ligne du fichier de stock
			opB=$( cat ./frequencesStock/$1 | cut -f4 -d ' ' ) # recup de la frequence de gen de graphe
			if [ $(( $opA - $(( $(( $opA / $opB )) * $opB )) )) -eq 0 ] # calcul modulo ($opA%$opB==0)
			then
				sh genGraph.sh $1 # generation du graphe
			fi
	fi
	exit
else
	a=$(echo "$page" | grep cotation | grep tar | cut -f3 -d '>' | cut -f1 -d '(')
	teste=$( echo "$a" | cut -f1 -d '.')
	if [ "$(echo $teste | grep "^[ [:digit:] ]*$")" ] # test de la partie avant le point de la valeur
	then 
		echo "ok B $a"
		if [ $modVerif -eq 1 ] # si simple verification
		then
			echo "action valide"
			touch ./actionsStock/$1 # creation du fichier pour validation
		else 
			rec=$( cat ./frequencesStock/$1 | cut -f3 -d ' ' ) # recup de la tolérence du pourcentage de variation
			# amodif
			echo "$(date +%Y/%m/%d/%H/%M) $a" >> ./actionsStock/$1 #ajout de la date a laquelle l'action a ete pushee
			opA=$(wc -l ./actionsStock/$1 | cut -f1 -d ' ')
			opB=$( cat ./frequencesStock/$1 | cut -f4 -d ' ' )
			if [ $(( $opA - $(( $(( $opA / $opB )) * $opB )) )) -eq 0 ]
			then
				sh genGraph.sh $1
			fi
		fi
		exit
	fi
fi
echo "erreur action non valide"
#else #si $a est vide (si la page n'existe pas)
#	echo "erreur action non valide annulation"
#	echo "$page" > tmp.html
#fi
