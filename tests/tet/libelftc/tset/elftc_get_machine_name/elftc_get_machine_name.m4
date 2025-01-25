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
	TP_ANNOUNCE("elftc_get_machine() returns a null pointer for an "
	    "unknown machine");

	/* Ask for the machine name for an unknown EM_* value. */
	const char *machine_name = elftc_get_machine_name(~0U);

 	int result = TET_PASS;

	/* The API should fail and should set errno. */
	if (machine_name) {
		TP_FAIL("elftc_get_machine() unexpectedly returned \"%s\".",
		    machine_name);
	} else if (errno != EINVAL)
		TP_FAIL("elftc_get_machine() failed with an unexpected "
		    "error number: %d.", errno);

	tet_result(result);
}

/*
 * Currently defined gABI EM_* values and their symbolic names.
 *
 * See: https://groups.google.com/g/generic-abi/c/0kORSDcyhTE.
 */
static const char *gABI_names[] = {
	[0]	= "EM_NONE",
	[1]	= "EM_M32",
	[2]	= "EM_SPARC",
	[3]	= "EM_386",
	[4]	= "EM_68K",
	[5]	= "EM_88K",
	[6]	= "EM_IAMCU",
	[7]	= "EM_860",
	[8]	= "EM_MIPS",
	[9]	= "EM_S370",
	[10]	= "EM_MIPS_RS3_LE",
	[15]	= "EM_PARISC",
	[17]	= "EM_VPP500",
	[18]	= "EM_SPARC32PLUS",
	[19]	= "EM_960",
	[20]	= "EM_PPC",
	[21]	= "EM_PPC64",
	[22]	= "EM_S390",
	[23]	= "EM_SPU",
	[36]	= "EM_V800",
	[37]	= "EM_FR20",
	[38]	= "EM_RH32",
	[39]	= "EM_RCE",
	[40]	= "EM_ARM",
	[41]	= "EM_ALPHA",
	[42]	= "EM_SH",
	[43]	= "EM_SPARCV9",
	[44]	= "EM_TRICORE",
	[45]	= "EM_ARC",
	[46]	= "EM_H8_300",
	[47]	= "EM_H8_300H",
	[48]	= "EM_H8S",
	[49]	= "EM_H8_500",
	[50]	= "EM_IA_64",
	[51]	= "EM_MIPS_X",
	[52]	= "EM_COLDFIRE",
	[53]	= "EM_68HC12",
	[54]	= "EM_MMA",
	[55]	= "EM_PCP",
	[56]	= "EM_NCPU",
	[57]	= "EM_NDR1",
	[58]	= "EM_STARCORE",
	[59]	= "EM_ME16",
	[60]	= "EM_ST100",
	[61]	= "EM_TINYJ",
	[62]	= "EM_X86_64",
	[63]	= "EM_PDSP",
	[64]	= "EM_PDP10",
	[65]	= "EM_PDP11",
	[66]	= "EM_FX66",
	[67]	= "EM_ST9PLUS",
	[68]	= "EM_ST7",
	[69]	= "EM_68HC16",
	[70]	= "EM_68HC11",
	[71]	= "EM_68HC08",
	[72]	= "EM_68HC05",
	[73]	= "EM_SVX",
	[74]	= "EM_ST19",
	[75]	= "EM_VAX",
	[76]	= "EM_CRIS",
	[77]	= "EM_JAVELIN",
	[78]	= "EM_FIREPATH",
	[79]	= "EM_ZSP",
	[80]	= "EM_MMIX",
	[81]	= "EM_HUANY",
	[82]	= "EM_PRISM",
	[83]	= "EM_AVR",
	[84]	= "EM_FR30",
	[85]	= "EM_D10V",
	[86]	= "EM_D30V",
	[87]	= "EM_V850",
	[88]	= "EM_M32R",
	[89]	= "EM_MN10300",
	[90]	= "EM_MN10200",
	[91]	= "EM_PJ",
	[92]	= "EM_OPENRISC",
	[93]	= "EM_ARC_COMPACT",
	[94]	= "EM_XTENSA",
	[95]	= "EM_VIDEOCORE",
	[96]	= "EM_TMM_GPP",
	[97]	= "EM_NS32K",
	[98]	= "EM_TPC",
	[99]	= "EM_SNP1K",
	[100]	= "EM_ST200",
	[101]	= "EM_IP2K",
	[102]	= "EM_MAX",
	[103]	= "EM_CR",
	[104]	= "EM_F2MC16",
	[105]	= "EM_MSP430",
	[106]	= "EM_BLACKFIN",
	[107]	= "EM_SE_C33",
	[108]	= "EM_SEP",
	[109]	= "EM_ARCA",
	[110]	= "EM_UNICORE",
	[111]	= "EM_EXCESS",
	[112]	= "EM_DXP",
	[113]	= "EM_ALTERA_NIOS2",
	[114]	= "EM_CRX",
	[115]	= "EM_XGATE",
	[116]	= "EM_C166",
	[117]	= "EM_M16C",
	[118]	= "EM_DSPIC30F",
	[119]	= "EM_CE",
	[120]	= "EM_M32C",
	[131]	= "EM_TSK3000",
	[132]	= "EM_RS08",
	[133]	= "EM_SHARC",
	[134]	= "EM_ECOG2",
	[135]	= "EM_SCORE7",
	[136]	= "EM_DSP24",
	[137]	= "EM_VIDEOCORE3",
	[138]	= "EM_LATTICEMICO32",
	[139]	= "EM_SE_C17",
	[140]	= "EM_TI_C6000",
	[141]	= "EM_TI_C2000",
	[142]	= "EM_TI_C5500",
	[143]	= "EM_TI_ARP32",
	[144]	= "EM_TI_PRU",
	[160]	= "EM_MMDSP_PLUS",
	[161]	= "EM_CYPRESS_M8C",
	[162]	= "EM_R32C",
	[163]	= "EM_TRIMEDIA",
	[164]	= "EM_QDSP6",
	[165]	= "EM_8051",
	[166]	= "EM_STXP7X",
	[167]	= "EM_NDS32",
	[168]	= "EM_ECOG1X",
	[169]	= "EM_MAXQ30",
	[170]	= "EM_XIMO16",
	[171]	= "EM_MANIK",
	[172]	= "EM_CRAYNV2",
	[173]	= "EM_RX",
	[174]	= "EM_METAG",
	[175]	= "EM_MCST_ELBRUS",
	[176]	= "EM_ECOG16",
	[177]	= "EM_CR16",
	[178]	= "EM_ETPU",
	[179]	= "EM_SLE9X",
	[180]	= "EM_L10M",
	[181]	= "EM_K10M",
	[183]	= "EM_AARCH64",
	[185]	= "EM_AVR32",
	[186]	= "EM_STM8",
	[187]	= "EM_TILE64",
	[188]	= "EM_TILEPRO",
	[189]	= "EM_MICROBLAZE",
	[190]	= "EM_CUDA",
	[191]	= "EM_TILEGX",
	[192]	= "EM_CLOUDSHIELD",
	[193]	= "EM_COREA_1ST",
	[194]	= "EM_COREA_2ND",
	[195]	= "EM_ARC_COMPACT2",
	[196]	= "EM_OPEN8",
	[197]	= "EM_RL78",
	[198]	= "EM_VIDEOCORE5",
	[199]	= "EM_78KOR",
	[200]	= "EM_56800EX",
	[201]	= "EM_BA1",
	[202]	= "EM_BA2",
	[203]	= "EM_XCORE",
	[204]	= "EM_MCHP_PIC",
	[205]	= "EM_INTEL205",
	[206]	= "EM_INTEL206",
	[207]	= "EM_INTEL207",
	[208]	= "EM_INTEL208",
	[209]	= "EM_INTEL209",
	[210]	= "EM_KM32",
	[211]	= "EM_KMX32",
	[212]	= "EM_KMX16",
	[213]	= "EM_KMX8",
	[214]	= "EM_KVARC",
	[215]	= "EM_CDP",
	[216]	= "EM_COGE",
	[217]	= "EM_COOL",
	[218]	= "EM_NORC",
	[219]	= "EM_CSR_KALIMBA",
	[220]	= "EM_Z80",
	[221]	= "EM_VISIUM",
	[222]	= "EM_FT32",
	[223]	= "EM_MOXIE",
	[224]	= "EM_AMDGPU",
	[243]	= "EM_RISCV",
	[244]	= "EM_LANAI",
	[245]	= "EM_CEVA",
	[246]	= "EM_CEVA_X2",
	[247]	= "EM_BPF",
	[248]	= "EM_GRAPHCORE_IPU",
	[249]	= "EM_IMG1",
	[250]	= "EM_NFP",
	[251]	= "EM_VE",
	[252]	= "EM_CSKY",
	[253]	= "EM_ARC_COMPACT3_64",
	[254]	= "EM_MCS6502",
	[255]	= "EM_ARC_COMPACT3",
	[256]	= "EM_KVX",
	[257]	= "EM_65816",
	[258]	= "EM_LOONGARCH",
	[259]	= "EM_KF32",
	[260]	= "EM_U16_U8CORE",
	[261]	= "EM_TACHYUM",
	[262]	= "EM_56800EF",
	[263]	= "EM_SBF",
	[264]	= "EM_AIENGINE",
	[265]	= "EM_SIMA_MLA",
	[266]	= "EM_BANG",
	[267]	= "EM_LOONGGPU",
};

