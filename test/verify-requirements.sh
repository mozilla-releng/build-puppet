#!/bin/bash

MY_DIR=$(pwd)
MODULES=$(readlink -f "${MY_DIR}/../modules")

rc=0

# in order to catch transitive dependencies we need hashes, so maybe try:
# 1) parse requirements file and remove nodownload deps (beacuse they aren't on pypi)
# 2) run the new requirements file through hashin, to add hashes
# 3) pip install the new new requirements file, which should fail if any transitive deps are missing
for req_file in `find ${MODULES} -wholename "*files*requirements*.txt"`; do
    echo "Verify requirements for ${req_file}..."
    virtualenv_dir=$(mktemp -d)
    log=$(mktemp)
    req_python_version=$(grep python_version $req_file | cut -d: -f2 | xargs)
    python=$(which python2.7)
    if [ "${req_python_version}" == "36" ]; then
        python=$(which python3.6)
    fi
    virtualenv -p ${python} ${virtualenv_dir} >${log} 2>&1
    venv_python="${virtualenv_dir}/bin/${python}"
    pip="${virtualenv_dir}/bin/pip"

    ${pip} install -r ${req_file} >>${log} 2>&1
    # if exit code is not 1, print message and mark overall as fail
    if [ $? != 0 ]; then
        echo "ERROR: pip install failed for ${req_file}. See below for details:"
        cat ${log}
        rc=1
    fi
done

exit ${rc}
