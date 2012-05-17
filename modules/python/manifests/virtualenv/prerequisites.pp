# A single class that installs the prerequisites for virtualenv, which vary per
# platform.  This way, other resources (in python::virtualenv) can just require
# Class['python::virtualenv::prerequisites'].
class python::virtualenv::prerequisites {
    python::misc_python_file {
        "virtualenv.py": ;

        # these two need to be in the same dir as virtualenv.py, or it will
        # want to download them from pypi
        "pip-0.8.2.tar.gz": ;
        "distribute-0.6.26.tar.gz": ;
    }
}
