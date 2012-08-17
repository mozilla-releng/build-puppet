class smarthost {
    anchor {
        'smarthost::begin': ;
        'smarthost::end': ;
    }
    Anchor['smarthost::begin'] ->
    class {
        smarthost::install: ;
    } -> Anchor['smarthost::end']

    Anchor['smarthost::begin'] ->
    class {
        smarthost::setup: ;
    } -> Anchor['smarthost::end']

    Anchor['smarthost::begin'] ->
    class {
        smarthost::daemon: ;
    } -> Anchor['smarthost::end']
}
