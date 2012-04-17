Most of the scripts in this directory serve different purposes, but contain
common components and are built from templates.

The notable exception is puppetize.sh, which is actually fetched verbatim from
hg, and thus not templated.

This directory uses erb (which comes with puppet) to build the scripts.  Just
run 'make'
