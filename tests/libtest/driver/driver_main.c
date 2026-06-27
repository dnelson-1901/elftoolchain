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

/*
 * This file defines a "main()" that invokes (or lists) the tests that
 * were linked into the current executable, based on command-line
 * options specified.
 */

#include <sys/param.h>
#include <sys/queue.h>
#include <sys/stat.h>

#include <assert.h>
#include <err.h>
#include <errno.h>
#include <fnmatch.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sysexits.h>
#include <time.h>
#include <unistd.h>

#include "_elftc.h"

#include "test.h"
#include "test_case.h"

#include "driver.h"

#if defined(ELFTC_VCSID)
ELFTC_VCSID("$Id$");
#endif

enum test_result test_status = TEST_UNSPECIFIED;

/* Test execution styles. */
struct style_entry {
	enum test_run_style	se_style;
	const char		*se_name;
};

static const struct style_entry known_styles[] = {
	{ TRS_LIBTEST, "libtest" },
	{ TRS_TAP, "tap" },
	{ TRS_ATF, "atf" }
};

/*
 * Parse a test run style.
 *
 * This function returns true if the run style was recognized, or
 * false otherwise.
 */
static bool
parse_run_style(const char *option, enum test_run_style *run_style)
{
	size_t n;

	for (n = 0; n < sizeof(known_styles) / sizeof(known_styles[0]); n++) {
		if (strcasecmp(option, known_styles[n].se_name) == 0) {
			*run_style = known_styles[n].se_style;
			return (true);
		}
	}

	return (false);
}

/*
 * Return the canonical spelling of a test execution style.
 */
static const char *
to_execution_style_name(enum test_run_style run_style)
{
	size_t n;

	for (n = 0; n < sizeof(known_styles) / sizeof(known_styles[0]); n++) {
		if (known_styles[n].se_style == run_style)
			return (known_styles[n].se_name);
	}

	return (NULL);
}

/*
 * Parse a string value containing a positive integral number.
 */
static bool
parse_execution_time(const char *option, long *execution_time) {
	char *end;
	long value;

	if (option == NULL || *option == '\0')
		return (false);

	value = strtol(option, &end, 10);

	/* Check for parse errors. */
	if (*end != '\0')
		return (false);

	/* Reject negative numbers. */
	if (value < 0)
		return (false);

	/* Check for overflows during parsing. */
	if (value == LONG_MAX && errno == ERANGE)
		return (false);

	*execution_time = value;

	return (true);
}

/*
 * Translate a file name to absolute form.
 *
 * The caller needs to free the returned pointer.
 */
static char *
to_absolute_path(const char *filename)
{
	size_t space_needed;
	char *absolute_path;
	char current_directory[PATH_MAX];

	if (filename == NULL || *filename == '\0')
		return (NULL);
	if (*filename == '/')
		return strdup(filename);

	if (getcwd(current_directory, sizeof(current_directory)) == NULL)
		err(1, "getcwd failed");

	/* Reserve space for the slash separator and the trailing NUL. */
	space_needed = strlen(current_directory) + strlen(filename) + 2;
	if ((absolute_path = malloc(space_needed)) == NULL)
		err(1, "malloc failed");
	if (snprintf(absolute_path, space_needed, "%s/%s", current_directory,
	    filename) != (int) (space_needed - 1))
		err(1, "snprintf failed");
	return (absolute_path);
}


/*
 * Display run parameters.
 */

#define	FIELD_NAME_WIDTH	24
#define	INFOLINE(NAME, FLAG, FORMAT, ...)	do {			\
		printf("I %c %-*s " FORMAT,				\
		    (FLAG) ? '!' : '.',					\
		    FIELD_NAME_WIDTH, NAME, __VA_ARGS__);		\
	} while (0)

