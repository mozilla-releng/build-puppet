#! /bin/bash

set -e
source $(cd $(dirname $0) && pwd)/ca_config.sh

host="$1"
targetdir="$2"

# exercise an abundance of caution:
host=$(echo "$host" | tr ' /' --)

LOCKFILE="${master_ssldir}/generate-cert.lock"
lockfile -10 -r10 $LOCKFILE
trap "rm -f $LOCKFILE" INT TERM EXIT

# revoke the old cert, if necessary
if [ -f "$client_certs_dir/$host.crt" ]; then
    h=`openssl x509 -hash -noout -in "$client_certs_dir/$host.crt"`
    mv "$client_certs_dir/$host.crt" "$client_certs_dir/revoke/$h.crt"
    $(cd $(dirname $0) && pwd)/do-revocations.sh
fi

# make a key
openssl genrsa -des3 -out "$targetdir/$host.key.pass" -passout pass:x

# strip its password
openssl rsa -in "$targetdir/$host.key.pass" -out "$targetdir/$host.key" -passin pass:x

# make a signing request
openssl req -new -key "$targetdir/${host}.key" -out "$targetdir/${host}.csr" \
    -subj "/CN=${host}"

# sign it
openssl ca -config "$config" -in "$targetdir/${host}.csr" \
    -notext -out "$targetdir/${host}.crt" \
    -batch -passin "file:${master_ssldir}/ca/private/ca.pass"

# generate public key
openssl rsa -in "$targetdir/$host.key" -pubout \
    -out "$targetdir/${host}.pub"

# keep a copy for posterity
cp -f "$targetdir/${host}.crt" "${master_ssldir}/client_certs/"

# copy CA public cert
cp "$ca_dir/ca_crt.pem" "$targetdir"
# and current CRL
cp "$certdir/ca_crl.pem" "$targetdir"

rm -f "$LOCKFILE"
