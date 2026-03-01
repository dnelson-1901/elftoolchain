/*-
 * Copyright (c) 2026 Joseph Koshy
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

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>

#include "elftc_vector.h"

/*
 * The following defaults are sized to fit machines with 64-byte cache
 * lines.
 */
#define ELFTC_VECTOR_DEFAULT_SIZE 6
#define ELFTC_VECTOR_DEFAULT_SIZE_INCREMENT 8

struct elftc_vector_head {
	size_t evh_size;	/* Current size of the vector. */
	size_t evh_capacity;	/* Number of elements. */
};

struct elftc_vector {
	struct elftc_vector_head ev_head;
	/* The vector's entries follow. */
	uintptr_t ev_entries[]; /* C99 flexible array member syntax. */
};

/*
 * Helper: returns the memory size of a vector with capacity 'count'.
 */
static size_t
elftc_vector_memory_size(size_t count)
{
	return (sizeof(struct elftc_vector_head) +
	    count * sizeof(uintptr_t));
}

elftc_vector_t
elftc_vector_new(size_t size_hint)
{
	if (size_hint == 0)
		size_hint = ELFTC_VECTOR_DEFAULT_SIZE;

	struct elftc_vector *v;
	
	if ((v = malloc(elftc_vector_memory_size(size_hint))) == NULL)
		return (NULL);
	
	v->ev_head.evh_capacity = size_hint;
	v->ev_head.evh_size = 0;

	return (v);
}

bool
elftc_vector_push(elftc_vector_t *v, uintptr_t elem)
{
	struct elftc_vector *ev = *v;
	
	if (ev->ev_head.evh_size == ev->ev_head.evh_capacity) {
		/* Needs a resize. */
		struct elftc_vector *nv;
		const size_t new_capacity = ev->ev_head.evh_capacity +
		    ELFTC_VECTOR_DEFAULT_SIZE_INCREMENT;

		if ((nv = realloc(ev, elftc_vector_memory_size(new_capacity)))
		    == NULL)
			return (false);

		nv->ev_head.evh_capacity = new_capacity;

		*v = ev = nv;
	}

	assert(ev->ev_head.evh_size < ev->ev_head.evh_capacity);
	
	ev->ev_entries[ev->ev_head.evh_size++] = elem;

	return (true);
}

bool
elftc_vector_pop(elftc_vector_t v, uintptr_t *value)
{
	if (v->ev_head.evh_size == 0)
		return (false);

	*value = v->ev_entries[--v->ev_head.evh_size];

	return (true);
}

void
elftc_vector_clear(elftc_vector_t v)
{
	v->ev_head.evh_size = 0;
}

size_t
elftc_vector_capacity(const elftc_vector_t v)
{
	return (v->ev_head.evh_capacity);
}

size_t
elftc_vector_size(const elftc_vector_t v)
{
	return (v->ev_head.evh_size);
}

void
elftc_vector_delete(elftc_vector_t v)
{
	assert(v->ev_head.evh_size == 0);
	
	free(v);
}

/*
 * Iteration using a callback function.
 */
bool
elftc_vector_iterate(elftc_vector_t v, void *context,
    elftc_vector_iteration_control_t (*fn)(void *_context, uintptr_t _value))
{
	for (size_t n = 0; n < v->ev_head.evh_size; n++) {
		elftc_vector_iteration_control_t status =
		    (*fn)(context, v->ev_entries[n]);

		if (status != EVIC_CONTINUE)
			return (false);
	}

	return (true);
}

/*
 * 'for(..)' loop style iteration.
 */

struct elftc_vector_iterator
{
	struct elftc_vector *evi_vector;
	size_t evi_index;
};
	
elftc_vector_iterator_t
elftc_vector_iterator_new(elftc_vector_t v)
{
	assert(v != NULL);
	
	struct elftc_vector_iterator *it;

	if ((it = malloc(sizeof(*it))) == NULL)
		return (NULL);

	it->evi_index = 0;
	it->evi_vector = v;

	return (it);
}

void
elftc_vector_iterator_delete(elftc_vector_iterator_t it)
{
	assert(it != NULL);
	
	free(it);
}

bool
elftc_vector_iterator_next(elftc_vector_iterator_t it, uintptr_t *value)
{
	struct elftc_vector *v = it->evi_vector;

	if (it->evi_index >= v->ev_head.evh_size)
		return (false);
	
	*value = v->ev_entries[it->evi_index++];
	return (true);
}

void
elftc_vector_free_elements(elftc_vector_t v)
{
	uintptr_t value;

	for (;elftc_vector_pop(v, &value);)
		free((void *) value);
}
