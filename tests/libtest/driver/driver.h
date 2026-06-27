/*-
 * Copyright (c) 2018,2019 Joseph Koshy
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

#ifndef	_LIBTEST_DRIVER_H_
#define	_LIBTEST_DRIVER_H_

#include <sys/queue.h>

#include <limits.h>
#include <stdbool.h>

#include "_elftc.h"

#include "test.h"

#define	TEST_SEARCH_PATH_ENV_VAR	"TEST_PATH"
#define	TEST_TMPDIR_ENV_VAR		"TEST_TMPDIR"

/*
 * Run time data strucrures.
 */

/* The completion status for a test run */
enum test_run_status {
	/*
	 * All selected test functions were successfully invoked and
	 * passed.
	 */
	TR_PASS = 0,

	/*
	 * At least one test function reported a non-PASS status, or
	 * at least one selected test failed to execute either due to
	 * an internal failure, or due to its test case setup/teardown
	 * functions failing.
	 */
	TR_FAIL = 1,
};

/*
 * The 'style' of the run determines the manner in which the test
 * executable reports test status, and emits logs.
 */
enum test_run_style {
	/* Libtest semantics. */
	TRS_LIBTEST,

	/*
	 * Be compatible with the Test Anything Protocol
	 * (http://testanything.org/).
	 */
	TRS_TAP,

	/* Be compatible with NetBSD ATF(9). */
	TRS_ATF
};

/*
 * The action being requested of the test driver.
 */
enum test_run_action {
	TRA_EXECUTE,	/* Execute the selected tests. */
	TRA_LIST,	/* List selected tests. */
};

/*
 * A test function in the executable.
 */
struct test_function_entry {
	STAILQ_ENTRY(test_function_entry) tfe_next;
	
	/*
	 * The function descriptor in the test object.
	 */
	const struct test_function_descriptor *tfe_descriptor;

	/*
	 * The test case descriptor for this function.
	 */
	const struct test_case_descriptor *tfe_test_case;
	
	/*
	 * The canonical name for the function.  Test selectors match
	 * against this name.
	 */
	char *tfe_canonical_name;

	/*
	 * The result of the application of test selectors.
	 */
	bool	tfe_is_selected;
};

STAILQ_HEAD(test_function_list, test_function_entry);

/*
 * Runtime directories to look up data files.
 */
struct test_search_path_entry {
	char *tsp_directory;
	STAILQ_ENTRY(test_search_path_entry)	tsp_next;
};

STAILQ_HEAD(test_search_path_list, test_search_path_entry);

/*
 * Used to track flags that were explicity set on the command line.
 */
enum test_run_flags {
	TRF_BASE_DIRECTORY = 1U << 0,
	TRF_EXECUTION_TIME =  1U << 1,
	TRF_ARTEFACT_ARCHIVE = 1U << 2,
	TRF_NAME = 1U << 3,
	TRF_SEARCH_PATH = 1U << 4,
	TRF_EXECUTION_STYLE = 1U << 5,
};

/*
 * Parameters for the run.
 */
struct test_run {
	/*
	 * Flags tracking the options which were explicitly set.
	 *
	 * This field is a bitmask formed of 'enum test_run_flags' values.
	 */
	unsigned int		tr_commandline_flags;

	/* What the test run should do. */
	enum test_run_action	tr_action;

	/* The desired behavior of the test harness. */
	enum test_run_style	tr_style;

	/* The desired verbosity level. */
	int			tr_verbosity;

	/* The name for this test run. */
	char			*tr_name;

	/*
	 * The absolute path to the directory under which the test is
	 * to be run.
	 *
	 * Each test case will be invoked in some subdirectory of this
	 * directory.
	 */
	char			*tr_runtime_base_directory;

	/*
	 * The test timeout in seconds.
	 *
	 * A value of zero indicates that the test driver should wait
	 * indefinitely for tests.
	 */
	long			tr_max_seconds_per_test;

	/*
	 * If not NULL, An absolute pathname to an archive that will hold
	 * the artefacts created by a test run.
	 */
	char			*tr_artefact_archive;

	/*
	 * Directories to use when resolving non-absolute data file
	 * names.
	 */
	struct test_search_path_list tr_search_path;

	/*
	 * All tests in the test executable.
	 */
	struct test_function_list tr_functions;
};

#ifdef	__cplusplus
extern "C" {
#endif
struct test_run	*test_driver_allocate_run(void);
bool		test_driver_add_search_path(struct test_run *,
    const char *search_path);
void		test_driver_free_run(struct test_run *);
bool		test_driver_is_directory(const char *);
bool		test_driver_finish_run_initialization(struct test_run *_tr,
    const char *_argv0, bool _has_selectors);
#ifdef	__cplusplus
}
#endif

#endif	/* _LIBTEST_DRIVER_H_ */
