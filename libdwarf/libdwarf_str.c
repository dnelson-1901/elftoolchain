/*-
 * Copyright (c) 2009,2010,2023 Kai Wang
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
 */

#include "_libdwarf.h"

ELFTC_VCSID("$Id$");

#define	_INIT_DWARF_STRTAB_SIZE 1024

int
_dwarf_strtab_add(Dwarf_Debug dbg, char *string, uint64_t *off,
    Dwarf_Error *error)
{
	size_t len;

	assert(dbg != NULL && string != NULL);

	len = strlen(string) + 1;
	while (dbg->dbg_strtab_size + len > dbg->dbg_strtab_cap) {
		dbg->dbg_strtab_cap *= 2;
		dbg->dbg_strtab = realloc(dbg->dbg_strtab,
		    (size_t) dbg->dbg_strtab_cap);
		if (dbg->dbg_strtab == NULL) {
			DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
			return (DW_DLE_MEMORY);
		}
	}

	if (off != NULL)
		*off = dbg->dbg_strtab_size;

	memcpy(&dbg->dbg_strtab[dbg->dbg_strtab_size], string, len - 1);
	dbg->dbg_strtab_size += len;
	dbg->dbg_strtab[dbg->dbg_strtab_size - 1] = '\0';

	return (DW_DLE_NONE);
}

char *
_dwarf_strtab_get_table(Dwarf_Debug dbg)
{

	assert(dbg != NULL);

	return (dbg->dbg_strtab);
}

char *
_dwarf_strtab_get_line_table(Dwarf_Debug dbg)
{

	assert(dbg != NULL);

	return (dbg->dbg_line_strtab);
}

static int
_dwarf_str_offsets_init(Dwarf_Debug dbg, Dwarf_Error *error)
{
	Dwarf_Section *ds;
	Dwarf_StrOffsets *str_off;
	Dwarf_Half version;
	uint64_t offset, length;
	int dwarf_size;

	assert(dbg != NULL);

	dbg->dbg_str_offsets = NULL;

	if ((ds = _dwarf_find_section(dbg, ".debug_str_offsets")) == NULL)
		return (DW_DLE_NONE);

	offset = 0;

	/* Read in the table header. */
	length = dbg->read(ds->ds_data, &offset, 4);
	if (length == 0xffffffff) {
		dwarf_size = 8;
		length = dbg->read(ds->ds_data, &offset, 8);
	} else
		dwarf_size = 4;

	version = dbg->read(ds->ds_data, &offset, 2);
	if (version != 5) {
		DWARF_SET_ERROR(dbg, error, DW_DLE_VERSION_STAMP_ERROR);
		return (DW_DLE_VERSION_STAMP_ERROR);
	}

	if ((str_off = calloc(1, sizeof(*str_off))) == NULL) {
		DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
		return (DW_DLE_MEMORY);
	}

	/* 2 byte padding. */
	offset += 2;

	str_off->so_length = length;
	str_off->so_version = version;
	str_off->so_header_size = offset;
	str_off->so_dwarf_size = dwarf_size;
	str_off->so_data = ds->ds_data;

	dbg->dbg_str_offsets = str_off;

	return (DW_DLE_NONE);
}

static int
_dwarf_find_cu_str_offsets_base(Dwarf_Debug dbg, Dwarf_CU cu,
    uint64_t *offset_basep, Dwarf_Error *error)
{
	Dwarf_Attribute at;
	Dwarf_Die cu_die;
	int ret;

	assert(dbg->dbg_str_offsets != NULL);

	if (!cu->cu_stroff_base_valid) {
		if ((ret = dwarf_siblingof(dbg, 0, &cu_die, error)) !=
		    DW_DLV_OK) {
			DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
			return (DW_DLE_NO_ENTRY);
		}

		if ((at = _dwarf_attr_find(cu_die, DW_AT_str_offsets_base)) !=
		    NULL) {
			cu->cu_stroff_base = at->u[0].u64;
		} else {
			/*
			 * No DW_AT_str_offsets_base found. Use header size
			 * instead.
			 */
			cu->cu_stroff_base =
			    dbg->dbg_str_offsets->so_header_size;
		}
		cu->cu_stroff_base_valid = 1;
		dwarf_dealloc(dbg, cu_die, DW_DLA_DIE);
	}
	*offset_basep = cu->cu_stroff_base;

	return (DW_DLE_NONE);
}

