#!/bin/awk -f
# throughput.awk needs the following parameters:

# flow_id  : the ns id of the flow (that can be set in ns.
#             For example: $tcp set fid 0)
# flow_type: the type of the flow (this is actually used only for
#             SCTP flows... check the script and the following for
#             explanation)
# hrd_size : the size of the tcp+ip header of the given flow (used
#             to strip off the header before calculating the actual
#             throughput). As an example, for TCP flows it should be
#             set to 40, while for UDP flows should be set to 0
#             (since in ns trace files the packet size for UDP does
#             not count any header!).
#             As far as SCTP flows are concerned, you should modify
#             the script depending on the chunk size. In the script
#             above, I attached an FTP application to the SCTP agent,
#             with packets of 400 bytes each. The SCTP agent sent
#             one, two or three chunk in a single packet, with the
#             header varying accordingly... (pkt_size == 864 means
#             that the packet contains two chunks wiht 64 bytes of
#             header, that must be stripped off)
# dst      : the flow destination node identifier (an integer from 0
#             on, which is automatically defined by ns when the node
#             is created: the first node is 0, the second 1 and so on)
# awk -v flow="cbr" -v src="0" -v dst="1" -v simtime="30"  -f ./throughput.awk low-ant.tr
BEGIN {
	recv = 0
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
		pkt_size = $8
	}
	# Trace line format: new
	if ($2 == "-t") {
		event = $1
		time = $3
		node_id = $5
		flow_id = $39
		pkt_id = $41
		pkt_size = $37
	}

	# Calculate total received packets' size
	if (flow_id == flow && event == "r") {
		# if (flow_t != "sctp") {
			recv += pkt_size
			#printf("recv[%g] = %g --> tot: %g\n",node_id,pkt_size,recv)
		# } else {
		# 	# Rip off SCTP header, whose size depends
		# 	# on the number of chunks in each packet
		# 	if (pkt_size == 40) pkt_size = 0
		# 	if (pkt_size == 448) pkt_size = 400
		# 	if (pkt_size == 864) pkt_size = 800
		# 	if (pkt_size == 1280) pkt_size = 1200
		# 	recv += pkt_size
		# 	#printf("recv[%g] = %g --> tot: %g\n",node_id,pkt_size,recv)
		# }
	}
}

END {
	printf("%10s %10g\n",flow,(recv/simtime)*(8/1000))
}
