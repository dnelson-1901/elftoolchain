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

#include "uthash.h"

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
 
/*
 * Describes a contiguous range of relocation types.
 */
struct relocation_type_range {
	unsigned int	rtr_start; /* Starting R_* value. */
	unsigned int	rtr_end;   /* Ending R_* value. */
};

/*
 * Defines a hashable struct to track the uniqueness of relocation type
 * values used in these tests.
 */
struct relocation_type {
	unsigned int	r_value;  /* The key for the hash table. */
	unsigned int	r_count;  /* The number of times this value was seen. */
	UT_hash_handle	hh;	  /* This field makes the struct hashable. */
};

/*
 * A relocation type value and its symbolic name.
 */
struct relocation_type_and_name {
	unsigned int	r_value;
	const char	*r_name;
};

/**
 ** Tables with relocation type values and their respective symbols.
 **/
 
/*
 * EM_386.
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
static const struct relocation_type_and_name relocation_types_386[] = {
	{ 0,  "R_386_NONE" },
	{ 1,  "R_386_32" },
	{ 2,  "R_386_PC32" },
	{ 3,  "R_386_GOT32" },
	{ 4,  "R_386_PLT32" },
	{ 5,  "R_386_COPY" },
	{ 6,  "R_386_GLOB_DAT" },
	{ 7,  "R_386_JUMP_SLOT" },
	{ 8,  "R_386_RELATIVE" },
	{ 9,  "R_386_GOTOFF" },
	{ 10, "R_386_GOTPC" },
	{ 11, "R_386_32PLT"},
	{ 14, "R_386_TLS_TPOFF" },
	{ 15, "R_386_TLS_IE" },
	{ 16, "R_386_TLS_GOTIE" },
	{ 17, "R_386_TLS_LE" },
	{ 18, "R_386_TLS_GD" },
	{ 19, "R_386_TLS_LDM" },
	{ 20, "R_386_16" },
	{ 21, "R_386_PC16" },
	{ 22, "R_386_8" },
	{ 23, "R_386_PC8" },
	{ 24, "R_386_TLS_GD_32" },
	{ 25, "R_386_TLS_GD_PUSH" },
	{ 26, "R_386_TLS_GD_CALL" },
	{ 27, "R_386_TLS_GD_POP" },
	{ 28, "R_386_TLS_LDM_32" },
	{ 29, "R_386_TLS_LDM_PUSH" },
	{ 30, "R_386_TLS_LDM_CALL" },
	{ 31, "R_386_TLS_LDM_POP" },
	{ 32, "R_386_TLS_LDO_32" },
	{ 33, "R_386_TLS_IE_32" },
	{ 34, "R_386_TLS_LE_32" },
	{ 35, "R_386_TLS_DTPMOD32" },
	{ 36, "R_386_TLS_DTPOFF32" },
	{ 37, "R_386_TLS_TPOFF32" },
	{ 38, "R_386_SIZE32" },
	{ 39, "R_386_TLS_GOTDESC" },
	{ 40, "R_386_TLS_DESC_CALL" },
	{ 41, "R_386_TLS_DESC" },
	{ 42, "R_386_IRELATIVE" },
	{ 43, "R_386_GOT32X" },
};

/*
 * EM_AARCH64.
 */
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
static const struct relocation_type_and_name relocation_types_AARCH64[] = {
	{ 0, "R_AARCH64_NONE" },
	{ 257, "R_AARCH64_ABS64" },
	{ 258, "R_AARCH64_ABS32" },
	{ 259, "R_AARCH64_ABS16" },
	{ 260, "R_AARCH64_PREL64" },
	{ 261, "R_AARCH64_PREL32" },
	{ 262, "R_AARCH64_PREL16" },
	{ 263, "R_AARCH64_MOVW_UABS_G0" },
	{ 264, "R_AARCH64_MOVW_UABS_G0_NC" },
	{ 265, "R_AARCH64_MOVW_UABS_G1" },
	{ 266, "R_AARCH64_MOVW_UABS_G1_NC" },
	{ 267, "R_AARCH64_MOVW_UABS_G2" },
	{ 268, "R_AARCH64_MOVW_UABS_G2_NC" },
	{ 269, "R_AARCH64_MOVW_UABS_G3" },
	{ 270, "R_AARCH64_MOVW_SABS_G0" },
	{ 271, "R_AARCH64_MOVW_SABS_G1" },
	{ 272, "R_AARCH64_MOVW_SABS_G2" },
	{ 273, "R_AARCH64_LD_PREL_LO19" },
	{ 274, "R_AARCH64_ADR_PREL_LO21" },
	{ 275, "R_AARCH64_ADR_PREL_PG_HI21" },
	{ 276, "R_AARCH64_ADR_PREL_PG_HI21_NC" },
	{ 277, "R_AARCH64_ADD_ABS_LO12_NC" },
	{ 278, "R_AARCH64_LDST8_ABS_LO12_NC" },
	{ 279, "R_AARCH64_TSTBR14" },
	{ 280, "R_AARCH64_CONDBR19" },
	{ 282, "R_AARCH64_JUMP26" },
	{ 283, "R_AARCH64_CALL26" },
	{ 284, "R_AARCH64_LDST16_ABS_LO12_NC" },
	{ 285, "R_AARCH64_LDST32_ABS_LO12_NC" },
	{ 286, "R_AARCH64_LDST64_ABS_LO12_NC" },
	{ 287, "R_AARCH64_MOVW_PREL_G0" },
	{ 288, "R_AARCH64_MOVW_PREL_G0_NC" },
	{ 289, "R_AARCH64_MOVW_PREL_G1" },
	{ 290, "R_AARCH64_MOVW_PREL_G1_NC" },
	{ 291, "R_AARCH64_MOVW_PREL_G2" },
	{ 292, "R_AARCH64_MOVW_PREL_G2_NC" },
	{ 293, "R_AARCH64_MOVW_PREL_G3" },
	{ 299, "R_AARCH64_LDST128_ABS_LO12_NC" },
	{ 300, "R_AARCH64_MOVW_GOTOFF_G0" },
	{ 301, "R_AARCH64_MOVW_GOTOFF_G0_NC" },
	{ 302, "R_AARCH64_MOVW_GOTOFF_G1" },
	{ 303, "R_AARCH64_MOVW_GOTOFF_G1_NC" },
	{ 304, "R_AARCH64_MOVW_GOTOFF_G2" },
	{ 305, "R_AARCH64_MOVW_GOTOFF_G2_NC" },
	{ 306, "R_AARCH64_MOVW_GOTOFF_G3" },
	{ 307, "R_AARCH64_GOTREL64" },
	{ 308, "R_AARCH64_GOTREL32" },
	{ 309, "R_AARCH64_GOT_LD_PREL19" },
	{ 310, "R_AARCH64_LD64_GOTOFF_LO15" },
	{ 311, "R_AARCH64_ADR_GOT_PAGE" },
	{ 312, "R_AARCH64_LD64_GOT_LO12_NC" },
	{ 313, "R_AARCH64_LD64_GOTPAGE_LO15" },
	{ 314, "R_AARCH64_PLT32" },
	{ 315, "R_AARCH64_GOTPCREL32" },
	{ 512, "R_AARCH64_TLSGD_ADR_PREL21" },
	{ 513, "R_AARCH64_TLSGD_ADR_PAGE21" },
	{ 514, "R_AARCH64_TLSGD_ADD_LO12_NC" },
	{ 515, "R_AARCH64_TLSGD_MOVW_G1" },
	{ 516, "R_AARCH64_TLSGD_MOVW_G0_NC" },
	{ 517, "R_AARCH64_TLSLD_ADR_PREL21" },
	{ 518, "R_AARCH64_TLSLD_ADR_PAGE21" },
	{ 519, "R_AARCH64_TLSLD_ADD_LO12_NC" },
	{ 520, "R_AARCH64_TLSLD_MOVW_G1" },
	{ 521, "R_AARCH64_TLSLD_MOVW_G0_NC" },
	{ 522, "R_AARCH64_TLSLD_LD_PREL19" },
	{ 523, "R_AARCH64_TLSLD_MOVW_DTPREL_G2" },
	{ 524, "R_AARCH64_TLSLD_MOVW_DTPREL_G1" },
	{ 525, "R_AARCH64_TLSLD_MOVW_DTPREL_G1_NC" },
	{ 526, "R_AARCH64_TLSLD_MOVW_DTPREL_G0" },
	{ 527, "R_AARCH64_TLSLD_MOVW_DTPREL_G0_NC" },
	{ 528, "R_AARCH64_TLSLD_ADD_DTPREL_HI12" },
	{ 529, "R_AARCH64_TLSLD_ADD_DTPREL_LO12" },
	{ 530, "R_AARCH64_TLSLD_ADD_DTPREL_LO12_NC" },
	{ 531, "R_AARCH64_TLSLD_LDST8_DTPREL_LO12" },
	{ 532, "R_AARCH64_TLSLD_LDST8_DTPREL_LO12_NC" },
	{ 533, "R_AARCH64_TLSLD_LDST16_DTPREL_LO12" },
	{ 534, "R_AARCH64_TLSLD_LDST16_DTPREL_LO12_NC" },
	{ 535, "R_AARCH64_TLSLD_LDST32_DTPREL_LO12" },
	{ 536, "R_AARCH64_TLSLD_LDST32_DTPREL_LO12_NC" },
	{ 537, "R_AARCH64_TLSLD_LDST64_DTPREL_LO12" },
	{ 538, "R_AARCH64_TLSLD_LDST64_DTPREL_LO12_NC" },
	{ 539, "R_AARCH64_TLSIE_MOVW_GOTTPREL_G1" },
	{ 540, "R_AARCH64_TLSIE_MOVW_GOTTPREL_G0_NC" },
	{ 541, "R_AARCH64_TLSIE_ADR_GOTTPREL_PAGE21" },
	{ 542, "R_AARCH64_TLSIE_LD64_GOTTPREL_LO12_NC" },
	{ 543, "R_AARCH64_TLSIE_LD_GOTTPREL_PREL19" },
	{ 544, "R_AARCH64_TLSLE_MOVW_TPREL_G2" },
	{ 545, "R_AARCH64_TLSLE_MOVW_TPREL_G1" },
	{ 546, "R_AARCH64_TLSLE_MOVW_TPREL_G1_NC" },
	{ 547, "R_AARCH64_TLSLE_MOVW_TPREL_G0" },
	{ 548, "R_AARCH64_TLSLE_MOVW_TPREL_G0_NC" },
	{ 549, "R_AARCH64_TLSLE_ADD_TPREL_HI12" },
	{ 550, "R_AARCH64_TLSLE_ADD_TPREL_LO12" },
	{ 551, "R_AARCH64_TLSLE_ADD_TPREL_LO12_NC" },
	{ 552, "R_AARCH64_TLSLE_LDST8_TPREL_LO12" },
	{ 553, "R_AARCH64_TLSLE_LDST8_TPREL_LO12_NC" },
	{ 554, "R_AARCH64_TLSLE_LDST16_TPREL_LO12" },
	{ 555, "R_AARCH64_TLSLE_LDST16_TPREL_LO12_NC" },
	{ 556, "R_AARCH64_TLSLE_LDST32_TPREL_LO12" },
	{ 557, "R_AARCH64_TLSLE_LDST32_TPREL_LO12_NC" },
	{ 558, "R_AARCH64_TLSLE_LDST64_TPREL_LO12" },
	{ 559, "R_AARCH64_TLSLE_LDST64_TPREL_LO12_NC" },	
	{ 560, "R_AARCH64_TLSDESC_LD_PREL19" },
	{ 561, "R_AARCH64_TLSDESC_ADR_PREL21" },
	{ 562, "R_AARCH64_TLSDESC_ADR_PAGE21" },
	{ 563, "R_AARCH64_TLSDESC_LD64_LO12" },
	{ 564, "R_AARCH64_TLSDESC_ADD_LO12" },
	{ 565, "R_AARCH64_TLSDESC_OFF_G1" },
	{ 566, "R_AARCH64_TLSDESC_OFF_G0_NC" },
	{ 567, "R_AARCH64_TLSDESC_LDR" },
	{ 568, "R_AARCH64_TLSDESC_ADD" },
	{ 569, "R_AARCH64_TLSDESC_CALL" },
	{ 570, "R_AARCH64_TLSLE_LDST128_TPREL_LO12" },
	{ 571, "R_AARCH64_TLSLE_LDST128_TPREL_LO12_NC" },
	{ 572, "R_AARCH64_TLSLD_LDST128_DTPREL_LO12" },
	{ 573, "R_AARCH64_TLSLD_LDST128_DTPREL_LO12_NC" },
	{ 580, "R_AARCH64_AUTH_ABS64" },
	{ 581, "R_AARCH64_AUTH_MOVW_GOTOFF_G0" },
	{ 582, "R_AARCH64_AUTH_MOVW_GOTOFF_G0_NC" },
	{ 583, "R_AARCH64_AUTH_MOVW_GOTOFF_G1" },
	{ 584, "R_AARCH64_AUTH_MOVW_GOTOFF_G1_NC" },
	{ 585, "R_AARCH64_AUTH_MOVW_GOTOFF_G2" },
	{ 586, "R_AARCH64_AUTH_MOVW_GOTOFF_G2_NC" },
	{ 587, "R_AARCH64_AUTH_MOVW_GOTOFF_G3" },
	{ 588, "R_AARCH64_AUTH_GOT_LD_PREL19" },
	{ 589, "R_AARCH64_AUTH_LD64_GOTOFF_LO15" },
	{ 590, "R_AARCH64_AUTH_ADR_GOT_PAGE" },
	{ 591, "R_AARCH64_AUTH_LD64_GOT_LO12_NC" },
	{ 592, "R_AARCH64_AUTH_LD64_GOTPAGE_LO15" },
	{ 593, "R_AARCH64_AUTH_GOT_ADD_LO12_NC" },
	{ 594, "R_AARCH64_AUTH_GOT_ADR_PREL_LO21" },
	{ 595, "R_AARCH64_AUTH_TLSDESC_ADR_PAGE21" },
	{ 596, "R_AARCH64_AUTH_TLSDESC_LD64_LO12" },
	{ 597, "R_AARCH64_AUTH_TLSDESC_ADD_LO12" },	
	{ 1024, "R_AARCH64_COPY" },
	{ 1025, "R_AARCH64_GLOB_DAT" },
	{ 1026, "R_AARCH64_JUMP_SLOT" },
	{ 1027, "R_AARCH64_RELATIVE" },
	{ 1028, "R_AARCH64_TLS_DTPREL64" },
	{ 1029, "R_AARCH64_TLS_DTPMOD64" },
	{ 1030, "R_AARCH64_TLS_TPREL64" },
	{ 1031, "R_AARCH64_TLSDESC" },
	{ 1032, "R_AARCH64_IRELATIVE" },
	{ 1041, "R_AARCH64_AUTH_RELATIVE" },
	{ 1042, "R_AARCH64_AUTH_GLOB_DAT" },
	{ 1043, "R_AARCH64_AUTH_TLSDESC" },
	{ 1044, "R_AARCH64_AUTH_IRELATIVE" }	
};