/*
 * Verify that EM_* values in the gABI list are supported.
 */
void
tcKnownMachines(void)
{
	TP_ANNOUNCE("elftc_get_machine_name() returns the expected name "
	    "for known EM_* values.");

	const size_t n_machines = sizeof(gABI_names)/sizeof(gABI_names[0]);

	int result = TET_PASS;
	int valid_name_count = 0;
	
	for (unsigned int n = 0; n < n_machines; n++) {
 		if (gABI_names[n] == NULL) /* A reserved value. */
			continue;

		const char *machine_name = elftc_get_machine_name(n);
		if (machine_name == NULL)
			TP_FAIL("elftc_get_machine_name(%u) failed.", n);
		else if (strcmp(machine_name, gABI_names[n]))
			TP_FAIL(`"elftc_get_machine_name(%u): name mismatch: "
			    "expected \"%s\", got \"%s\"."', n,
			    gABI_names[n], machine_name);

		valid_name_count++;
	}

	tet_printf("I: Checked %d non-reserved EM_* values.",
	    valid_name_count);
	
	tet_result(result);
}

/*
 * Verify that the reserved values in the gABI list do not have
 * associated symbolic names.
 */
void
tcReservedValues(void)
{
	TP_ANNOUNCE("elftc_get_machine_name() fails for reserved EM_* "
	    "values.");

	int reserved_name_count = 0;
	int result = TET_PASS;

	const size_t n_machines = sizeof(gABI_names)/sizeof(gABI_names[0]);

	for (unsigned int n = 0; n < n_machines; n++) {
 		if (gABI_names[n] != NULL) /* Not a reserved value. */
			continue;

		const char *machine_name = elftc_get_machine_name(n);
		if (machine_name != NULL)
			TP_FAIL(`"elftc_get_machine_name(%u) succeeded "
			    "unexpectedly, returning \"%s\""', n,
			    machine_name);

		reserved_name_count++;
	}

	tet_printf("I: Checked %d reserved EM_* values.", reserved_name_count);
	
	tet_result(result);
}

