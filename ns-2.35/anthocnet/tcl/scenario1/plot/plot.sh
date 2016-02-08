#! /usr/bin/gnuplot -persist
#set terminal pdfcairo enhanced font "Helvetica,5"
set terminal png
set output "./test.png"
set encoding utf8
set title "test"
#set yrange [-0.04:0.51]
set style line 1 lt 1 pt 7
plot "./sim-scn1-0-AODV-trace-clean-result-average.txt" using 1:2 with linespoints linestyle 1
