class mozpool::httpd {
    httpd::config {
        "mozpool_httpd.conf" :
            contents => template("mozpool/mozpool_httpd_conf.erb");
    }
}
