=======================================
libtest - a framework for writing tests
=======================================

The ``libtest`` library and related tools offers an framework for
writing tests and mapping tests to the software being tested.

- It offers an API (``test(3)``) for writing tests.
- It implements a test harness (``test_driver(3)``) that executes
  tests, reports test status, and optionally preserves test output in
  an archive for subsequent analysis.
- If offers tools that map individual tests to assertions about the
  behavior of the software being tested, see ``test(5)``, allowing a
  collection of tests to be checked statically for conceptual
  completeness.
- ``libtest``'s scaffolding generator (`make-test-scaffolding(1) <mts_>`_)
  reduces the boilerplate needed for tests.

.. _mts: bin/make-test-scaffolding

Quick Start
===========

The following source code defines a test suite that contains a single
test:

.. code:: c

	/* File: test.c */
	#include "test.h"

	void
	tf_goodbye_world(testcase_state_t ts)
	{
		(void) ts;
		test_result(TEST_PASS);
	}

By convention, test functions are named using a ``tf_`` prefix, short
for 'test function'.

Given an object file compiled from this source code, the
`make-test-scaffolding(1) <mts_>`_ utility would generate scaffolding
describing a single invocable test named "``goodbye_world``".

The argument ``ts`` passed to the test function is a pointer to an
arena holding test-specific state.  This arena is initialized by an
optional user-supplied 'setup' function (see below).  The ``libtest``
framework itself treats a ``testcase_state_t`` as an opaque pointer.

Every test function must call ``test_result(3)`` at least once to
indicate the status of the test.

Test Cases
----------

Test functions that are related to each other can be grouped into test
cases.  The following code snippet defines a test suite with two test
functions contained in a test case named "``helloworld``":

.. code:: c

	/* File: test.c */
	#include "test.h"

	void
	tf_helloworld_hello(testcase_state_t ts)
	{
		(void) ts;
		test_result(TEST_PASS);
	}

	void
	tf_helloworld_goodbye(testcase_state_t ts)
	{
		(void) ts;
		test_result(TEST_FAIL);
	}

The `make-test-scaffolding(1) <mts_>`_ utility can automatically
detect and group test functions into test cases, based on their
names.

Test cases can define their own setup and teardown functions:

.. code:: c

	/* File: test.c continued. */
	struct helloworld_test { .. state used by the helloworld tests .. };

	bool
	tc_setup_helloworld(testcase_state_t *ts)
	{
		*ts = ..allocate a struct helloworld_test.. ;
		return (true);
	}

	bool
	tc_teardown_helloworld(testcase_state_t ts)
	{
		.. deallocate test case state..
		return (true);
	}

The setup function for a test case will be invoked prior to any of the
functions that are part of the test case.  The setup function can
allocate test-specific state on the heap, and set ``*ts`` to point to
this state.  This pointer value is then passed to each test function
when the test function is invoked.  A return value of ``true`` from a
setup function indicates that setup succeeded.  A return of ``false``
indicates that setup failed.  The test functions in the test case are
not run if the setup function does not return ``true``.

The teardown function for a test case will be invoked after the test
functions in the test case are invoked.  This function is responsible
for deallocating the resources allocated by its corresponding setup
function.  This function can return ``false`` to indicate to the test
harness that resources could not be successfully returned.

Building Tests
--------------

Within the `Elftoolchain Project`_'s sources, the ``elftoolchain.test.mk``
rule set handles the process of invoking the `make-test-scaffolding(1)
<mts_>`_ utility and building an test executable.

.. code:: make

	# Example Makefile.

	TOP=	..path to the top of the elftoolchain source tree..

	TEST_SRCS=	test.c

	.include "$(TOP)/mk/elftoolchain.test.mk"


.. _Elftoolchain Project: http://elftoolchain.sourceforge.net/

Further Reading
===============

- The `test(3) <lib/test.3>`_ manual page.
- The `make-test-scaffolding(1) <bin/make-test-scaffolding.1>`_ manual page.
- `Example code <examples/>`_.
