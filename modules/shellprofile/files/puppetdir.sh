# /etc/profile.puppet.d is puppet-managed, so run any # scripts in there
for i in /etc/profile.puppet.d/*.sh ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then
            . "$i"
        else
            . "$i" >/dev/null 2>&1
        fi
    fi
done
