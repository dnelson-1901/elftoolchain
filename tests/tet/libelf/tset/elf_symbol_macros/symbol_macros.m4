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
 * Test ELF{32,64}_ST_* macros.
 */

define(`FN',`dnl
pushdef(`TYPE',ifelse($1,32,Elf32_Byte,Elf64_Byte))dnl
void
tcElf$1_ST_macros(void)
{
	int result = TET_PASS;
	TYPE t;
	
	TP_ANNOUNCE("Test ELF$1_ST_* macros.");

	/*
	 * Test with scalar values.
	 */
	const TYPE st_info = 0x42U;

	if ((t = ELF$1_ST_BIND(st_info)) != 0x4U) {
		TP_FAIL("ST_BIND() failed: expected 0x4, actual 0x%X",
			t);
	}
	
	if ((t = ELF$1_ST_TYPE(st_info)) != 0x2U) {
		TP_FAIL("ST_TYPE() failed: expected 0x2, actual 0x%X",
			t);
	}

	if ((t = ELF$1_ST_INFO(0x4U, 0x2U)) != 0x42U) {
		TP_FAIL("ST_INFO(0x4, 0x2) failed: expected 0x42, "
		        "actual 0x%X", t);
	}

	/*
	 * Test with parameters that are expressions, to catch
	 * parenthesization errors in these macros.
	 */
	 
	if ((t = ELF$1_ST_BIND((7*16) | (7 + 1))) != 0x7U) {
		TP_FAIL("ST_BIND() failed: expected 0x7, actual 0x%X", t);
	}
	
	if ((t = ELF$1_ST_TYPE((7*16) | (7 + 1))) != 0x8U) {
		TP_FAIL("ST_TYPE() failed: expected 0x8, actual 0x%X", t);
	}

	if ((t = ELF$1_ST_INFO(7, 8)) != 0x78U) {
		TP_FAIL("ST_INFO() failed: expected 0x78U, actual 0x%X", t);
	}

	const TYPE st_other = 0x4F;

	if ((t = ELF$1_ST_VISIBILITY(st_other)) != 0x3) {
		TP_FAIL("ST_VISIBILITY() failed: expected 0x3, actual 0x%X",
		    t);
        }

	if ((t = ELF$1_ST_VISIBILITY(0x40 | 0x2)) != 0x2) {
		TP_FAIL("ST_VISIBILITY() failed: expected 0x2, actual 0x%X",
		    t);
        }

	tet_result(result);
}
popdef(`TYPE')dnl
')

FN(32)
FN(64)
