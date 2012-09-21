# CA top directory
master_ssldir="/home/buildduty/aws/CA"
client_certs_dir="${master_ssldir}/client_certs"
ca_dir="${master_ssldir}/ca"
certdir="${master_ssldir}/certdir"
crl="$certdir/ca_crl.pem"
# OpenSSL config file
config="$ca_dir/openssl.conf"
# Where to publish the CRL file
crl_push_dest=/var/www/html/builds/aws-support/aws_ca_crl.pem