int
_dwarf_read_indexed_str(Dwarf_Debug dbg, Dwarf_CU cu, uint64_t index,
    char **str_p, Dwarf_Error *error)
{
	Dwarf_StrOffsets *so;
	uint64_t offset, offsets_base, strtab_offset;
	int ret;

	if (dbg->dbg_str_offsets == NULL) {
		if ((ret = _dwarf_str_offsets_init(dbg, error)) != DW_DLE_NONE)
			return (ret);
		if (dbg->dbg_str_offsets == NULL) {
			DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
			return (DW_DLE_NO_ENTRY);
		}
	}

	if ((ret = _dwarf_find_cu_str_offsets_base(dbg, cu, &offsets_base,
	    error)) != DW_DLE_NONE)
		return (ret);

	so = dbg->dbg_str_offsets;
	/* Caculate where to read from string offsets array. */
	offset = offsets_base + so->so_dwarf_size * index;
	/* Read from the str offsets array to get offset into string table. */
	strtab_offset = dbg->read(so->so_data, &offset, so->so_dwarf_size);
	*str_p = _dwarf_strtab_get_table(dbg) + strtab_offset;

	return (DW_DLE_NONE);
}

int
_dwarf_strtab_init(Dwarf_Debug dbg, Dwarf_Error *error)
{
	Dwarf_Section *ds;

	assert(dbg != NULL);

	if (dbg->dbg_mode == DW_DLC_READ || dbg->dbg_mode == DW_DLC_RDWR) {
		ds = _dwarf_find_section(dbg, ".debug_str");
		if (ds == NULL) {
			dbg->dbg_strtab = NULL;
			dbg->dbg_strtab_cap = dbg->dbg_strtab_size = 0;
			return (DW_DLE_NONE);
		}

		dbg->dbg_strtab_cap = dbg->dbg_strtab_size = ds->ds_size;

		if (dbg->dbg_mode == DW_DLC_RDWR) {
			if ((dbg->dbg_strtab = malloc((size_t) ds->ds_size)) ==
			    NULL) {
				DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
				return (DW_DLE_MEMORY);
			}
			memcpy(dbg->dbg_strtab, ds->ds_data, ds->ds_size);
		} else
			dbg->dbg_strtab = (char *) ds->ds_data;

		ds = _dwarf_find_section(dbg, ".debug_line_str");
		if (ds != NULL) {
			dbg->dbg_line_strtab = (char *) ds->ds_data;
		}
	} else {
		/* DW_DLC_WRITE */

		dbg->dbg_strtab_cap = _INIT_DWARF_STRTAB_SIZE;
		dbg->dbg_strtab_size = 0;

		if ((dbg->dbg_strtab = malloc((size_t) dbg->dbg_strtab_cap)) ==
		    NULL) {
			DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
			return (DW_DLE_MEMORY);
		}

		dbg->dbg_strtab[0] = '\0';
	}

	return (DW_DLE_NONE);
}

void
_dwarf_str_offsets_cleanup(Dwarf_Debug dbg)
{

	assert(dbg != NULL);

	if (dbg->dbg_str_offsets)
		free(dbg->dbg_str_offsets);
}

void
_dwarf_strtab_cleanup(Dwarf_Debug dbg)
{

	assert(dbg != NULL);

	if (dbg->dbg_mode == DW_DLC_RDWR || dbg->dbg_mode == DW_DLC_WRITE)
		free(dbg->dbg_strtab);
}

int
_dwarf_strtab_gen(Dwarf_P_Debug dbg, Dwarf_Error *error)
{
	Dwarf_P_Section ds;
	int ret;

	assert(dbg != NULL);

	if ((ret = _dwarf_section_init(dbg, &ds, ".debug_str", 0, error)) !=
	    DW_DLE_NONE)
		return (ret);

	if (dbg->dbg_strtab_size > ds->ds_cap) {
		ds->ds_data = realloc(ds->ds_data,
		    (size_t) dbg->dbg_strtab_size);
		if (ds->ds_data == NULL) {
			_dwarf_section_free(dbg, &ds);
			DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
			return (DW_DLE_MEMORY);
		}
		ds->ds_cap = dbg->dbg_strtab_size;
	}

	memcpy(ds->ds_data, dbg->dbg_strtab, dbg->dbg_strtab_size);
	ds->ds_size = dbg->dbg_strtab_size;

	/*
	 * Inform application the creation of .debug_str ELF section.
	 * Note that .debug_str use a different format than usual ELF
	 * string table, so it should not have SHT_STRTAB as its type.
	 */
	ret = _dwarf_section_callback(dbg, ds, SHT_PROGBITS, 0, 0, 0, error);

	return (ret);
}
