/*-
 * Copyright (c) 2025 Joseph Koshy
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

#include <errno.h>
#include <libelftc.h>
#include <string.h>

#include "tet_api.h"

include(`elfts.m4')

void
tcUnknownMachine(void)
{
	TP_ANNOUNCE("elftc_get_relocation_type_name() returns a null pointer "
	    "for an unknown machine");

	/*
	 * Ask for relocation type '0' for an unknown EM_* value.
	 */
	const char *machine_name = elftc_get_relocation_type_name(
	    /*e_machine*/ ~0U, /*r_type*/ 0U);

 	int result = TET_PASS;

	/* The API should fail and should set errno. */
	if (machine_name) {
		TP_FAIL("elftc_get_relocation_type_name() returned \"%s\""
		    "unexpectedly.", machine_name);
	} else if (errno != EINVAL)
		TP_FAIL("elftc_get_relocation_type_name() failed with an "
		    "unexpected error number: %d.", errno);

	tet_result(result);
}
