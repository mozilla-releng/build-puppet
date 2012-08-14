class ssh {
    anchor {
        'ssh::begin': ;
        'ssh::end': ;
    }

    Anchor['ssh::begin'] ->
    class {
        'ssh::service': ;
    } -> Anchor['ssh::end']

    Anchor['ssh::begin'] ->
    class {
        'ssh::config': ;
    } -> Anchor['ssh::end']
}
