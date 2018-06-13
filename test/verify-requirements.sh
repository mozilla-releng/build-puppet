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

for req_file in `find ${MODULES} -wholename "*files*requirements*.txt"`; do
    req_python_version=$(grep python_version $req_file | cut -d: -f2 | xargs)
    if [ "${req_python_version}" != "${python_version}" ]; then
        echo "Skipping ${req_file} because its python version (${req_python_version}) doesn't match python_version (${python_version})"
        continue
    fi

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

    echo "Verify requirements for ${req_file}..."
    while read dependency; do
        hashin -r ${pypi_deps} ${dependency}
        if [ $? != 0 ]; then
            echo "ERROR: couldn't find hashes for ${dependency}. The pinned version is probably invalid."
            rc=1
            continue
        fi
    done < <(cat $req_file | grep -v '^#' | grep -v 'puppet: nodownload' | sed -e 's/.\?#.*//')

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
done

if [ $rc != 0 ]; then
    echo "Hit errors while verifying some requirements. See above for details."
fi
exit ${rc}
