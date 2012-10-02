! Copyright (C) 2012 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit graphviz.render
graphviz.render.private io.directories
io.directories.search.windows io.files.info sequences system ;
IN: graphviz.render.windows

: graphviz-install-directories ( -- directories )
    program-files-directories [
        directory-entries [
            {
                [ directory? ]
                [ name>> "Graphviz" head? ]
                [ name>> ]
            } 1&&
        ] map sift
    ] map concat ;

M: windows default-graphviz-program ( -- path )
    graphviz-install-directories
    standard-layouts [ ".exe" append ] map
    [ find-in-applications ] with find nip ;
