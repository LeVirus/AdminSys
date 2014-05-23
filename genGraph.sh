#!/bin/bash

if [ $# -ne 1 ] 
then
	echo "erreur receptAct nombre arguments non valide"
	exit
fi

 gnuplot << -EOF
        set xlabel "temps"
        set ylabel "Cours"
        set term png
        set output "$1.png"
        plot "$1" using 1:2";
    EOF
