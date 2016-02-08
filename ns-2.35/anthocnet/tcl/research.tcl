# SKRYPT SYMULACYJNY - PROTOKOL AntHocNet Andrzej Podrucki

set val(chan)           Channel/WirelessChannel    ;# Channel Type/Typ kanalu
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             100                        ;# number of mobilenodes
set val(rp)             AntHocNet                  ;# routing protocol
set val(v)              30.0		               ;# velocity
set val(x)				1500
set val(y)				1500
set val(stop)			100.0


# Initialize Global Variables	/Inicjowanie zmiennych globalnych
set ns_		[new Simulator]
set tracefd     [open low-ant.tr w]
$ns_ trace-all $tracefd

set namtrace [open low-ant-wrls.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object	/Utworzenie obiektu topograficznego
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

# Create God			/Tworzenie GOD
set god_ [create-god $val(nn)]

# New API to config node: 					/Nowe API do konfiguracji węzła:
# 1. Create channel (or multiple-channels);			/1. Tworzenie kanału (lub kilku kanałów);
# 2. Specify channel in node-config (instead of channelType);	/2. Określ kanału w node-config (zamiast channelType);
# 3. Create nodes for simulations.				/3. Tworzenie węzłów dla symulacji.

# Create channel #1 and #2	/Tworzenie kanału 1 i 2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]


# Create node(0) "attached" to channel #1	/Tworzenie wezla node(0) "dolaczonego" do kanalu 1

# configure node, please note the change below.	/Konfiguracji węzła, należy zwrócić uwagę na zmiany poniżej
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-channel $chan_1_

for {set i 0} {$i < $val(nn) } { incr i } {
	set node_($i) [$ns_ node]
}

# Provide initial location of mobilenodes
for {set i 0} {$i < $val(nn) } { incr i } {
    set x [expr floor(rand() * $val(x))]
    set y [expr floor(rand() * $val(y))]

    $node_($i) set X_ $x
    $node_($i) set Y_ $y
    $node_($i) set Z_ 0.0
}

# Generation of movements
for {set j 0} {$j < $val(nn) } { incr j } {
    set moves [expr floor(rand() * 5)]
    set i [expr int($j)]

    for {set k 0} {$k < $moves } { incr k } {
        set timer [expr floor(rand() * $val(stop))]
        set x [expr floor(rand() * $val(x))]
        set y [expr floor(rand() * $val(y))]

		if {$x < 1} { set x 1.0 }
		if {$y < 1} { set y 1.0 }

        $ns_ at $timer "$node_($i) setdest $x $y $val(v)"
    }
}


# Setup traffic flow between nodes			/Ustawienia ruchu między węzłami
# UDP connections between node_(0) and node_(1)		/Polaczenie TCP pomiedzy wezlami node_(0) i node_(1)

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 3.0 "$ftp start"

#
# Tell nodes when the simulation ends			/Powiedz węzłom gdy symulacja sie kończy
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "stop"
$ns_ at [expr $val(stop) + 0.1] "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run
