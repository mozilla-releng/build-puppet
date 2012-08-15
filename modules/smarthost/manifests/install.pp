class smarthost::install {
    anchor {
        'smarthost::install::begin': ;
        'smarthost::install::end': ;
    }
    
    Anchor['smarthost::install::begin'] ->
    class {
        packages::postfix: ;
        packages::mailx: ;
    } -> Anchor['smarthost::install::end']
}
