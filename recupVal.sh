#! /bin/bash

puissanceDix(){
if [ $# -ne 1 ] || [ $1 -le 0 ]
then
	echo "erreur puissance arguments non valide"
	exit
fi
cmpt=0
	var=1
	while [ $cmpt -ne $1 ]
	do
		var=$(($var * 10))
		cmpt=$(($cmpt + 1))
	done
	echo $var
	exit
}

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

diff=0
val=0
pourcent=0
page=$(curl -L http://www.boursorama.com/recherche/index.phtml?q=$1)
a=$(echo "$page" | grep cotation | grep EUR | cut -d '>' -f 3  | cut -d '<' -f 1) # premiere tentative
teste=$( echo "$a" | cut -f1 -d '.') #recup du nombre avant la virgule

if [ "$(echo $teste | grep "^[ [:digit:] ]*$")" ] # test si la partie avant la virgule est bien numerique
then 
	echo "ok A $a"
	val=1
	teste=$( echo "$a" | cut -f2 -d '.')
	if [ "$(echo $teste | grep "^[ [:digit:] ]*$")" ] # test si la partie apres la virgule est bien numerique
	then
		echo "ok confirm"
	else
		a=$(echo "$a" | cut -f1 -d ' ') #sinon correction du EUR a la fin de l'expression
		echo "modif mais ok $a"
	fi
fi

if [ $val -eq 0 ]
then
	a=$(echo "$page" | grep cotation | grep tar | cut -f3 -d '>' | cut -f1 -d '(') # 2eme tentative
	teste=$( echo "$a" | cut -f1 -d '.')
	if [ "$(echo $teste | grep "^[ [:digit:] ]*$")" ] # test de la partie avant le point de la valeur
	then 
		val=1
		echo "ok B $a"
	fi
fi

if [ $val -eq 0 ]
then
	echo "erreur action non valide"
	exit
fi

if [ $modVerif -eq 1 ] # si simple verification
then
	echo "action valide"
	touch ./actionsStock/$1 # creation du fichier pour confirmation dans gestActions.sh
else # si ajout de la valeur dans la base


#Verification ecart negatif______________________________________

if [ $(wc -l ./actionsStock/$1 | cut -f1 -d ' ') -ne 0 ] # verif si fichier non vide
then

	# verif si ecart entre derniere valeur et la nouvelle est <= n%
	limitPourcent=$( head ./frequencesStock/$1 | cut -f3 -d ' ' ) #recup limite pourcentage dans frequencesStock
	ancien=$(tail -n1 actionsStock/$1 | cut -f2 -d ' ') # recup derniere valeur enregistrée

	partA=$( echo "$ancien" | cut -f1 -d '.' ) # recup 1ere partie avant la virgule
	partB=$( echo "$ancien" | cut -f2 -d '.' ) # ""    ""      ""  apres  ""   ""
	cmptA=$(echo "$partB" | wc -c) # comptage du nombre de chiffres apres la virgule de "ancien"
	cmptA=$(($cmptA - 1)) # correction -1 
	recA=$(puissanceDix $cmptA) # conversion en puissance de dix avec la fonction
	partA=$(($partA * $recA)) # multiplication avec recA
	ancien=$(($partA + $partB)) # adition des 2 parties
	echo "$partA $partB $cmptA $recA $ancien"

	partA=$( echo "$a" | cut -f1 -d '.' )
	partB=$( echo "$a" | cut -f2 -d '.' )
	cmptB=$(echo "$partB" | wc -c) # comptage du nombre de chiffres apres la virgule de "ancien"
	cmptB=$(($cmptB - 1))
	recB=$(puissanceDix $cmptB)
	partA=$(($partA * recB))
	memA=$(($partA + $partB))

	if [ $cmptA -lt $cmptB ]
	then
		cmptA=$(($cmptB - $cmptA))
		recA=$(puissanceDix $cmptA)
		ancien=$(($ancien * $recA))
	elif [ $cmptB -lt $cmptA ]
	then
		cmptB=$(($cmptA - $cmptB))
		recB=$(puissanceDix $cmptB)
		memA=$(($memA * $recB))
	fi

	diff=$(($ancien - $memA)) 
	echo "diff $diff $ancien $memA"
		pourcent=$((100 * $diff / $ancien)) # calcul de la différence en %
	echo "pourcent $pourcent"
	if [ $diff -gt 0 ] # verif si la difference est positive
	then
		pourcent=$((100 * $diff / $ancien)) # calcul de la différence en %
	fi
	# si pourcentage limite depasse
	if [ $pourcent -ge $limitPourcent ]
	then
		adrM=$(cat ./frequencesStock/adrMail)
		echo "limite depassee envoie d'un mail"
		# envoi du mail a l'adresse stockee dans le fichier
		echo "l'action $1 a diminué de $pourcent % \n.Date:$(date +%d/%m/%Y/%H:%M)" | mail -s "Depassement action $1" $adrM 
	fi

fi

	echo "$(date +%d/%m/%Y/%H:%M) $a" >> ./actionsStock/$1 #ajout de la date a laquelle l'action a ete pushee


#Generation du Graphe______________________________________


	#test nombre de ligne du fichier de stockage du cours de l'action modulo la frequence de generation des graphes(fichier config)
	#si -eq 0 generation du graphe
	opA=$(wc -l ./actionsStock/$1 | cut -f1 -d ' ') # recup nombre de ligne du fichier de stock
	opB=$( cat ./frequencesStock/$1 | cut -f4 -d ' ' ) # recup de la frequence de gen de graphe
	if [ $(( $opA - $(( $(( $opA / $opB )) * $opB )) )) -eq 0 ] # calcul modulo ($opA%$opB==0)
	then
		sh genGraph.sh $1 # generation du graphe
	fi
fi
