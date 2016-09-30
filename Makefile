#	$OpenBSD$

FAKE_ETHER ?=	vether188
FAKE_PREFIX ?=	10.188.210

.if empty (FAKE_ETHER) || empty (FAKE_PREFIX)
regress:
	@echo FAKE_ETHER FAKE_PREFIX are empty
	@echo fill out these variables for additional tests
	@echo SKIPPED
.endif

.MAIN: all

.if make (regress) || make (all)
.BEGIN:
	@echo
	${SUDO} sh -c '[ `id -u` -eq 0 ]'
.endif

IF =	${FAKE_ETHER}
NET =	${FAKE_PREFIX}

# Clear addresses, interface, routes.
clean-if:
	@echo '\n======== $@ ========'
	while ${SUDO} ifconfig ${IF} inet delete; do :; done || true
	${SUDO} ifconfig ${IF} destroy || true
	${SUDO} route -qn delete -inet -net ${NET}.0/24 || true
	for a in `jot 9`; do\
	    ${SUDO} route -qn delete -inet -host ${NET}.$$a || true; done

REGRESS_TARGETS +=	run-regress-address
run-regress-address: clean-if
	@echo '\n======== $@ ========'
	${SUDO} ifconfig ${IF} create
	${SUDO} ifconfig ${IF} inet ${NET}.1/24
	ifconfig ${IF} | grep -F inet
	ifconfig ${IF} | grep -qF 'inet ${NET}.1 '
	ifconfig ${IF} | grep -qF ' netmask 0xffffff00 '
	ifconfig ${IF} | grep -qF ' broadcast ${NET}.255'
	netstat -rn | grep -F '${NET}'
	route -n get -inet -net ${NET}.0/24 | grep -qF 'mask: 255.255.255.0'
	route -n get -inet -net ${NET}.0/24 | grep -qF 'interface: ${IF}'
	route -n get -inet -net ${NET}.0/24 | grep -qF 'if address: ${NET}.1'
	route -n get -inet -net ${NET}.0/24 |\
	    grep -qF 'flags: <UP,DONE,CLONING,CONNECTED>'
	route -n get -inet -host ${NET}.1 | grep -qF 'mask: 255.255.255.255'
	route -n get -inet -host ${NET}.1 | grep -qF 'interface: ${IF}'
	route -n get -inet -host ${NET}.1 | grep -qF 'if address: ${NET}.1'
	route -n get -inet -host ${NET}.1 |\
	    grep -qF 'flags: <UP,HOST,DONE,LLINFO,LOCAL>'
	route -n get -inet -host ${NET}.255 | grep -qF 'mask: 255.255.255.255'
	route -n get -inet -host ${NET}.255 | grep -qF 'interface: ${IF}'
	route -n get -inet -host ${NET}.255 | grep -qF 'if address: ${NET}.1'
	route -n get -inet -host ${NET}.255 |\
	    grep -qF 'flags: <UP,HOST,DONE,BROADCAST>'

.include <bsd.regress.mk>