/*
 * EM_IA_64.
 */
static const struct relocation_type_range relocation_type_ranges_IA_64[] = {
	{
		0, /* R_IA_64_NONE */
		0
	},
	{
		0x21, /* R_IA_64_IMM14 */
		0x27  /* R_IA_64_DIR64LSB */
	},
	{
		0x2A, /* R_IA_64_GPREL22 */
		0x2F  /* R_IA_64_GPREL2F */
	},
	{
		0x32, /* R_IA_64_LTOFF22 */
		0x33  /* R_IA_64_LTOFF64I */
	},
	{
		0x3A, /* R_IA_64_PLTOFF22 */
		0x3B  /* R_IA_64_PLTOFF64I */
	},
	{
		0x3E, /* R_IA_64_PLTOFF64MSB */
		0x3F  /* R_IA_64_PLTOFF64LSB */
	},
	{
		0x43, /* R_IA_64_FPTR64I */
		0x4F  /* R_IA_64_PCREL64LSB */
	},
	{
		0x52, /* R_IA_64_LTOFF_FPTR22 */
		0x57  /* R_IA_64_LTOFF_FPTR64LSB */
	},
	{
		0x5C, /* R_IA_64_SEGREL32MSB */
		0x5F  /* R_IA_64_SEGREL64LSB */
	},
	{
		0x64, /* R_IA_64_SECREL32MSB */
		0x67  /* R_IA_64_SECREL64LSB */
	},
	{
		0x6C, /* R_IA_64_REL32MSB */
		0x6F  /* R_IA_64_REL64LSB */
	},
	{
		0x74, /* R_IA_64_LTV32MSB */
		0x77  /* R_IA_64_LTV64LSB */
	},
	{
		0x79, /* R_IA_64_PCREL21BI */
		0x7B  /* R_IA_64_PCREL64I */
	},
	{
		0x80, /* R_IA_64_IPLTMSB */
		0x81  /* R_IA_64_IPLTLSB */
	},
	{
		0x85, /* R_IA_64_SUB */
		0x87  /* R_IA_64_LDXMOV */
	},
	{
		0x91, /* R_IA_64_TPREL14 */
		0x93  /* R_IA_64_TPREL64I */
	},
	{
		0x96, /* R_IA_64_TPREL64MSB */
		0x97  /* R_IA_64_TPREL64LSB */
	},
	{
		0x9A, /* R_IA_64_LTOFF_TPREL22 */
		0x9A
	},
	{
		0xA6, /* R_IA_64_DTPMOD64MSB */
		0xA7  /* R_IA_64_DTPMOD64LSB */
	},
	{
		0xAA, /* R_IA_64_LTOFFDTPMOD22 */
		0xAA
	},
	{
		0xB1, /* R_IA_64_DTPREL14 */
		0xB7  /* R_IA_64_DTPREL64LSB */
	},
	{
		0xBA, /* R_IA_64_LTOFF_DTPREL22 */
		0xBA
	}
};
static const struct relocation_type_and_name relocation_types_IA_64[] = {
	{ 0, "R_IA_64_NONE" },
	/**/
	{ 0x21, "R_IA_64_IMM14" },
	{ 0x22, "R_IA_64_IMM22" },
	{ 0x23, "R_IA_64_IMM64" },
	{ 0x24, "R_IA_64_DIR32MSB" },
	{ 0x25, "R_IA_64_DIR32LSB" },
	{ 0x26, "R_IA_64_DIR64MSB" },
	{ 0x27, "R_IA_64_DIR64LSB" },
	/**/
	{ 0x2A, "R_IA_64_GPREL22" },
	{ 0x2B, "R_IA_64_GPREL64I" },
	{ 0x2C, "R_IA_64_GPREL32MSB" },
	{ 0x2D, "R_IA_64_GPREL32LSB" },
	{ 0x2E, "R_IA_64_GPREL64MSB" },
	{ 0x2F, "R_IA_64_GPREL64LSB" },
	/**/
	{ 0x32, "R_IA_64_LTOFF22" },
	{ 0x33, "R_IA_64_LTOFF64I" },
	/**/
	{ 0x3A, "R_IA_64_PLTOFF22" },
	{ 0x3B, "R_IA_64_PLTOFF64I" },
	/**/
	{ 0x3E, "R_IA_64_PLTOFF64MSB" },
	{ 0x3F, "R_IA_64_PLTOFF64LSB" },
	/**/
	{ 0x43, "R_IA_64_FPTR64I" },
	{ 0x44, "R_IA_64_FPTR32MSB" },
	{ 0x45, "R_IA_64_FPTR32LSB" },
	{ 0x46, "R_IA_64_FPTR64MSB" },
	{ 0x47, "R_IA_64_FPTR64LSB" },
	{ 0x48, "R_IA_64_PCREL60B" },
	{ 0x49, "R_IA_64_PCREL21B" },
	{ 0x4A, "R_IA_64_PCREL21M" },
	{ 0x4B, "R_IA_64_PCREL21F" },
	{ 0x4C, "R_IA_64_PCREL32MSB" },
	{ 0x4D, "R_IA_64_PCREL32LSB" },
	{ 0x4E, "R_IA_64_PCREL64MSB" },
	{ 0x4F, "R_IA_64_PCREL64LSB" },
	/**/
	{ 0x52, "R_IA_64_LTOFF_FPTR22" },
	{ 0x53, "R_IA_64_LTOFF_FPTR64I" },
	{ 0x54, "R_IA_64_LTOFF_FPTR32MSB" },
	{ 0x55, "R_IA_64_LTOFF_FPTR32LSB" },
	{ 0x56, "R_IA_64_LTOFF_FPTR64MSB" },
	{ 0x57, "R_IA_64_LTOFF_FPTR64LSB" },
	/**/
	{ 0x5C, "R_IA_64_SEGREL32MSB" },
	{ 0x5D, "R_IA_64_SEGREL32LSB" },
	{ 0x5E, "R_IA_64_SEGREL64MSB" },
	{ 0x5F, "R_IA_64_SEGREL64LSB" },
	/**/
	{ 0x64, "R_IA_64_SECREL32MSB" },
	{ 0x65, "R_IA_64_SECREL32LSB" },
	{ 0x66, "R_IA_64_SECREL64MSB" },
	{ 0x67, "R_IA_64_SECREL64LSB" },
	/**/
	{ 0x6C, "R_IA_64_REL32MSB" },
	{ 0x6D, "R_IA_64_REL32LSB" },
	{ 0x6E, "R_IA_64_REL64MSB" },
	{ 0x6F, "R_IA_64_REL64LSB" },
	/**/
	{ 0x74, "R_IA_64_LTV32MSB" },
	{ 0x75, "R_IA_64_LTV32LSB" },
	{ 0x76, "R_IA_64_LTV64MSB" },
	{ 0x77, "R_IA_64_LTV64LSB" },
	/**/
	{ 0x79, "R_IA_64_PCREL21BI" },
	{ 0x7A, "R_IA_64_PCREL22" },
	{ 0x7B, "R_IA_64_PCREL64I" },
	/**/
	{ 0x80, "R_IA_64_IPLTMSB" },
	{ 0x81, "R_IA_64_IPLTLSB" },
	/**/
	{ 0x85, "R_IA_64_SUB" },
	{ 0x86, "R_IA_64_LTOFF22X" },
	{ 0x87, "R_IA_64_LDXMOV" },
	/**/
	{ 0x91, "R_IA_64_TPREL14" },
	{ 0x92, "R_IA_64_TPREL22" },
	{ 0x93, "R_IA_64_TPREL64I" },
	/**/
	{ 0x96, "R_IA_64_TPREL64MSB" },
	{ 0x97, "R_IA_64_TPREL64LSB" },
	/**/
	{ 0x9A, "R_IA_64_LTOFF_TPREL22" },
	/**/
	{ 0xA6, "R_IA_64_DTPMOD64MSB" },
	{ 0xA7, "R_IA_64_DTPMOD64LSB" },
	/**/
	{ 0xAA, "R_IA_64_LTOFF_DTPMOD22" },
	/**/
	{ 0xB1, "R_IA_64_DTPREL14" },
	{ 0xB2, "R_IA_64_DTPREL22" },
	{ 0xB3, "R_IA_64_DTPREL64I" },
	{ 0xB4, "R_IA_64_DTPREL32MSB" },
	{ 0xB5, "R_IA_64_DTPREL32LSB" },
	{ 0xB6, "R_IA_64_DTPREL64MSB" },
	{ 0xB7, "R_IA_64_DTPREL64LSB" },
	/**/
	{ 0xBA, "R_IA_64_LTOFF_DTPREL22" }
};

