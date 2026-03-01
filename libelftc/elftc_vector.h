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

#ifndef _ELFTC_VECTOR_H_
#define _ELFTC_VECTOR_H_

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/*
 * Opaque types implementing a dynamically-sized vector, and
 * an iterator over such a vector.
 */
typedef struct elftc_vector *elftc_vector_t;
typedef struct elftc_vector_iterator *elftc_vector_iterator_t;

/*
 * Iteration control values for use with elftc_vector_iterate(3).
 */
typedef enum elftc_vector_iteration_control {
	EVIC_CONTINUE,	/* Continue iterating. */
	EVIC_ABORT,	/* Abort the iteration. */
} elftc_vector_iteration_control_t;

elftc_vector_t	elftc_vector_new(size_t _size_hint);
void	elftc_vector_delete(elftc_vector_t _v);

size_t	elftc_vector_size(const elftc_vector_t v);
size_t	elftc_vector_capacity(const elftc_vector_t v);

bool	elftc_vector_push(elftc_vector_t *_v, uintptr_t _val);
bool	elftc_vector_pop(elftc_vector_t _v, uintptr_t *_val);

void	elftc_vector_clear(elftc_vector_t _v);

/*
 * Iteration over the contents of the vector.
 */
bool	elftc_vector_iterate(elftc_vector_t v, void *_ctx,
    elftc_vector_iteration_control_t (*_cb)(void *_ctx, uintptr_t _val));

elftc_vector_iterator_t elftc_vector_iterator_new(elftc_vector_t _v);
void	elftc_vector_iterator_delete(elftc_vector_iterator_t _it);
bool	elftc_vector_iterator_next(elftc_vector_iterator_t _it,
	    uintptr_t *_val);

/*
 * Convenience routine for use when the vector's contents are pointers
 * allocated by prior calls to malloc(3).
 */
void	elftc_vector_free_elements(elftc_vector_t _v);

#endif /* _ELFTC_VECTOR_H_ */
