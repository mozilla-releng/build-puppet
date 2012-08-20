# A single class that installs the prerequisites for virtualenv, which vary per
# platform.  This way, other resources (in python::virtualenv) can just require
# Class['python::virtualenv::prerequisites'].
class python::virtualenv::prerequisites {
    anchor {
        'python::virtualenv::prerequisites::begin': ;
        'python::virtualenv::prerequisites::end': ;
    }

    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "virtualenv.py": ;
    } -> Anchor['python::virtualenv::prerequisites::end']

    # these two need to be in the same dir as virtualenv.py, or it will
    # want to download them from pypi

    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "pip-0.8.2.tar.gz": ;
    } -> Anchor['python::virtualenv::prerequisites::end']

    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "distribute-0.6.24.tar.gz": ; # the virtualenv.py above looks for this version
    } -> Anchor['python::virtualenv::prerequisites::end']
}
