class smarthost {
    anchor {
        'smarthost::begin': ;;
        'smarthost::end': ;;
    }
    Anchor['smarthost::begin'] ->
    class {
        smarthost::install: ;
        smarthost::setup: ;
        smarthost::daemon: ;
    } -> Anchor['smarthost::end']
}
