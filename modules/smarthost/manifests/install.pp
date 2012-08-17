class smarthost::install {
    anchor {
        'smarthost::install::begin': ;
        'smarthost::install::end': ;
    }
    
    Anchor['smarthost::install::begin'] ->
    class {
        packages::postfix: ;
    } -> Anchor['smarthost::install::end']

    Anchor['smarthost::install::begin'] ->
    class {
        packages::mailx: ;
    } -> Anchor['smarthost::install::end']
}
