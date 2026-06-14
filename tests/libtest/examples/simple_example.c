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

/* $Id$ */

#include <stddef.h>

#include "test.h"

/*
 * Function prototypes.
 */
bool tc_setup_helloworld(test_case_state_t *);
bool tc_teardown_helloworld(test_case_state_t);
void tf_helloworld_sayhello(test_case_state_t);
void tf_helloworld_saygoodbye(test_case_state_t);

/*
 * This source defines a single test case named 'helloworld' containing a
 * single test function named 'sayhello' contained in that test case.
 *
 * The test function can be selected by its name 'helloworld_sayhello'.
 *
 * Given the object code generated from this file, the
 * 'make-test-scaffolding' utility will prepare the scaffolding needed
 * to create a executable that can be used to execute these tests.
 *
 * Specifically the 'make-test-scaffolding' utilit will generate test and
 * test case descriptors equivalent to:
 *
 *   struct test_function_descriptor test_functions_helloworld[] = {
 *       {
 *           .tf_name = "helloworld_sayhello",
 *           .tf_func = tf_helloworld_sayhello
 *       },
 *       {
 *           .tf_name = "helloworld_saygoodbye",
 *           .tf_func = tf_helloworld_saygoodbye
 *       }
 *   };
 *
 *   struct test_case_descriptor test_cases[] = {
 *       {
 *            .tc_name = "helloworld",
 *            .tc_tests = test_functions_helloworld
 *       }
 *   };
 */

/*
 * Function names prefixed with 'tc_setup_' are assumed to be test
 * case setup functions.
 */
bool
tc_setup_helloworld(test_case_state_t *state)
{
	(void) state;
	return (true);
}

/*
 * Function names prefixed with 'tc_teardown_' are assumed to be test
 * case teardown functions.
 */
bool
tc_teardown_helloworld(test_case_state_t state)
{
	(void) state;
	return (true);
}

/*
 * Function names prefixed with 'tf_' name test functions.
 */
void
tf_helloworld_sayhello(test_case_state_t state)
{
	(void) state;
	test_result(TEST_PASS);
}

void
tf_helloworld_saygoodbye(test_case_state_t state)
{
	(void) state;
	test_result(TEST_PASS);
}
