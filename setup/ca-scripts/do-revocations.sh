#! /bin/bash

set -e
source $(cd $(dirname $0) && pwd)/ca_config.sh

LOCKFILE="${master_ssldir}/do-revocations.lock"
lockfile -10 -r10 $LOCKFILE
trap "rm -f $LOCKFILE" INT TERM EXIT

need_crl=false
shopt -s nullglob
cd "$client_certs_dir/revoke"
for crt in *.crt; do
    openssl ca -revoke $crt -config "$config" \
            -keyfile "$ca_dir/ca_key.pem" \
            -passin file:"$ca_dir/private/ca.pass" -cert "$ca_dir/ca_crt.pem"
    rm "$crt"
    need_crl=true
done

# check the date on the CRL, regenerting if it's over a day old
if [ -n "$(find $crl -mtime +1 2>/dev/null)" ]; then
    need_crl=true
fi

if [ ! -e "$crl" ]; then
    need_crl=true
fi

# if we revoked anything or otherwise need to re-gen the CRL, do it
if $need_crl; then
    openssl ca -gencrl -config "$config" \
            -crldays 3650 \
            -keyfile "$ca_dir/ca_key.pem" \
            -passin file:"$ca_dir/private/ca.pass" \
            -cert "$ca_dir/ca_crt.pem" -out "$crl"
    cp -a $crl $crl_push_dest
    chmod 644 $crl_push_dest
fi

rm -f "$LOCKFILE"
