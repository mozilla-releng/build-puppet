#!/bin/bash

MY_DIR=$(dirname $(readlink -f $0))
MODULES=$(readlink -f "${MY_DIR}/../modules")

python_version=$1

rc=0

# Install the packages we need to install certain Python packages.
apt-get -q update
apt-get -q --yes install gcc automake autoconf libmariadbclient-dev liblzma-dev

# We need virtualenv and hashin to do our work, so we install them
# into the system first
pip install virtualenv hashin

error_messages=""

for req_file in `find ${MODULES} -wholename "*files*requirements*.txt"`; do
    req_python_version=$(grep python_version $req_file | cut -d: -f2 | xargs)
    if [ "${req_python_version}" != "${python_version}" ]; then
        echo "Skipping ${req_file} because its python version (${req_python_version}) doesn't match python_version (${python_version})"
        continue
    fi

    echo "Verifying requirements for ${req_file}..."

    # Initial set-up, including:
    # * Get the right python version
    # * Set up some temporary files/dirs
    # * Set up the virtualenv
    python=$(which python2.7)
    if [ "${req_python_version}" == "36" ]; then
        python=$(which python3.6)
    fi
    virtualenv_dir=$(mktemp -d)
    pypi_deps=$(mktemp)
    log=$(mktemp)
    virtualenv -p ${python} ${virtualenv_dir} >${log} 2>&1
    venv_python="${virtualenv_dir}/bin/${python}"
    pip="${virtualenv_dir}/bin/pip"

    # Before we can verify the requirements file, we need to do some parsing and
    # add hashes to it. In the parsing phase, we remove any packages that are
    # marked as 'nodownload', because they won't be available on pypi. In theory,
    # this could cause bustage, but in practice they are all direct dependencies,
    # and nothing depends on them.
    # A side-effect of running hashin is that any packages which are pinned to invalid
    # versions will throw errors.
    # Once we're done here, we end up with a new requirements file with the nodownload
    # packages removed, and with hashes included.
    hashin_error=0
    while read dependency; do
        hashin -r ${pypi_deps} ${dependency}
        if [ $? != 0 ]; then
            echo "ERROR: couldn't find hashes for ${dependency}. The pinned version is probably invalid."
            rc=1
            hashin_error=1
        fi
    done < <(cat $req_file | grep -v '^#' | grep -v 'puppet: nodownload' | sed -e 's/.\?#.*//')

    if [ ${hashin_error} != 0 ]; then
        continue
    fi

    # Now that we have a more useful requirements file, let's install everything
    # from it! Because hashes are included in it, any transitive dependencies
    # that are missing from the file will cause an error, rather than get
    # implicitly installed.
    ${pip} install -r ${pypi_deps} >>${log} 2>&1

    # if exit code is not 1, print message and mark overall as fail
    if [ $? != 0 ]; then
        echo "ERROR: pip install failed for ${req_file}. See below for details:"
        echo "pip install log:"
        cat ${log}
        echo "requirements file used:"
        cat ${pypi_deps}
        echo
        echo
        rc=1
    fi

    # Now make sure all deps align
    ${pip} check >>${log} 2>&1
    # if exit code is not 1, print message and mark overall as fail
    if [ $? != 0 ]; then
        echo "ERROR: pip check failed for ${req_file}. See below for details:"
        echo "pip log:"
        cat ${log}
        actual_error=`grep "has requirement" ${log}`
        if [ ".$actual_error" == "." ] ; then
            actual_error="can't find the error; please read the full log. sorry\n"
        fi
        # actual_error has a newline already
        error_messages="${error_messages}${req_file}: ${actual_error}"
        echo "requirements file used:"
        cat ${pypi_deps}
        echo
        echo
        rc=1
    fi
done

if [ $rc != 0 ]; then
    echo "Hit errors while verifying some requirements. See above for details."
    echo "$error_messages"
fi
exit ${rc}
