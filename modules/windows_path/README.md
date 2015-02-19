puppet-windows-path
===================

Manage individual entries in the Windows PATH variable as resources, that is, add and remove directories to the PATH in an idempotent manner.

There is already the excellent puppetlabs/registry module to manage registry entries. In the end, the Windows PATH is also a registry entry (or rather two, the system PATH and the user PATH of the current user), so you might wonder why this module exists. However, the registry module (or any other module I know of) does not offer the abstraction of managing a single entry in the PATH (like "C:\Program Files (x86)\puppetlabs\puppet\bin") as a resource. Thus adding specific directories to the PATH in an idempotent manner is a real headache. Naive attempts (for example, by using exec together with SET) might result in duplicated path entries or other issues.

This module solves this problem. Internally, it parses and splits the PATH up into individual entries (directories) and is thus able to check reliably if any given directory already is contained in the PATH or not.

The module is able to manage the system path as well as the user path. The default is to manage the system path.

Installation
------------

Either install the latest release from puppet forge:

    puppet module install basti1302/windows_path

or install the current head from the git repository by going to your puppet modules folder and do

    git clone git@github.com:basti1302/puppet-windows-path.git windows_path

It is important that the folder where this module resisdes is named windows_path, not puppet-windows-path.

Usage
-----

    include windows_path

    # Add an entry to the PATH or verify that it is already there.
    windows_path {'add a PATH entry if it is not there yet':
      ensure      => present,
      directory   => 'C:\this\should\be\added',
    }

    # Remove an existing path entry or verify that the directory is not in the PATH.
    windows_path {'remove a directory from PATH.':
      ensure      => absent,
      directory   => 'C:\this\should\be\removed',
    }

    # By specifying target => user you can manage the path of the current user.
    # target => system (or omitting target) results in the sytem path being managed.
    # Currently it is not possible to manage the path of an arbitrary user. Pull
    # requests are welcome :-)
    windows_path {'Manage the path of the current user.':
      ensure      => absent,
      directory   => 'C:\this\should\be\removed',
      target      => user,
    }

    # The namevar is, of course, the parameter directory.
    windows_path {'C:\add\this\also\please':
        ensure      => present,
    }
