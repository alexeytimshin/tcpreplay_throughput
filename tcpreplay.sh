#!/bin/bash

pcap_file="udp_64B_100mbps.pcap"
final_pcap="test.pcap"

#ПРОВЕРИМ НАЛИЧИЕ PCAP
if ! [ -f $pcap_file ]; then
echo 'No PCAP file'
else
#зададим MAC-целевого интерфейса
read -p "Введите MAC-адрес целевого интерфейса: " macaddress
tcprewrite -i $pcap_file -o $final_pcap --enet-dmac=$macaddress

read -p "Введите минимальное значение скорости трафика: " min
read -p "Введите максимальное значение скорости трафика: " max
read -p "С каким шагом (Мбит/с) выполнять прогон: " step

while [ $min -le $max ]
do
rx_packets=$(ssh root@10.52.1.217 'ifconfig eth2 | grep "RX packets"' | awk '{print $3}')
tcpreplay -i enp3s0 -l 10 -M $min ./$final_pcap
sleep 10
rx_packets_after=$(ssh root@10.52.1.217 'ifconfig eth2 | grep "RX packets"' | awk '{print $3}')
itog=$(expr $rx_packets_after - $rx_packets)
delenie=$(bc<<<"scale=3;$itog/204745")
throughput=$(bc<<<"scale=2;$delenie*100")
echo "Пропускная способность на скорости $min Мбит/с: $throughput "
let min=min+step
done
fi