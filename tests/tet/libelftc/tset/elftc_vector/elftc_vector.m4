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

/*
 * Test elftc_vector(3) APIs.
 */

#include <elftc_vector.h>

#include "tet_api.h"

include(`elfts.m4')

void
tcNewVectorProperties(void)
{
	TP_ANNOUNCE("Verify new vector properties.");

	int result = TET_PASS;

	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	const size_t sz = elftc_vector_size(v);
	if (sz != 0)
		TP_FAIL("Non-zero vector size: %%zu.", sz);

	const size_t cap = elftc_vector_capacity(v);
	if (cap == 0)
		TP_FAIL("Zero capacity vector.");

	elftc_vector_delete(&v);

done:
	tet_result(result);	/* Prior TET_FAILs override. */
}

void
tcNewVectorPropertiesWithSizeHint(void)
{
	TP_ANNOUNCE("Verify properties of a vector created with a size hint.");

	int result = TET_PASS;
	const size_t size_hint = 42;

	elftc_vector_t v = elftc_vector_new(size_hint);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	const size_t sz = elftc_vector_size(v);
	if (sz != 0)
		TP_FAIL("Non-zero new vector size: %%zu.", sz);

	const size_t cap = elftc_vector_capacity(v);
	if (cap != size_hint)
		TP_FAIL("Unexpected capacity expected %zu, got %zu.",
		    size_hint, cap);

	elftc_vector_delete(&v);

done:
	tet_result(result);
}

/*
 * Verify that push and pop work as expected.
 */
void
tcVectorPushPop(void)
{
	TP_ANNOUNCE("Verify push/pop on a single value.");

	int result = TET_PASS;

	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	const uintptr_t reference_value = 0x4041424345444546ULL;

	if (!elftc_vector_push(&v, reference_value))
		TP_FAIL("elftc_vector_push() failed.");

	uintptr_t value = 0;
	if (!elftc_vector_pop(v, &value))
		TP_FAIL("elftc_vector_pop() failed.");

	size_t sz = elftc_vector_size(v);
	if (sz != 0)
		TP_FAIL("elftc_vector_pop(): failed to empty vector.");

	if (value != reference_value)
		TP_FAIL("elftc_vector_pop(): expected 0x%zx, got 0x%zx.",
		    reference_value, value);

	elftc_vector_delete(&v);

done:
	tet_result(result);
}

/*
 * Verify the order of iteration.
 */
static elftc_vector_iteration_control_t
check_fn_1(void *context, uintptr_t value) {
	uintptr_t *v = (uintptr_t *) context;

	if (*v != value) {
		tet_printf("%s: ctx (%zu) != value (%zu)",
		    __func__, *v, value);
		tet_result(TET_FAIL);
	}
	(*v)++;

	return (EVIC_CONTINUE);
}

void
tcVectorIterationOrder(void)
{
	TP_ANNOUNCE("Check iteration order.");

	int result = TET_PASS;
	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	const size_t maxCount = 4;
	for (size_t n = 0; n < maxCount; n++) {
		if (!elftc_vector_push(&v, n))
			TP_FAIL("elftc_vector_push(%zu) failed.", n);
	}

	uintptr_t expected = 0;
	if (!elftc_vector_iterate(v, &expected, check_fn_1))
		TP_FAIL("unexpected iteration failure.");

	elftc_vector_clear(v);
	elftc_vector_delete(&v);

done:
	tet_result(result);
}

/*
 * Verify iteration on an empty vector.
 *
 * The following helper function will fail the test if called.  It should
 * not be called for the empty vector.
 */
static elftc_vector_iteration_control_t
check_fn_2(void *context, uintptr_t value)
{
	(void) context;
	(void) value;
	tet_printf("%s: unexpected call.", __func__);
	tet_result(TET_FAIL);

	return (EVIC_CONTINUE);
}

void
tcVectorIterationEmpty(void)
{
	TP_ANNOUNCE("Check iteration on the empty vector.");

	int result = TET_PASS;
	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	if (!elftc_vector_iterate(v, NULL, check_fn_2))
		TP_FAIL("unexpected iteration failure.");

	elftc_vector_clear(v);
	elftc_vector_delete(&v);

done:
	tet_result(result);
}

/*
 * Verify that iteration can be aborted.
 *
 * The following helper function should be invoked just once, since
 * its EIS_ABORT return should suppress further iteration on the vector.
 */
static elftc_vector_iteration_control_t
check_fn_3(void *context, uintptr_t value)
{
	(void) context;

	if (value != 0x42) {
		tet_printf("%s: unexpected value %zu", __func__, value);
		tet_result(TET_FAIL);
	}

	static bool function_was_invoked = false;
	if (function_was_invoked) {
		tet_printf("%s: unexpected re-invocation");
		tet_result(TET_FAIL);
	}
	function_was_invoked = true;

	return (EVIC_ABORT);
}

void
tcVectorIterationAbort(void)
{
	TP_ANNOUNCE("Verify that iterations are aborted successfully.");

	int result = TET_PASS;
	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	/* Add two elements to the vector. */
	if (!elftc_vector_push(&v, 0x42))
		TP_FAIL("vector-push failed.");
	if (!elftc_vector_push(&v, 0x42))
		TP_FAIL("vector-push failed.");

	if (elftc_vector_iterate(v, NULL, check_fn_3))
		TP_FAIL("unexpected success of iteration.");

	elftc_vector_clear(v);
	elftc_vector_delete(&v);

done:
	tet_result(result);
}

/*
 * Verify that additions beyond the initial capacity work as expected.
 */
void
tcVectorResizeBeyondCapacity(void)
{
	TP_ANNOUNCE("Verify resize beyond installed capacity.");

	int result = TET_PASS;
	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("vector-allocation failed.");
		goto done;
	}

	const size_t initial_capacity = elftc_vector_capacity(v);
	const size_t test_capacity = initial_capacity + 42;
	for (size_t n = 0; n < test_capacity; n++) {
		tet_printf("Pushing %zu", n);
		if (!elftc_vector_push(&v, n))
			TP_FAIL("elftc_vector_push(%zu) failed.", n);
	}

	if (elftc_vector_size(v) != test_capacity)
		TP_FAIL("expected vector-size %zu, got %zu", test_capacity,
			elftc_vector_size(v));

	elftc_vector_clear(v);
	elftc_vector_delete(&v);

done:
	tet_result(result);
}

/*
 * Verify iteration via the iteration API.
 */

void
tcVectorIterationAPI(void)
{
	TP_ANNOUNCE("Verify operation of the iterator API.");

	int result = TET_UNRESOLVED;

	elftc_vector_t v = elftc_vector_new(0);
	if (v == NULL) {
		TP_UNRESOLVED("Vector allocation failed.");
		goto unresolved;
	}

	const size_t cap = elftc_vector_capacity(v);

	/* Add some content to the vector. */
	for (size_t n = 0; n < cap; n++) {
		if (!elftc_vector_push(&v, n))
			TP_FAIL("vector-push(%zu) failed.", n);
	}

	/*
	 * Now iterate through the vector using the iterator API.
	 */
	elftc_vector_iterator_t it = elftc_vector_iterator_new(v);
	if (it == NULL) {
		TP_FAIL("Failed to allocate an iterator.");
		goto done;
	}

	for (size_t n = 0; n < cap; n++) {
		uintptr_t value = ~0UL;
		if (!elftc_vector_iterator_next(it, &value))
			TP_FAIL("iterator failed at iteration %zu", n);
		if (value != n)
			TP_FAIL("Unexpected iteration value: expected %zu, "
			    "got %zu", n, value);
	}

	result = TET_PASS;

	elftc_vector_iterator_delete(&it);

done:
	elftc_vector_clear(v);
	elftc_vector_delete(&v);

unresolved:
	tet_result(result);
}