static void
show_run_header(const struct test_run *tr)
{
	time_t start_time;
	struct test_search_path_entry *path_entry;

	INFOLINE("test-run-name", tr->tr_commandline_flags & TRF_NAME,
	    "%s\n", tr->tr_name);

	INFOLINE("test-execution-style",
	    tr->tr_commandline_flags & TRF_EXECUTION_STYLE,
	    "%s\n", to_execution_style_name(tr->tr_style));

	if (!STAILQ_EMPTY(&tr->tr_search_path)) {
		INFOLINE("test-search-path",
		    tr->tr_commandline_flags & TRF_SEARCH_PATH,
		    "%c", '[');
		STAILQ_FOREACH(path_entry, &tr->tr_search_path, tsp_next) {
			printf(" %s", path_entry->tsp_directory);
		}
		printf(" ]\n");
	}

	INFOLINE("test-run-base-directory",
	    tr->tr_commandline_flags & TRF_BASE_DIRECTORY,
	    "%s\n", tr->tr_runtime_base_directory);

	if (tr->tr_artefact_archive) {
		INFOLINE("test-artefact-archive",
		    tr->tr_commandline_flags & TRF_ARTEFACT_ARCHIVE,
		    "%s\n", tr->tr_artefact_archive);
	}

	printf("I %c %-*s ",
	    tr->tr_commandline_flags & TRF_EXECUTION_TIME ? '=' : '.',
	    FIELD_NAME_WIDTH, "test-execution-time");
	if (tr->tr_max_seconds_per_test == 0)
		printf("unlimited\n");
	else
		printf("%lu\n", tr->tr_max_seconds_per_test);

	printf("I %% %-*s %d\n", FIELD_NAME_WIDTH, "test-case-count",
	    test_case_count);

	if (tr->tr_action == TRA_EXECUTE) {
		start_time = time(NULL);
		printf("I %% %-*s %s", FIELD_NAME_WIDTH,
		    "test-run-start-time", ctime(&start_time));
	}
}

static void
show_run_trailer(const struct test_run *tr)
{
	time_t end_time;

	if (tr->tr_action == TRA_EXECUTE) {
		end_time = time(NULL);
		printf("I %% %-*s %s", FIELD_NAME_WIDTH, "test-run-end-time",
		    asctime(localtime(&end_time)));
	}
}

#undef	INFOLINE
#undef	FIELD_HEADER_WIDTH

static int
show_listing(struct test_run *tr)
{
	const struct test_function_entry *tfe;

	STAILQ_FOREACH(tfe, &tr->tr_functions, tfe_next) {
		if (tfe->tfe_is_selected)
			printf("%s\n", tfe->tfe_canonical_name);
	}

	return (EXIT_SUCCESS);
}

/*
 * Print a brief help message to stdout.
 */
static void
show_usage(const char *argv0)
{
	(void) printf(
		"Usage: %s [options] [test-selector...]\n"
		"\n"
		"Run compiled-in tests and report test status.\n"
		"\n"
		"Supported options:\n"
		"  -R DIR       Set the runtime base directory.\n"
		"  -T SECONDS   Set the test timeout.\n"
		"  -c ARCHIVE   Copy test results to ARCHIVE.\n"
		"  -h           Display this help message and exit.\n"
		"  -l           List selected tests.\n"
		"  -n NAME      Name the test run.\n"
		"  -p PATH      Add PATH to the resource search path.\n"
		"  -s STYLE     Use the specified test execution style.\n"
		"  -v           Be more verbose.\n",
		argv0);

	exit(EX_OK);
}

