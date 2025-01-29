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
#include <limits.h>
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

/**
 ** The first set of tests checks the ranges of R_* definitions
 ** known to the libelftc library.
 **
 ** These tests are meant to detect unexpected additions or
 ** deletions to the list of relocation types for an architecture.
 **/
 
/*
 * Describes a contiguous range of relocation types.
 */
struct relocation_type_range {
	unsigned int	rtr_start; /* Starting R_* value. */
	unsigned int	rtr_end;   /* Ending R_* value. */
};

undefine(`RTRFN')
define(`RTRFN',`
/*
 * Verify that elftc_get_relocation_type_name() succeeds for known relocation
 * types for the EM_$1 architecture.
 */
void
tcCheckRelocationTypeRangeValid_$1(void)
{
	TP_ANNOUNCE("elftc_get_relocation_type_name() succeeds for "
	    "relocation types values known to be valid for the EM_$1 "
	    "architecture.");

	int result = TET_PASS;
	const size_t n_ranges = sizeof(relocation_type_ranges_$1) /
	    sizeof(relocation_type_ranges_$1[0]);

	for (unsigned int n = 0; n < n_ranges; n++) {
		const struct relocation_type_range *rtr =
		    &relocation_type_ranges_$1[n];
		/*
		 * Every value in the range should have a symbolic name.
		 */
		for (unsigned int r = rtr->rtr_start; r <= rtr->rtr_end; r++)
			if (elftc_get_relocation_type_name(EM_$1, r) == NULL)
				TP_FAIL("relocation %u failed.", r);
	}

	tet_result(result);
}

/*
 * Verify that elftc_get_relocation_type_name() fails for relocation type values
 * falling beyond the boundaries of the known ranges.
 */
void
tcCheckRelocationTypeRangeBoundary_$1(void)
{
	TP_ANNOUNCE("elftc_get_relocation_type_name() fails for relocation "
	    "type values outside of the known ranges for the EM_$1 "
	    "architecture.");

	int result = TET_PASS;

	const size_t n_ranges = sizeof(relocation_type_ranges_$1) /
	    sizeof(relocation_type_ranges_$1[0]);

	for (unsigned int n = 0; n < n_ranges; n++) {
		const struct relocation_type_range *rtr =
		    &relocation_type_ranges_$1[n];
		const char *r_name = NULL;
		
		if (rtr->rtr_start > 0 &&
		   (r_name = elftc_get_relocation_type_name(EM_$1,
		       rtr->rtr_start - 1)) != NULL)
		   	TP_FAIL(`"relocation %u succeeded unexpectedly with "
			    "result \"%s\"."', rtr->rtr_start - 1, r_name);

		if (rtr->rtr_end < UINT_MAX &&
		    (r_name = elftc_get_relocation_type_name(EM_$1,
		        rtr->rtr_end + 1)) != NULL)
			TP_FAIL(`"relocation %u succeeded unexpectedly with "
			    "result \"%s\"."', rtr->rtr_end + 1, r_name);
	}

	tet_result(result);
}
')

/*
 * EM_386 relocations.
 */
static const struct relocation_type_range relocation_type_ranges_386[] = {
	{
		0, /*R_386_NONE*/
		11 /*R_386_32PLT*/
	},
	{
		14, /*R_386_TLS_TPOFF*/
		43  /*R_386_GOT32X*/
	}
};

RTRFN(386)

static const struct relocation_type_range relocation_type_ranges_AARCH64[] = {
	{ 0, 0 },  /* R_AARCH64_NONE */
	{
		257, /* R_AARCH64_ABS64 */
		280  /* R_AARCH64_CONDBR19 */
	},
	{
		282, /* R_AARCH64_JUMP26 */
		293, /* R_AARCH64_MOVW_PREL_G3 */
	},
	{
		299, /* R_AARCH64_LDST128_ABS_LO12_NC */
		315  /* R_AARCH64_GOTPCREL32 */
	},
	{
		512, /* R_AARCH64_TLSGD_ADR_PREL21 */
		573  /* R_AARCH64_TLSLD_LDST128_DTPREL_LO12_NC */
	},
	{
		580, /* R_AARCH64_AUTH_ABS64 */
		597  /* R_AARCH64_AUTH_TLSDESC_ADD_LO12 */
	},
	{
		1024, /* R_AARCH64_COPY */
		1032 /* R_AARCH64_IRELATIVE */
	},
	{
		1041, /* R_AARCH64_AUTH_RELATIVE */
		1044  /* R_AARCH64_AUTH_IRELATIVE */
	}
};

RTRFN(AARCH64)

static const struct relocation_type_range relocation_type_ranges_LOONGARCH[] = {
	{
		0,  /* R_LARCH_NONE */
		14, /* R_LARCH_TLS_DESC64 */
	},
	{
		20, /* R_LARCH_MARK_LA */
		58, /* R_LARCH_GNU_VTENTRY */
	},
	{
		64, /* R_LARCH_B16 */
		100 /* R_LARCH_RELAX */
	},
	{
		102, /* R_LARCH_ALIGN */
		103  /* R_LARCH_PCREL20_S2 */
	},
	{
		105, /* R_LARCH_ADD6 */
		126  /* R_LARCH_TLS_DESC_PCREL20_S2 */
	}
};

RTRFN(LOONGARCH)
