# $Id$

TOP=	../../../../..

TS_SRCS=		getarhdr.m4

# These names must match those in the test case code.
TS_DATA=		a.ar a-bsd.ar a1.o a2.o
TS_LONGNAME=		"s------------------------2"
CLEANFILES+=		a1.c a2.c s1 ${TS_LONGNAME} "s 3"

# This timestamp must match that in test case code.
TS_TIMESTAMP=		202511201606.02 # time_t: 1763654762.

a1.c:	.SILENT
	echo "int a1;" > ${.TARGET}
a2.c:	.SILENT
	echo "int a2;" > ${.TARGET}

a.ar:	a1.o a2.o .SILENT
	rm -f ${.TARGET}
	echo 'This is s1.' > s1
	echo 's2.' > ${TS_LONGNAME}
	echo 's-3.' > "s 3"
	for f in ${.ALLSRC} s1 "${TS_LONGNAME}" "s 3"; do \
		touch -t ${TS_TIMESTAMP} "$${f}"; \
	done
	${AR} crvU ${.TARGET} s1 a1.o ${TS_LONGNAME} a2.o "s 3" > /dev/null

a-bsd.ar: a.ar .SILENT
	rm -f ${.TARGET}
	${ELFTOOLCHAIN_AR} -F bsd -crv ${.TARGET} s1 a1.o ${TS_LONGNAME} \
		a2.o "s 3" > /dev/null

.include "${TOP}/mk/elftoolchain.tet.mk"
