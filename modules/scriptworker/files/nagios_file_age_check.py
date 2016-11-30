#!/usr/bin/env python

"""
Checks for the existence and age of specific files.

Allow file age to be defined as warning and critical arguments.

You can either:
- Specify one file to check
- Give the path to a file, that contains a newline-separated list
  of the files to check.

This script will produce a multi-line nagios report in either case.

Attributes:
    STATUS_CODE (dict): a mapping of status strings to the exit codes nagios
        requires
    DEFAULT_WARNING (int): The default warning threshold, if none is given
    DEFAULT_CRITICAL (int): The default critical alarm threshold, if none is
        given


"""
import os
import sys
import time
import argparse

# Nagios plugin exit codes
STATUS_CODE = {
    'OK': 0,
    'WARNING': 1,
    'CRITICAL': 2,
    'UNKNOWN': 3,
}

DEFAULT_WARNING = 45
DEFAULT_CRITICAL = 60


def file_age_check(filename, warning, critical, optional):
    """file_age_check.

    Checks the age and existence of a given filename

    Args:
      filename (str): containing a full path
      warning (int): time in seconds over which to issue a warning.
      critical (int): time in seconds over which to issue critical.

    Returns:
      tuple:
        (nagios status code from STATUS_CODE, message string)
    """
    if not os.path.isfile(filename):
        if optional:
            return STATUS_CODE['OK'], "{0} doesn't exist and that's ok".format(filename)
        else:
            return STATUS_CODE['CRITICAL'], "{0} does not exist".format(filename)

    try:
        st = os.stat(filename)
    except OSError as excp:
        return STATUS_CODE['UNKNOWN'], "{0}: {1}".format(filename, excp)
    current_time = time.time()
    age = current_time - st.st_mtime

    if age >= critical:
        msg = "{0} is too old {1}/{2} seconds".format(
            filename, int(age), critical)
        return STATUS_CODE['CRITICAL'], msg
    elif age >= warning:
        msg = "{0} is getting too old {1}/{2} seconds".format(
            filename, int(age), warning)
        return STATUS_CODE['CRITICAL'], msg
    else:
        msg = "{0} is ok, {1}/{2} seconds old".format(
            filename, int(age), critical)
        return STATUS_CODE['OK'], msg


def get_args():
    """Parse command-line arguments."""
    argp = argparse.ArgumentParser(description=__doc__)
    argp.add_argument('-w', '--warning', type=int, default=DEFAULT_WARNING,
                      help='warn if older than this many minutes')
    argp.add_argument('-c', '--critical', type=int, default=DEFAULT_CRITICAL,
                      help='critical if older than this many minutes')

    argp.add_argument('-o', '--optional', action='store_true',
                      help="If set, don't error if the file is missing")

    arggroup = argp.add_mutually_exclusive_group(required=True)

    arggroup.add_argument('-p', '--path', type=str,
                          help="The full path name to check")
    arggroup.add_argument('-f', '--from-file',
                          type=argparse.FileType('r'),
                          default=sys.stdin,
                          help="File of paths one per line, or - for stdin (default)")

    args = argp.parse_args()

    # convert to seconds for epoch time comparison
    args.warning = args.warning * 60
    args.critical = args.critical * 60

    return args


def run_file_age_checks():
    """Organise the file age checks for nagios.

    Output:
    Prints to stdout
    Exits with appropriate return code
    """
    args = get_args()

    statuses = list()
    messages = list()

    if args.path:
        check_files = [args.path]
    else:
        check_files = [f.strip() for f in args.from_file]

    for filename in check_files:
        status, message = file_age_check(
            filename, args.warning, args.critical, args.optional)
        statuses.append(status)
        messages.append(message)

    exit_code = max(statuses)

    reverse_status_codes = {v: k for k, v in STATUS_CODE.items()}
    service_output = "FILE_AGE {0}".format(reverse_status_codes[exit_code])

    service_output_options = {
        STATUS_CODE['OK']: "All files ok",
        STATUS_CODE['WARNING']: "Some files may be too old, see long output",
        STATUS_CODE['CRITICAL']: "Some files errored, see long output",
        STATUS_CODE['UNKNOWN']: "Unknown error",
    }

    service_output += " - {0}".format(service_output_options[exit_code])

    print("{0}\n{1}\n".format(service_output, "\n".join(sorted(messages))))
    sys.exit(exit_code)


if __name__ == '__main__':
    run_file_age_checks()
