# Gnuplot script for plotting "avg_rssi.data"
set term png
set grid
set output "avg_rssi.png"
set title "Average Rssi vs. Channel"
set xlabel "Channel"
set ylabel "RSSI [dBm]"
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set key autotitle columnheader
plot 'avg_rssi.data' using :(sqrt($2**2)):xtic(1) with linespoint ls 1