/*
 * EM_LOONGARCH.
 */
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
static const struct relocation_type_and_name relocation_types_LOONGARCH[] = {
	{ 0, "R_LARCH_NONE" },
	{ 1, "R_LARCH_32" },
	{ 2, "R_LARCH_64" },
	{ 3, "R_LARCH_RELATIVE" },
	{ 4, "R_LARCH_COPY" },
	{ 5, "R_LARCH_JUMP_SLOT" },
	{ 6, "R_LARCH_TLS_DTPMOD32" },
	{ 7, "R_LARCH_TLS_DTPMOD64" },
	{ 8, "R_LARCH_TLS_DTPREL32" },
	{ 9, "R_LARCH_TLS_DTPREL64" },
	{ 10, "R_LARCH_TLS_TPREL32" },
	{ 11, "R_LARCH_TLS_TPREL64" },
	{ 12, "R_LARCH_IRELATIVE" },
	{ 13, "R_LARCH_TLS_DESC32" },
	{ 14, "R_LARCH_TLS_DESC64" },
	{ 20, "R_LARCH_MARK_LA" },
	{ 21, "R_LARCH_MARK_PCREL" },
	{ 22, "R_LARCH_SOP_PUSH_PCREL" },
	{ 23, "R_LARCH_SOP_PUSH_ABSOLUTE" },
	{ 24, "R_LARCH_SOP_PUSH_DUP" },
	{ 25, "R_LARCH_SOP_PUSH_GPREL" },
	{ 26, "R_LARCH_SOP_PUSH_TLS_TPREL" },
	{ 27, "R_LARCH_SOP_PUSH_TLS_GOT" },
	{ 28, "R_LARCH_SOP_PUSH_TLS_GD" },
	{ 29, "R_LARCH_SOP_PUSH_PLT_PCREL" },
	{ 30, "R_LARCH_SOP_ASSERT" },
	{ 31, "R_LARCH_SOP_NOT" },
	{ 32, "R_LARCH_SOP_SUB" },
	{ 33, "R_LARCH_SOP_SL" },
	{ 34, "R_LARCH_SOP_SR" },
	{ 35, "R_LARCH_SOP_ADD" },
	{ 36, "R_LARCH_SOP_AND" },
	{ 37, "R_LARCH_SOP_IF_ELSE" },
	{ 38, "R_LARCH_SOP_POP_32_S_10_5" },
	{ 39, "R_LARCH_SOP_POP_32_U_10_12" },
	{ 40, "R_LARCH_SOP_POP_32_S_10_12" },
	{ 41, "R_LARCH_SOP_POP_32_S_10_16" },
	{ 42, "R_LARCH_SOP_POP_32_S_10_16_S2" },
	{ 43, "R_LARCH_SOP_POP_32_S_5_20" },
	{ 44, "R_LARCH_SOP_POP_32_S_0_5_10_16_S2" },
	{ 45, "R_LARCH_SOP_POP_32_S_0_10_10_16_S2" },
	{ 46, "R_LARCH_SOP_POP_32_U" },
	{ 47, "R_LARCH_ADD8" },
	{ 48, "R_LARCH_ADD16" },
	{ 49, "R_LARCH_ADD24" },
	{ 50, "R_LARCH_ADD32" },
	{ 51, "R_LARCH_ADD64" },
	{ 52, "R_LARCH_SUB8" },
	{ 53, "R_LARCH_SUB16" },
	{ 54, "R_LARCH_SUB24" },
	{ 55, "R_LARCH_SUB32" },
	{ 56, "R_LARCH_SUB64" },
	{ 57, "R_LARCH_GNU_VTINHERIT" },
	{ 58, "R_LARCH_GNU_VTENTRY" },
	{ 64, "R_LARCH_B16" },
	{ 65, "R_LARCH_B21" },
	{ 66, "R_LARCH_B26" },
	{ 67, "R_LARCH_ABS_HI20" },
	{ 68, "R_LARCH_ABS_LO12" },
	{ 69, "R_LARCH_ABS64_LO20" },
	{ 70, "R_LARCH_ABS64_HI12" },
	{ 71, "R_LARCH_PCALA_HI20" },
	{ 72, "R_LARCH_PCALA_LO12" },
	{ 73, "R_LARCH_PCALA64_LO20" },
	{ 74, "R_LARCH_PCALA64_HI12" },
	{ 75, "R_LARCH_GOT_PC_HI20" },
	{ 76, "R_LARCH_GOT_PC_LO12" },
	{ 77, "R_LARCH_GOT64_PC_LO20" },
	{ 78, "R_LARCH_GOT64_PC_HI12" },
	{ 79, "R_LARCH_GOT_HI20" },
	{ 80, "R_LARCH_GOT_LO12" },
	{ 81, "R_LARCH_GOT64_LO20" },
	{ 82, "R_LARCH_GOT64_HI12" },
	{ 83, "R_LARCH_TLS_LE_HI20" },
	{ 84, "R_LARCH_TLS_LE_LO12" },
	{ 85, "R_LARCH_TLS_LE64_LO20" },
	{ 86, "R_LARCH_TLS_LE64_HI12" },
	{ 87, "R_LARCH_TLS_IE_PC_HI20" },
	{ 88, "R_LARCH_TLS_IE_PC_LO12" },
	{ 89, "R_LARCH_TLS_IE64_PC_LO20" },
	{ 90, "R_LARCH_TLS_IE64_PC_HI12" },
	{ 91, "R_LARCH_TLS_IE_HI20" },
	{ 92, "R_LARCH_TLS_IE_LO12" },
	{ 93, "R_LARCH_TLS_IE64_LO20" },
	{ 94, "R_LARCH_TLS_IE64_HI12" },
	{ 95, "R_LARCH_TLS_LD_PC_HI20" },
	{ 96, "R_LARCH_TLS_LD_HI20" },
	{ 97, "R_LARCH_TLS_GD_PC_HI20" },
	{ 98, "R_LARCH_TLS_GD_HI20" },
	{ 99, "R_LARCH_32_PCREL" },
	{ 100, "R_LARCH_RELAX" },
	{ 102, "R_LARCH_ALIGN" },
	{ 103, "R_LARCH_PCREL20_S2" },
	{ 105, "R_LARCH_ADD6" },
	{ 106, "R_LARCH_SUB6" },
	{ 107, "R_LARCH_ADD_ULEB128" },
	{ 108, "R_LARCH_SUB_ULEB128" },
	{ 109, "R_LARCH_64_PCREL" },
	{ 110, "R_LARCH_CALL36" },
	{ 111, "R_LARCH_TLS_DESC_PC_HI20" },
	{ 112, "R_LARCH_TLS_DESC_PC_LO12" },
	{ 113, "R_LARCH_TLS_DESC64_PC_LO20" },
	{ 114, "R_LARCH_TLS_DESC64_PC_HI12" },
	{ 115, "R_LARCH_TLS_DESC_HI20" },
	{ 116, "R_LARCH_TLS_DESC_LO12" },
	{ 117, "R_LARCH_TLS_DESC64_LO20" },
	{ 118, "R_LARCH_TLS_DESC64_HI12" },
	{ 119, "R_LARCH_TLS_DESC_LD" },
	{ 120, "R_LARCH_TLS_DESC_CALL" },
	{ 121, "R_LARCH_TLS_LE_HI20_R" },
	{ 122, "R_LARCH_TLS_LE_ADD_R" },
	{ 123, "R_LARCH_TLS_LE_LO12_R" },
	{ 124, "R_LARCH_TLS_LD_PCREL20_S2" },
	{ 125, "R_LARCH_TLS_GD_PCREL20_S2" },
	{ 126, "R_LARCH_TLS_DESC_PCREL20_S2" },
};

