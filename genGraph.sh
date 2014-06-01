#!/bin/bash

if [ $# -ne 1 ] 
then
	echo "erreur receptAct nombre arguments non valide"
	exit
fi

if [ ! -f ./actionsStock/$1 ] 
then
	echo "erreur action non existante abandon"
	exit
fi

freqGraph=$(cat ./frequencesStock/$1 | cut -f4 -d ' ') # recup de la freequence de generation de graphe
opA=0

tail -n$freqGraph ./actionsStock/$1 > tmp

for i in $(ls ./grapheStock/$1/) #calcul nombre graphe
do
	echo "$i"
	opA=$(($opA + 1))
done

png=".png"
opB=$(cat ./frequencesStock/$1 | cut -f5 -d ' ') # recup du nombre de graphe a concerver

if [ $opA -lt $opB ] # si nombre graphe < au nombre de graphe a concevoir
then
	opA=$(($opA + 1))
	echo "a$opA"
	final="$1/$1$opA"
else
	echo "b"
	cmpt=2
	until [ $cmpt -eq $(($opA+1)) ]
	do
		mv ./grapheStock/$1/$1$cmpt$png ./grapheStock/$1/$1$(($cmpt-1))$png
	cmpt=$(($cmpt + 1))
	done
		final="$1/$1$opB" # mise a jour du dernier graphe
fi

echo "$final"

if [ ! -d ./grapheStock/$1 ]
then
	mkdir ./grapheStock/$1
fi
final=$(echo "$final$png")
echo "./grapheStock/$final"
gnuplot << -EOF
set xlabel "temps"
set ylabel "Cours"
set xdata time
set timefmt "%d/%m/%Y/%H:%M"
set style data linespoints
set term png
set output "./grapheStock/$final"
plot "./tmp" using 1:2 title "$1"
