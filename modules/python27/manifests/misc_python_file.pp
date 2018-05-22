# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
#
# Download a file from the package dir into the misc-python directory.  This should be
# used sparingly - pip should download most mackages on its own.
define python27::misc_python_file(
    $source_file,
    $filename,
    $recurse                      = false,
) {
    include python27::virtualenv::settings
    include python27::misc_python_dir

    file {
        "${python27::virtualenv::settings::misc_python_dir}/${filename}":
            source    => "${python27::virtualenv::settings::packages_dir_source}/${source_file}",
            backup    => false,
            recurse   => $recurse,
            show_diff => false,
            require   => [
                File[$python27::virtualenv::settings::misc_python_dir],
            ];
    }
}
