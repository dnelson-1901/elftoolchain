/*-
 * Copyright (c) 2025, Joseph Koshy.
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

include(`elfts.m4')

#include <libelf.h>

#include "tet_api.h"

/*
 * Test the ELF{32,64}_R_* relocation macros.
 */

void
tcElf32_R_macros(void)
{
	int result = TET_PASS;
	Elf32_Word t;
	
	TP_ANNOUNCE("Verify ELF32_R_* macros.");

	/*
	 * Test with scalar values.
	 */
	const Elf32_Word r_info = 0xAABBCCDD;

	if ((t = ELF32_R_SYM(r_info)) != 0xAABBCCU) {
		TP_FAIL("R_SYM() failed: expected 0xAABBCC, actual 0x%X.",
			t);
	}
	
	if ((t = ELF32_R_TYPE(r_info)) != 0xDDU) {
		TP_FAIL("R_TYPE() failed: expected 0xDD, actual 0x%X.",
			t);
	}

	if ((t = ELF32_R_INFO(0xBBCCDDU, 0xAAU)) != 0xBBCCDDAAU) {
		TP_FAIL("R_INFO(0xBBCCDD, 0xAA) failed: expected 0xBBCCDDAA, "
		        "actual 0x%X", t);
	}

	/*
	 * Test with expression parameters.
	 *
	 * This is intended to catch parenthesization errors in these
	 * macros.
	 */
	if ((t = ELF32_R_SYM((0xAABBU << 8) | (0xDDU + 0))) != 0xAABBU) {
		TP_FAIL("R_SYM() failed: expected 0xAABB, actual 0x%X", t);
	}
	
	if ((t = ELF32_R_TYPE((0xAABBU << 8) | (0xDDU+0))) != 0xDDU) {
		TP_FAIL("R_TYPE() failed: expected 0xDD, actual 0x%X", t);
	}

	if ((t = ELF32_R_INFO(0xAABBU << 8, 0xDDU + 0)) != 0xAABB00DDU) {
		TP_FAIL("R_TYPE() failed: expected 0xDD, actual 0x%X", t);
	}
	
	tet_result(result);
}

void
tcElf64_R_macros(void)
{
	int result = TET_PASS;
	Elf64_Xword t;
	
	TP_ANNOUNCE("Verify ELF64_R_* macros.");

	/*
	 * Test with a scalar value.
	 */
	const Elf64_Xword r_info = 0xAABBCCDD11223344ULL;
	
	if ((t = ELF64_R_SYM(r_info)) != 0xAABBCCDDLL) {
		TP_FAIL("R_SYM() failed: expected 0xAABBCCDD, actual 0x%X.",
			t);
	}
	
	if ((t = ELF64_R_TYPE(r_info)) != 0x11223344LL) {
		TP_FAIL("R_TYPE() failed: expected 0x11223344, actual 0x%X.",
			t);
	}

	if ((t = ELF64_R_INFO(0xBBCCDD, 0xAA)) != 0x00BBCCDD000000AAULL) {
		TP_FAIL("R_INFO(0xBBCCDD, 0xAA) failed: expected "
			" 0x00BBCCDD000000AA, actual 0x%lX", t);
	}

	/*
	 * Test with expression values.
	 *
	 * This is intended to catch parenthesization errors in these
	 * macros.
	 */
	if ((t = ELF64_R_SYM((0xAABBCCDDULL << 32) | (0x11223344U + 0))) !=
	    0xAABBCCDDULL) {
		TP_FAIL("R_SYM() failed: expected 0xAABBCCDD, actual 0x%lX",
			t);
	}
	
	if ((t = ELF64_R_TYPE((0xAABBCCDDULL << 32) | (0x11223344U + 0))) !=
	    0x11223344ULL) {
		TP_FAIL("R_TYPE() failed: expected 0x11223344, actual 0x%X",
		t);
	}

	if ((t = ELF64_R_INFO(0xAABBULL << 8, 0x11223344U + 0)) !=
	    0x00AABB0011223344ULL) {
		TP_FAIL("R_INFO() failed: expected 0x00AABB0011223344, "
			"actual 0x%lX", t);
	}

	tet_result(result);
}
