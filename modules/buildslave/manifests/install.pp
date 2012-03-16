# this class simply invokes the resource type with the production version
class buildslave::install {
    # TODO: include the package::python classes required here

    buildslave::install::version {
        # and the most recent version, kept around for posterity and as
        # a reminder to ensure it's absent when there's a *new* most recent
        # version.
        #"0.8.4-pre-moz1":
        #    active => false;

        "0.8.4-pre-moz2":
            active => true;
    }
}
