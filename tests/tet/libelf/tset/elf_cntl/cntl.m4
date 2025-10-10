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
#include <libelf.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "elfts.h"
#include "tet_api.h"

IC_REQUIRES_VERSION_INIT();

include(`elfts.m4')

/*
 * Test the `elf_cntl' API.
 */

static char elf_file[] = "\177ELF\001\001\001	\001\000\000\000\000"
	"\000\000\000\001\000\003\000\001\000\000\000\357\276\255\336"
	"\000\000\000\000\000\000\000\000\003\000\000\0004\000 \000"
	"\000\000(\000\000\000\000\000";

/*
 * A NULL elf parameter causes elf_cntl() to fail.
 */
void
tcInvalidNull(void)
{
	int error, result, ret;

	TP_ANNOUNCE("elf_cntl(NULL,...) fails with ELF_E_ARGUMENT.");

	TP_CHECK_INITIALIZATION();

	result = TET_PASS;
	if ((ret = elf_cntl(NULL, ELF_C_FDREAD)) != -1) {
		TP_FAIL("elf_cntl() succeeded unexpectedly, ret=%d.", ret);
	} else if ((error = elf_errno()) != ELF_E_ARGUMENT)
		TP_FAIL("elf_cntl() failed with an unexpected error \"%s\".",
		    elf_errmsg(error));

	tet_result(result);
}

/* 
 * Invalid `cmd' values are rejected.
 */
void
tcInvalidInvalid(void)
{
	Elf *e;
	int c, error, result, ret;

	TP_ANNOUNCE("elf_cntl(e,[INVALID]) fails with ELF_E_ARGUMENT.");

	TP_CHECK_INITIALIZATION();

	TS_OPEN_MEMORY(e, elf_file);

	ret = error = 0;
	result = TET_PASS;
	for (c = ELF_C_FIRST-1; c <= ELF_C_LAST; c++) {
		if (c == ELF_C_FDDONE || c == ELF_C_FDREAD)
			continue;
		if ((ret = elf_cntl(e, c)) != -1) {
			TP_FAIL("elf_cntl(%d) succeeded unexpectedly.", c);
			break;
		}
		if ((error = elf_errno()) != ELF_E_ARGUMENT) {
			TP_FAIL("elf_cntl(%d) returned an unexpected error "
			    "(%d, \"%s\").", c, error, elf_errmsg(error));
			break;
		}
	}

	(void) elf_end(e);
	tet_result(result);
}

/*
 * Calling elf_cntl(FDREAD) for files opened in read mode.
 */
void
tcReadFDREAD(void)
{
	Elf *e;
	int result;

	TP_ANNOUNCE("elf_cntl(e,FDREAD) for a read-only descriptor succeeds.");

	TP_CHECK_INITIALIZATION();

	TS_OPEN_MEMORY(e, elf_file);

	result = TET_PASS;
	if (elf_cntl(e, ELF_C_FDREAD) != 0)
		TP_FAIL("elf_cntl() failed unexpectedly: \"%s\".",
		    elf_errmsg(-1));

	(void) elf_end(e);
	tet_result(result);
}

/*
 * Returns the file descriptor and file name for a temporary
 * file.
 */
static int
create_temporary_file(char **pathname)
{
	int fd;
	mode_t previous_umask;
	char temporary_path[PATH_MAX];

	(void) strcpy(temporary_path, "/tmp/TCXXXXXX");

	/*
	 * Explicitly set the process's umask in order to be
	 * operate securely with older implementations of
	 * mkstemp`'().
	 */
	previous_umask = umask(S_IRWXG | S_IRWXO);

	fd = mkstemp`'(temporary_path);

	(void) umask(previous_umask);

	if (fd < 0)
		return (fd);

	if ((*pathname = strdup(temporary_path)) == NULL) {
		const int saved_errno = errno;
		(void) unlink(temporary_path);
		errno = saved_errno;
		
		return (-1);
	}
	
	return (fd);
}

/*
 * Reclaims resources associated with a temporary file
 * created by a previous call to create_temporary_file().
 */
static void
delete_temporary_file(int fd, char *pathname)
{
	if (fd >= 0)
		(void) close(fd);
	if (pathname) {
		(void) unlink(pathname);
		free(pathname);
	}
}

/*
 * elf_cntl(FDREAD) doesn't make sense for a descriptor opened
 * for writing.
 */
void
tcWriteFDREAD(void)
{
	Elf *e;
	char *pathname;
	int err, fd, result, ret;

	e = NULL;
	fd = -1;
	pathname = NULL;
	err = ELF_E_NONE;
	
	TP_ANNOUNCE("elf_cntl(e,FDREAD) for a descriptor opened for write "
	    "fails with ELF_E_MODE.");

	TP_CHECK_INITIALIZATION();

	if ((fd = create_temporary_file(&pathname)) < 0) {
		TP_UNRESOLVED("create_temporary_file() failed: \"%s\".",
		    strerror(errno));
		goto done;
	}

	if ((e = elf_begin(fd, ELF_C_WRITE, NULL)) == NULL) {
		TP_UNRESOLVED("elf_begin(%d,WRITE,NULL) failed.");
		goto done;
	}

	if ((ret = elf_cntl(e, ELF_C_FDREAD)) != -1) {
		TP_FAIL("elf_cntl() succeeded unexpectedly.");
		goto done;
	}
	if ((err = elf_errno()) != ELF_E_MODE) {
		TP_FAIL("elf_cntl() failed with an unexpected error \"%s\".",
		    elf_errmsg(err));
		goto done;
	}

	result = TET_PASS;

 done:
	if (e)
		(void) elf_end(e);

 	delete_temporary_file(fd, pathname);
	
	tet_result(result);
}

/*
 * An elf_cntl(FDDONE) causes a subsequent elf_update(WRITE) to fail.
 */

void
tcWriteFDDONE(void)
{
	Elf *e;
	Elf32_Ehdr *eh;
	char *pathname;
	int err, fd, result;
	off_t ret;

	e = NULL;
	fd = -1;
	pathname = NULL;
	err = ELF_E_NONE;
	
	TP_ANNOUNCE("elf_cntl(e,FDDONE) makes a subsequent "
	    "elf_update(ELF_C_WRITE) fail with ELF_E_SEQUENCE.");

	TP_CHECK_INITIALIZATION();

	if ((fd = create_temporary_file(&pathname)) == -1) {
		TP_UNRESOLVED("create_temporary_file() failed: \"%s\".",
		    strerror(errno));
		goto done;
	}
	if ((e = elf_begin(fd, ELF_C_WRITE, NULL)) == NULL) {
		TP_UNRESOLVED("elf_begin(%d,WRITE,NULL) failed.");
		goto done;
	}

	if (elf_cntl(e, ELF_C_FDDONE) == -1) {
		TP_FAIL("elf_cntl(e,FDONE) failed: \"%s\".", elf_errmsg(-1));
		goto done;
	}

	if (elf_flagelf(e, ELF_C_SET, ELF_F_DIRTY) == 0) {
		TP_UNRESOLVED("elf_flagelf() failed: \"%s\".", elf_errmsg(-1));
		goto done;
	}

	if ((eh = elf32_newehdr(e)) == NULL) {
		TP_UNRESOLVED("elf32_newehdr() failed: \"%s\".", elf_errmsg(-1));
		goto done;
	}

	if ((ret = elf_update(e, ELF_C_WRITE)) != (off_t) -1) {
		TP_FAIL("elf_update(ELF_C_WRITE) succeeded unexpectedly.");
		goto done;
	}
	if ((err = elf_errno()) != ELF_E_SEQUENCE) {
		TP_FAIL("elf_update() failed with an unexpected error "
		    "(%d, \"%s\").", ret, err, elf_errmsg(err));
		goto done;
	}

	result = TET_PASS;

 done:
	tet_result(result);

	if (e)
		(void) elf_end(e);

	delete_temporary_file(fd, pathname);
}
