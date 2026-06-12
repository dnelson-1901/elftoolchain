/*-
 * Copyright (c) 2018, Joseph Koshy
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer
 *    in this position and unchanged.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef	_LIBTEST_TEST_H_
#define	_LIBTEST_TEST_H_

#include <stdbool.h>

/*
 * The return values from test functions.
 *
 * - TEST_PASS : The assertion(s) in the test function passed.
 * - TEST_FAIL : At least one assertion in the test function failed.
 * - TEST_UNRESOLVED : The assertions in the test function could not be
 *                     checked for some reason.
 */
enum test_result {
	TEST_PASS = 0,
	TEST_FAIL = 1,
	TEST_UNRESOLVED = 2
};

/*
 * A 'test_case_state_t' is a handle to resources shared by the test functions
 * that make up a test case. A 'test_case_state_t' is allocated by the test
 * case setup function and is deallocated by the test case teardown function.
 *
 * The test(3) framework treats a 'test_case_state_t' as an opaque value.
 */
typedef	void *test_case_state_t;

/*
 * A test case setup function.
 *
 * If defined for a test case, this function will be called prior to
 * the execution of an of the test functions within the test case.  The
 * test functions that comprise the test case will not be run if the
 * setup function returns a value other 'true'.
 *
 * The function can set '*state' to a memory area holding test state to
 * be passed to test functions.
 *
 * If the test case does not define a setup function, then a default
 * no-op setup function will be used and a NULL pointer will be used
 * when invoking the test case's test functions.
 */
typedef bool	test_case_setup_function_t(test_case_state_t *state);

/*
 * A test function.
 *
 * This function will be invoked with the state that had been set by the
 * test case setup function. The function returns TEST_PASS to report that
 * its test succeeded or TEST_FAIL otherwise. In the event the test could
 * not be executed, it can return TEST_UNRESOLVED.
 */
typedef	enum test_result	test_function_t(test_case_state_t state);

/*
 * A test case teardown function.
 *
 * If defined for a test case, this function will be called after the
 * execution of the test functions in the test case.  It is passed the
 * state that had been allocated by the test case setup function, and is
 * responsible for deallocating the resources that the setup function
 * had allocated.
 */
typedef bool	test_case_teardown_function_t(test_case_state_t state);

#ifdef	__cplusplus
extern "C" {
#endif

/*
 * Write a progress report to the test log.
 *
 * This function takes a printf(3)-like format string and associated
 * arguments.
 */
int	test_report_progress(const char *format, ...);

#ifdef	__cplusplus
}
#endif

#endif	/* _LIBTEST_TEST_H_ */
