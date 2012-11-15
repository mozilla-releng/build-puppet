define bmm::script {
    file {
        "/opt/bmm/www/scripts/${title}":
            ensure => file,
            content => template("bmm/${title}.erb");
    }
}
