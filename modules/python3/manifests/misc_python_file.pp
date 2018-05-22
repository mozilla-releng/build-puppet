# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
#
# Download a file from the package dir into the misc-python directory.  This should be
# used sparingly - pip should download most mackages on its own.
define python3::misc_python_file(
    $source_file,
    $filename,
    $recurse                      = false,
) {
    include python3::virtualenv::settings
    include python3::misc_python_dir

    file {
        "${python3::virtualenv::settings::misc_python_dir}/${filename}":
            source  => "${python3::virtualenv::settings::packages_dir_source}/${source_file}",
            backup  => false,
            recurse => $recurse,
            require => [
                File[$python3::virtualenv::settings::misc_python_dir],
            ];
    }
}