int
main(int argc, char **argv)
{
	struct test_run *tr;
	int exit_code, option;
	enum test_run_style run_style;

	if ((tr = test_driver_allocate_run()) == NULL)
		err(EX_SOFTWARE, "Memory allocation failed.");

	/* Parse arguments. */
	while ((option = getopt(argc, argv, ":R:T:c:hln:p:s:v")) != -1) {
		switch (option) {
		case 'R':	/* Test runtime directory. */
			if (!test_driver_is_directory(optarg))
				errx(EX_USAGE, "option -%c: argument \"%s\" "
				    "does not name a directory.", option,
				    optarg);
			tr->tr_runtime_base_directory = realpath(optarg, NULL);
			if (tr->tr_runtime_base_directory == NULL)
				err(1, "realpath failed for \"%s\"", optarg);
			tr->tr_commandline_flags |= TRF_BASE_DIRECTORY;
			break;
		case 'T':	/* Max execution time for a test function. */
			if (!parse_execution_time(
			    optarg, &tr->tr_max_seconds_per_test))
				errx(EX_USAGE, "option -%c: argument \"%s\" "
				    "is not a valid execution time value.",
				    option, optarg);
			tr->tr_commandline_flags |= TRF_EXECUTION_TIME;
			break;
		case 'c':	/* The archive holding artefacts. */
			tr->tr_artefact_archive = to_absolute_path(optarg);
			tr->tr_commandline_flags |= TRF_ARTEFACT_ARCHIVE;
			break;
		case 'h':	/* Show usage. */
			show_usage(argv[0]);
			break;
		case 'l':	/* List matching tests. */
			tr->tr_action = TRA_LIST;
			break;
		case 'n':	/* Test run name. */
			if (tr->tr_name)
				free(tr->tr_name);
			tr->tr_name = strdup(optarg);
			tr->tr_commandline_flags |= TRF_NAME;
			break;
		case 'p':	/* Add a search path entry. */
			if (!test_driver_add_search_path(tr, optarg))
				errx(EX_USAGE, "option -%c: argument \"%s\" "
				    "does not name a directory.", option,
				    optarg);
			tr->tr_commandline_flags |= TRF_SEARCH_PATH;
			break;
		case 's':	/* Test execution style. */
			if (!parse_run_style(optarg, &run_style))
				errx(EX_USAGE, "option -%c: argument \"%s\" "
				    "is not a supported test execution style.",
				    option, optarg);
			tr->tr_style = run_style;
			tr->tr_commandline_flags |= TRF_EXECUTION_STYLE;
			break;
		case 'v':
			tr->tr_verbosity++;
			break;
		case ':':
			errx(EX_USAGE,
			    "ERROR: option -%c requires an argument.", optopt);
			break;
		case '?':
			errx(EX_USAGE,
			    "ERROR: unrecognized option -%c", optopt);
			break;
		default:
			errx(EX_USAGE, "ERROR: unspecified error.");
			break;
		}
	}

	if (!test_driver_finish_run_initialization(tr, argv[0], optind < argc))
		err(EX_SOFTWARE, "cannot initialize test driver");
	
	if (tr->tr_verbosity > 0)
		show_run_header(tr);

	/*
	 * If there are selectors present, apply them in sequence to
	 * the list of tests.
	 */
	for (int n = optind; n < argc; n++) {
		const char *pattern = argv[n];
		/* Deselection patterns start with a '^'. */
		const bool is_deselection = (*pattern == '^');
		if (is_deselection) pattern++;
		if (*pattern == '\0')	/* Empty patterns are not allowed. */
			errx(EX_USAGE, "empty test-selector specified.");

		if (tr->tr_verbosity > 0)
			printf("I . %-24s \"%s\"\n", "test-selector", argv[n]);

		struct test_function_entry *tfe = NULL;
		STAILQ_FOREACH(tfe, &tr->tr_functions, tfe_next) {
			if (fnmatch(pattern, tfe->tfe_canonical_name, 0))
				continue; /* Name did not match. */
			if (tfe->tfe_is_selected == !is_deselection)
				continue; /* No change to selection status. */
			if (tr->tr_verbosity > 0) {
				printf("I . %-24s %c %s\n",
				    "test-selection-state",
				    is_deselection ? '-' : '+',
				    tfe->tfe_canonical_name);
			}
			tfe->tfe_is_selected = !is_deselection;
		}
	}

	/* Perform the requested action. */
	switch (tr->tr_action) {
	case TRA_LIST:
		exit_code = show_listing(tr);
		break;

	case TRA_EXECUTE:
	default:
		/* Not yet implemented. */
		exit_code = EX_UNAVAILABLE;
	}

	if (tr->tr_verbosity > 0)
		show_run_trailer(tr);

	test_driver_free_run(tr);

	exit(exit_code);
}