/**
 ** Helper functions used by the test functions below.
 **/
 
/*
 * A helper function that populates a hash table with known relocation type
 * values.
 *
 * This function returns TET_PASS if the hash table could be successfully
 * created.
 *
 * In case of an error the function may return a partially constructed hash
 * table, which the caller would then need to clean up.
 */
static int
populate_hash_table(
    const struct relocation_type_range relocation_type_ranges[],
    size_t n_ranges,
    struct relocation_type **hash_table) {
	int result = TET_PASS;
    
	for (size_t n = 0; n < n_ranges; n++) {
		const struct relocation_type_range *rtr =
		    &relocation_type_ranges[n];

		for (unsigned int r = rtr->rtr_start; r <= rtr->rtr_end; r++) {
			/*
			 * Sanity check: the relocation type value should not
			 * have been seen before.
			 */
			struct relocation_type *is_duplicate = NULL;
 			HASH_FIND_INT(*hash_table, &r, is_duplicate);
			if (is_duplicate)
		    		TP_UNRESOLVED("Duplicate value in relocation "
				    "range: %u.", r);

			/*
			 * Add the value to the hash table.
			 */
			struct relocation_type *new_relocation_type =
			   malloc(sizeof(*new_relocation_type));
			if (new_relocation_type == NULL) {
				TP_UNRESOLVED("malloc() failed.");
				goto done;
			}
			new_relocation_type->r_value = r;
			new_relocation_type->r_count = 0;
			HASH_ADD_INT(*hash_table, r_value, new_relocation_type);
		}
	}		   

done:
	return (result);
}

