BEGIN {
	for (i in send) {
		send[i] = 0
	}
	for (i in recv) {
		recv[i] = 0
	}
	tx = 0
	drop = 0
	pkt_loss = 0
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
		send[pkt_id] = 1
		#printf("send[%g] = 1\n",pkt_id)
	}
	# Store packets arrival time
	if (flow_id == flow && node_id == dst && event == "r") {
		recv[pkt_id] = 1
		#printf("\t\trecv[%g] = 1\n",pkt_id)
	}
}

END {
	printf("%10g ",flow)
	for (i in send) {
		if (send[i] == 1) {
			tx ++
			if (recv[i] == 0) {
				drop ++
				#printf("pkt %g not recvd\n",i)
			}
		}
	}
	if (tx != 0) {
		pkt_loss = drop / tx
	} else {
		pkt_loss = 0
	}
	printf("%10g %10g %10g\n",tx,drop,pkt_loss*100)
}
