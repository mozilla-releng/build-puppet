# Tweak font appearance
class tweaks::fonts {
    include users::builder

    case $::operatingsystem {
        Ubuntu: {
            file {
                "$::users::builder::home/.fonts.conf":
                    owner  => $::users::builder::username,
                    group  => $::users::builder::group,
                    source => "puppet:///modules/tweaks/fonts.conf";
            }
        }
    }
}
