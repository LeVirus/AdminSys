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
			echo "$(date +%Y/%m/%d/%H/%M) $a" >> ./actionsStock/$1 #ajout de la date a laquelle l'action a ete pushee
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
		else 
			echo "$(date +%Y/%m/%d/%H/%M) $a" >> ./actionsStock/$1 #ajout de la date a laquelle l'action a ete pushee
		fi
		exit
	fi
fi
echo "erreur action non valide"
#else #si $a est vide (si la page n'existe pas)
#	echo "erreur action non valide annulation"
#	echo "$page" > tmp.html
#fi
