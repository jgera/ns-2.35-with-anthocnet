#!/bin/awk -f
# flow_id : the flow identifier, see explanation for throughput.awk
# src     : the flow source node identifier (see above)
# dst     : the flow destination node identifier (see above)

#awk -v flow="210" -v src="0" -v dst="0"  -f ./delay.awk low-ant.tr
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
		if (event == "+" || event == "-") node_id = 0+$14
		if (event == "r" || event == "d") node_id = 0+$15
		flow_id = $7
		pkt_id = $6
		from_id = $14
		to_id = $15
	}

	# Trace line format: new
	if ($2 == "-t") {
		event = $1
		time = $3
		node_id = $14
		flow_id = $39
		pkt_id = $41
	}

	# Store packets send time
	if (flow_id == flow && send[pkt_id] == 0 && (event == "+" || event == "s")) {
		send[pkt_id] = time
		#printf("send[%g] = %g\n",pkt_id,time)
	}
	# Store packets arrival time
	if (flow_id == flow &&  event == "r") {
		recv[pkt_id] = time
		#printf("\t\trecv[%g] = %g --> delay[%g] = %g\n",pkt_id,time,pkt_id,recv[pkt_id]-send[pkt_id])
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

	printf("%10s ",flow)
	if (num != 0) {
		avg_delay = delay / num
	} else {
		avg_delay = 0
	}
	printf("%10g\n",avg_delay*1000)
}
