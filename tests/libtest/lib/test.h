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
 * Values encoding the result of a test.
 *
 * The meaning of these values is:
 *
 * - TEST_UNSPECIFIED  A test result is yet to be specified.  Test functions
 *                     start in this state.
 * - TEST_PASS         The test succeeded.  Assertions associated with the
 *                     test are considered to be proven.
 * - TEST_FAIL         The test failed.  Assertions associated with the test
 *                     are disproven.
 * - TEST_UNRESOLVED   The test function could not proceed meaningfully for
 *                     whatever reason.  Assertions associated with the test
 *                     are not proven.
 *
 * These values are passed to the 'test_result()' API.  Multiple calls to
 * to 'test_result()' are permitted with the following behavior:
 *
 * - A result of TEST_FAIL overrides any prior test status.
 * - A result of TEST_UNRESOLVED overides a prior TEST_PASS status, but not
 *   a prior TEST_FAIL status.
 *
 * It is a testing error for the test function to return with test state as
 * TEST_UNSPECIFIED.
 */
enum test_result {
	TEST_UNSPECIFIED = -1,	/* Initial test state. */
	TEST_PASS = 0,		/* Test passed. */
	TEST_UNRESOLVED = 1,	/* Test status is indeterminate. */
	TEST_FAIL = 2,		/* The test failed. */ 
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
 * The type of a test case setup function.
 *
 * Defining a setup function is optional for a test case.
 *
 * If a setup function is defined, it will be called prior to invoking the
 * test functions within the test case.
 *
 * This function can set '*_state' to a memory area holding test state to be
 * passed to test functions.
 *
 * The return value from the setup function determines whether the test
 * functions in the test case are called:
 *
 * - A return value of 'true' indicates that test execution should
 *   proceed.  Test functions in the test case will be invoked with
 *   the value in '*_state'.
 * - A return value other than 'true' indicates that setup failed.
 *   Test functions in the test case will not be invoked, and test case
 *   execution will proceed directly to the teardown phase.
 */
typedef	bool	test_case_setup_function_t(test_case_state_t *_state);

/*
 * The type for a test function.
 *
 * Test functions will be invoked with the state that had been set by the
 * test case setup function.
 * 
 * Test functions are required to call 'test_result()' prior to returning.
 */
typedef	void	test_function_t(test_case_state_t _state);

/*
 * The type of a test case teardown function.
 *
 * If defined for a test case, this function will be called after
 * invoking the test functions in the test case.  The function is
 * responsible for deallocating the resources that the setup function
 * had allocated.  It is passed the state that had been allocated by
 * the test case setup function.
 *
 * A return value of 'true' signals that the resources allocated at
 * setup time were successfully reclaimed.  Any other return value
 * signals that the test case's resources were not fully reclaimed,
 * indicating a problem with the test suite itself.
 */
typedef bool	test_case_teardown_function_t(test_case_state_t state);

#ifdef	__cplusplus
extern "C" {
#endif

/*
 * Report test status to the test framework.
 *
 * A test function needs to call 'test_result()' at least once prior to
 * returning to its caller.
 */
void	test_result(enum test_result _result);

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