/*
 * Map aliases to the names of their canonical EM_* values.
 */
const struct {
	unsigned int	em_value;
	const char	*em_expected_name;
} em_aliases[] = {
	{ EM_AMD64,	"EM_X86_64" },
	{ EM_ARC_A5,	"EM_ARC_COMPACT" },
	{ EM_ECOG1,	"EM_ECOG1X" },
	{ EM_INTELGT,	"EM_INTEL205" }
};

/*
 * Check machine names for aliased EM_* values.
 */
void tcAliases(void)
{
	TP_ANNOUNCE("elftc_get_machine_name() returns the expected name "
	    "for aliased EM_* values.");

	int result = TET_PASS;
	const size_t n_aliases = sizeof(em_aliases) / sizeof(em_aliases[0]);

	tet_printf("I: Checking %zu aliases.", n_aliases);
	
	for (unsigned int n = 0; n < n_aliases; n++) {
		const char *machine_name = elftc_get_machine_name(
		    em_aliases[n].em_value);

		if (machine_name == NULL)
			TP_FAIL("elftc_get_machine_name(%u) failed.", n);
		else if (strcmp(machine_name, em_aliases[n].em_expected_name))
			TP_FAIL(`"elftc_get_machine_name(%u) returned \"%s\", "
			    "expected \"%s\"."', machine_name,
			    em_aliases[n].em_expected_name);
	}

	tet_result(result);
}
