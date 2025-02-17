/*-
 * Copyright (c) 2006,2011 Joseph Koshy
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $Id$
 */

#include <sys/types.h>
#include <sys/stat.h>

#include <errno.h>
#include <fcntl.h>
#include <libelf.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#include "elfts.h"

#include "tet_api.h"

include(`elfts.m4')
include(`elf_flag.m4')

/*
 * Tests for elf_flagdata().
 */

IC_REQUIRES_VERSION_INIT();

/*
 * A Null argument is allowed.
 */

TP_FLAG_NULL(`elf_flagphdr')

define(`_TP_DECLARATIONS',`
	int fd;
	Elf *e;
	Elf32_Ehdr *eh;
	Elf32_Phdr *ph;')
define(`_TP_PROLOGUE',`
	result = TET_UNRESOLVED;
	fd = -1;
	e = NULL;

	TS_OPEN_FILE(e, TS_NEWFILE, ELF_C_WRITE, fd);

	if ((eh = elf32_newehdr(e)) == NULL) {
		TP_UNRESOLVED("elf_newehdr() failed: \"%s\".", elf_errmsg(-1));
		goto done;
	}

	if ((ph = elf32_newphdr(e, 1)) == NULL) {
		TP_UNRESOLVED("elf_newphdr() failed: \"%s\".", elf_errmsg(-1));
		goto done;
	}')
define(`_TP_EPILOGUE',`
	if (e)
		(void) elf_end(e);
	if (fd != -1)
		(void) close(fd);
	(void) unlink(TS_NEWFILE);')

TP_FLAG_ILLEGAL_CMD(`elf_flagphdr',`e')

TP_FLAG_CLR(`elf_flagphdr',`e')
TP_FLAG_SET(`elf_flagphdr',`e')

TP_FLAG_ILLEGAL_FLAG(`elf_flagphdr',`e',`ELF_F_DIRTY')

/*
 * An out-of-sequence call is detected.
 */
_TP_FLAG_FN(`tcArgsSequence',`
	int error, fd;
	unsigned int f;
	Elf *e;',`
	TP_CHECK_INITIALIZATION();

	TP_ANNOUNCE("Out of sequence use is detected.");

	result = TET_UNRESOLVED;
	fd = -1;
	e = NULL;

	TS_OPEN_FILE(e, "phdr.lsb32", ELF_C_READ, fd);

	result = TET_PASS;
	if ((f = elf_flagphdr(e, ELF_C_SET, ELF_F_DIRTY)) != 0)
		TP_FAIL("flag=0x%x.", f);
	else if ((error = elf_errno()) != ELF_E_SEQUENCE)
		TP_FAIL("error=%d \"%s\".", error, elf_errmsg(error));
	',`_TP_EPILOGUE')
