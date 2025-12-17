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

#include <inttypes.h>

#include <libelf.h>

#include "tet_api.h"

/*
 * Test ELF{32,64}_M_* macros.
 */

define(`FN',`dnl
pushdef(TYPE,ifelse($1,32,Elf32_Word,Elf64_Xword))dnl
pushdef(FMT,ifelse($1,32,`%" PRIu32 "',`%" PRIu64 "'))dnl
void
tcElf$1_M_macros(void)
{
	int result = TET_PASS;
	TYPE t;
	
	TP_ANNOUNCE("Test ELF$1_M_* macros.");

	/*
	 * Test with scalar values.
	 */
	const TYPE m_info = 0xAABBCCDDUL;

	if ((t = ELF$1_M_SYM(m_info)) != 0xAABBCCU) {
		TP_FAIL("M_SYM() failed: expected 0xAABBCC, actual 0x`'FMT.",
			t);
	}
	
	if ((t = ELF$1_M_SIZE(m_info)) != 0xDDU) {
		TP_FAIL("M_SIZE() failed: expected 0xDD, actual 0x`'FMT.",
			t);
	}

	if ((t = ELF$1_M_INFO(0xBBCCDDU, 0xAAU)) != 0xBBCCDDAAUL) {
		TP_FAIL("M_INFO(0xBBCCDD, 0xAA) failed: expected 0xBBCCDDAA, "
		        "actual 0x`'FMT", t);
	}

	/*
	 * Test with expression parameters.
	 *
	 * This is intended to catch parenthesization errors in these
	 * macros.
	 */
	if ((t = ELF$1_M_SYM((0xAABBU << 8) | (0xDDU + 0))) != 0xAABBU) {
		TP_FAIL("M_SYM() failed: expected 0xAABB, actual 0x`'FMT", t);
	}
	
	if ((t = ELF$1_M_SIZE((0xAABBU << 8) | (0xDDU+0))) != 0xDDU) {
		TP_FAIL("M_TYPE() failed: expected 0xDD, actual 0x`'FMT", t);
	}

	if ((t = ELF$1_M_INFO(0xAABBU << 8, 0xDDU + 0)) != 0xAABB00DDU) {
		TP_FAIL("M_INFO() failed: expected 0xAABB00DD, actual 0x`'FMT", t);
	}
	
	tet_result(result);
}
popdef(`FMT')dnl
popdef(`TYPE')dnl
')

FN(32)
FN(64)
