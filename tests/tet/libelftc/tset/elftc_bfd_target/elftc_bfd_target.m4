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

#include <libelftc.h>

#include "tet_api.h"

include(`elfts.m4')

/*
 * The set of target names that -lelftc should know about.
 */
static const char *known_target_names[] = {
	"binary",
	"efi-app-ia32",
	"efi-app-loongarch64",
	"efi-app-x86_64",
	"elf32-avr",
	"elf32-big",
	"elf32-bigarm",
	"elf32-bigmips",
	"elf32-i386",
	"elf32-i386-freebsd",
	"elf32-ia64-big",
	"elf32-little",
	"elf32-littlearm",
	"elf32-littlemips",
	"elf32-loongarch",
	"elf32-powerpc",
	"elf32-powerpc-freebsd",
	"elf32-powerpcle",
	"elf32-riscv",
	"elf32-sh",
	"elf32-sh-linux",
	"elf32-sh-nbsd",
	"elf32-shbig-linux",
	"elf32-shl",
	"elf32-shl-nbsd",
	"elf32-sparc",
	"elf32-tradbigmips",
	"elf32-tradlittlemips",
	"elf64-alpha",
	"elf64-alpha-freebsd",
	"elf64-big",
	"elf64-bigmips",
	"elf64-ia64-big",
	"elf64-ia64-little",
	"elf64-little",
	"elf64-littleaarch64",
	"elf64-littlemips",
	"elf64-loongarch",
	"elf64-loongarch-freebsd",
	"elf64-powerpc",
	"elf64-powerpc-freebsd",
	"elf64-powerpcle",
	"elf64-riscv",
	"elf64-riscv-freebsd",
	"elf64-sh64",
	"elf64-sh64-linux",
	"elf64-sh64-nbsd",
	"elf64-sh64big-linux",
	"elf64-sh64l",
	"elf64-sh64l-nbsd",
	"elf64-sparc",
	"elf64-sparc-freebsd",
	"elf64-tradbigmips",
	"elf64-tradlittlemips",
	"elf64-x86-64",
	"elf64-x86-64-freebsd",
	"ihex",
	"pei-i386",
	"pei-x86-64",
	"srec",
	"symbolsrec",
};

void
tcKnownTargetNames(void)
{
	const size_t n_targets =
		sizeof(known_target_names) / sizeof(known_target_names[0]);
	
	TP_ANNOUNCE("elftc_bfd_find_target() succeeds for %zu known targets.",
	    n_targets);

	int result = TET_PASS;

	for (size_t n = 0; n < n_targets; n++) {
		const char *name = known_target_names[n];
		if (elftc_bfd_find_target(name) == NULL)
			TP_FAIL("elftc_bfd_find_target(%s) failed.", name);
	}

	tet_result(result);
}

void
tcUnknownTargetName(void)
{
	TP_ANNOUNCE("elftc_bfd_find_target() fails with an unknown target.");

	int result = TET_PASS;

	const char *name = "*unknown*";
	if (elftc_bfd_find_target(name) != NULL)
		TP_FAIL("elftc_bfd_find_target(%s) succeeded unexpectedly.",
		    name);

	tet_result(result);
}