/*
 * A helper to check a list of expected relocation type values for:
 *
 * a) Relocation type values that are not recognized.
 * b) Duplicate entries in the list.
 * c) Relocation type values that were not present in the list of expected
 *    values.
 *
 * The set of relocation type values that are known to be valid are passed
 * in the argument "hash_table".
 */
static int
check_relocations_list(
    const struct relocation_type_and_name expected_relocation_types[],
    size_t n_relocation_types,
    struct relocation_type *hash_table)
{
	int result = TET_PASS;
	
	for (size_t n = 0; n < n_relocation_types; n++) {
		const struct relocation_type_and_name *rtn =
		    &expected_relocation_types[n];

		struct relocation_type *rt = NULL;
		HASH_FIND_INT(hash_table, &rtn->r_value, rt);
		if (rt == NULL) {
			TP_UNRESOLVED("Relocation type value %u (0x%x) \"%s\" "
			    "is not in any valid range of relocation types.",
			    rtn->r_value, rtn->r_value, rtn->r_name);
			continue;
		}
		rt->r_count++;
		if (rt->r_count > 1)
			TP_UNRESOLVED("Relocation type value %u (0x%x) \"%s\" "
			    "seen multiple times.", rtn->r_value, rtn->r_value,
			    rtn->r_name);
	}

