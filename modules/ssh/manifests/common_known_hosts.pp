class ssh::common_known_hosts($home, $owner, $group) {
    include concat::setup

    concat {
        "$home/.ssh/known_hosts":
            mode => 0644,
            owner => $owner,
            group => $group,
            require => Class['ssh::setup'];
    }
    ssh::known_host {
        "dev-stage01.srv.releng.scl3.mozilla.com":
            home => $home,
            hostkey => "dev-stage01.srv.releng.scl3.mozilla.com,10.26.48.44 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA80JxNARSnHo9ym5FI2vt/WQPkLTePgHxE9Iwafwz2SvAKs/bcz1rUZm+s1YUJ6Xm4i3w984T6q/KSEqOWcYY3HjZ8rntcehGO8zXIVQRI4U1v1TxCvrwsJ12z9NHNrzX+JGtjyb+5RgODNQm2A6klbu/sgVdwbCxTkvImNb281erYyNuwaZ7CvF2yYFzMYtuR0dGMO02aIzIO3phM2PM7bLtWgDZ/zjiFZcuCVcM6vY75sLYyoXPj+q+oezeU5/cksyInVvcwFJ7Jn5WwRD4anqWrIrKjlVNY6XQbPm5OHdw4mXzct6hrLaYdXloT9tgA/ktZ7NDqL6kxeBjplTQ4Q==";
        "stage.mozilla.org":
            home => $home,
            hostkey => "stage.mozilla.org,10.2.74.116 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA6JfgGmF83VqGJQNJUta7xCP4ZN6z9OITNMfk9E6lYcJmpDWn4JFxQdTj7BwzADwFtYP3jdkZZbYILhZ9OvTKyX1vlmuom9ukKZSdRtv+GwzI1dYNvYca5sC7LWmf/2UiUpwoWC42Ljuwru9mV4xQ2XkiLulDU6TK8wtjTfUp5T0=";
        "symbols1.dmz.phx1.mozilla.com":
            home => $home,
            hostkey => "symbols1.dmz.phx1.mozilla.com,10.8.74.48 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA8C9kssmf2rAl2Y6iS6JONcgArpYJBMVzUwLE8Bd4A4qr1TIqLKUTTSkU3T8/+6lBj8UWmzRNwZ/eXCAquvsm0vSa1PX2shBrcuIi8w8JvyYszTMNseiLJmA7ADZ3NpQFr6KKTyH/JsB+vnbU0lO/KNsUcaFkaSelSrwR8rPmhAxrsxUbWKgSLMCtiaw9m7+WBgh+LpzQJPZh6gbmVWWPi7sQx7XgAsSOxkDQAQR3rCucXAVo/snG993d+etqWZqQzIt1gr2tx326ZywV5p+8lv0tHUtD8GR7lEN5uVp6xzvouXfzrhGIuZNc/GoY1MFBCmBdenF0h3Xvrj0JDHKolw==";
        "aus3-staging.mozilla.org":
            home => $home,
            hostkey => "aus3-staging.mozilla.org,10.8.74.30 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NsitnPbGVF9cNcnrrA5l/VsyMV3+fSL4orH8EkDLaZF0AHzgOa40kYKLqQ/nw+hEvK1Nt/L42IhneD9Cv8+FEoc36AKgHeg4m3EhutOMup5wfci9elonIlXf253tveC4+FCrGn2D/u4mVjAgdFGxGxMTnqvecS8hbuedNS1xXKx6tIGKwpzk4Mi2/CduEeAl5xybSVUdEcWtjNsJIQRawTqUytZ/N222nN+g3eKwBqYBpQIlqkW/kenlZg2eslnqrIMk6obh93RlxcNDkSdhzZh/6mCYxPc6B8dj07oysA8HyVan/0O7JxhhY4Cs/O2hWs6ocPfuR0AQlTFq77pdQ==";
    }
}
