#!/bin/bash

if [ $# -ne 1 ] 
then
	echo "erreur receptAct nombre arguments non valide"
	exit
fi

 gnuplot << -EOF
        set xlabel "temps"
        set ylabel "Cours"
set xdata time
set timefmt "%Y/%m/%d/%H/%M"
	set style data linespoints
        set term png
	set output "./grapheStock/$1.png"
        plot "./actionsStock/$1" using 1:2 title "$1"