	/*
	 * Next, check that every relocation type value in the hash table
	 * is covered by the list of relocation types.
	 */
	struct relocation_type *s = NULL, *tmp = NULL;
	HASH_ITER(hh, hash_table, s, tmp) {
		if (s->r_count == 0)
			TP_UNRESOLVED("Relocation type value %u (0x%x) is not "
			    "being tested.", s->r_value, s->r_value);
	}
	
	return (result);
}

/**
 ** The test functions for each architecture.
 **/

undefine(`FN')
define(`FN',`
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
				TP_FAIL("relocation %u (0x%x) failed.", r, r);
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

		/*
		 * Check beyond boundaries of the current range.
		 */
		if (rtr->rtr_start > 0) {
			const unsigned int r_prev = rtr->rtr_start - 1;
			if ((r_name = elftc_get_relocation_type_name(EM_$1,
			    r_prev)) != NULL)
			   	TP_FAIL(`"relocation %u (0x%x) succeeded "
				    "unexpectedly with result \"%s\"."',
				    r_prev, r_prev, r_name);
		}

		if (rtr->rtr_end < UINT_MAX) {
			const unsigned int r_next = rtr->rtr_end + 1;
			if ((r_name = elftc_get_relocation_type_name(EM_$1,
			    r_next)) != NULL)
				TP_FAIL(`"relocation %u (0x%x) succeeded "
				    "unexpectedly with result \"%s\"."',
				    r_next, r_next, r_name);
		}
	}

	tet_result(result);
}

