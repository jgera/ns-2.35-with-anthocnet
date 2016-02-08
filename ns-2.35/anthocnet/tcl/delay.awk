#!/bin/awk -f
# flow_id : the flow identifier, see explanation for throughput.awk
# src     : the flow source node identifier (see above)
# dst     : the flow destination node identifier (see above)

#awk -v flow_id="47" -v src="0" -v dst="0"  -f ./delay.awk low-ant.tr
BEGIN {
	for (i in send) {
		send[i] = 0
	}
	for (i in recv) {
		recv[i] = 0
	}
	delay = avg_delay = 0
}

{
	# Trace line format: normal
	if ($2 != "-t") {
		event = $1
		time = $2
		if (event == "+" || event == "-") node_id = $3
		if (event == "r" || event == "d") node_id = $4
		flow_id = $8
		pkt_id = $12
	}
	# Trace line format: new
	if ($2 == "-t") {
		event = $1
		time = $3
		node_id = $5
		flow_id = $39
		pkt_id = $41
	}

	# Store packets send time
	if (flow_id == flow && node_id == src && send[pkt_id] == 0 && (event == "+" || event == "s")) {
		send[pkt_id] = time
		printf("send[%g] = %g\n",pkt_id,time)
	}
	# Store packets arrival time
	if (flow_id == flow && node_id == dst && event == "r") {
		recv[pkt_id] = time
		printf("\t\trecv[%g] = %g --> delay[%g] = %g\n",pkt_id,time,pkt_id,recv[pkt_id]-send[pkt_id])
	}
}

END {
	# Compute average delay
	for (i in recv) {
		if (send[i] == 0) {
			printf("\nError %g\n",i)
		}
		delay += recv[i] - send[i]
		num ++
	}

	printf("%10g ",flow)
	if (num != 0) {
		avg_delay = delay / num
	} else {
		avg_delay = 0
	}
	printf("%10g\n",avg_delay*1000)
}
