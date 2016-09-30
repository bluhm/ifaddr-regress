#	$OpenBSD$

FAKE_ETHER ?=	vether188
FAKE_PREFIX ?=	10.188.70

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
	${SUDO} true
.endif

regress:
	@echo PASS

.include <bsd.regress.mk>