/*
 * Verify that relocation type values for the EM_$1 architecture are
 * correctly mapped to their symbolic names.
 */
void
tcKnownRelocations_$1(void)
{
	TP_ANNOUNCE("elftc_get_relocation_type_name(EM_$1) returns the "
	    "expected symbols for each known relocation type value.");

	int result = TET_PASS;

	/*
	 * Populate a hash table with all of the expected relocation type
	 * values for the EM_$1 architecture.  The entries in this table
	 * will be deleted as the test proceeds, and the hash table is
	 * expected to be empty at the end of the test.
	 */
	struct relocation_type *hash_table = NULL;
	result = populate_hash_table(
	    relocation_type_ranges_$1,
	    (sizeof(relocation_type_ranges_$1) /
             sizeof(relocation_type_ranges_$1[0])), &hash_table);
	if (result != TET_PASS)
		goto done;

	/*
	 * Sanity check the values in the relocations list for the
	 * EM_$1 architecture, aborting the test in case of an error.
	 */
	const size_t n_relocations = sizeof(relocation_types_$1) /
	    sizeof(relocation_types_$1[0]);

	result = check_relocations_list(relocation_types_$1,
	    n_relocations, hash_table);
	if (result != TET_PASS)
		goto done;
		
	/*
	 * Check the symbol returned by elftc_get_relocation_type_name()
	 * for each relocation type value in the list.
	 */
	for (unsigned int n = 0; n < n_relocations; n++) {
		const struct relocation_type_and_name *rtn =
		    &relocation_types_$1[n];

		const char *r_name = elftc_get_relocation_type_name(EM_$1,
		    rtn->r_value);
		if (r_name == NULL)
			TP_FAIL("relocation %u (0x%x) failed.", rtn->r_value,
			    rtn->r_value);
		else if (strcmp(r_name, rtn->r_name))
	   		TP_FAIL(`"relocation %u (0x%x): expected \"%s\", "
			    "got \"%s\"."', rtn->r_value, rtn->r_value,
			    rtn->r_name, r_name);
		/*
		 * Remove the relocation type record from the hash table since
		 * its value has been seen.
		 */
		struct relocation_type *rt = NULL;
		HASH_FIND_INT(hash_table, &rtn->r_value, rt);
		if (rt == NULL) {
			TP_UNRESOLVED("relocation type %u missing.", rtn->r_value);
			goto done;
		}
		HASH_DEL(hash_table, rt);
	}

	/*
	 * Verify that every known relocation type value has been checked.
	 */
	struct relocation_type *s = NULL, *tmp = NULL;
	HASH_ITER(hh, hash_table, s, tmp) {
		TP_UNRESOLVED("relocation type value %u was not checked.",
		    s->r_value);
	}

done:
	/*
	 * Free up the hash table.
	 */
	s = tmp = NULL;
	HASH_ITER(hh, hash_table, s, tmp) {
		HASH_DEL(hash_table, s);
		free(s);
	}
		
	tet_result(result);
}
')

FN(`386')
FN(`AARCH64')
FN(`IA_64')
FN(`LOONGARCH')
