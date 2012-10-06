! Copyright (C) 2012 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: graphviz help.markup help.syntax kernel ;
IN: graphviz.dot

HELP: write-dot
{ $values
    { "graph" graph } { "path" "a pathname string" } { "encoding" "a character encoding" }    
}
{ $description "Converts " { $snippet "graph" } " into its equivalent DOT code, saving the file to " { $snippet "path" } " using the given character " { $snippet "encoding" } "." } ;

ARTICLE: "graphviz.dot" "Translating Factor graphs into DOT"
"The " { $vocab-link "graphviz.dot" } " vocabulary implements a word to translate Factor " { $link graph } " objects into equivalent DOT code (see " { $url "http://graphviz.org/content/dot-language" } ")."
{ $subsections write-dot }
"Because the data structure of Factor " { $link graph } " objects so closely maps to the DOT language, the translation is straightforward. This also means that rendering Factor " { $link graph } "s using the " { $vocab-link "graphviz.render" } " vocabulary should generally work exactly as though you had written the DOT code to start with."
$nl
"However, there is one limitation. Though Graphviz documentation claims that there's no semantic difference between quoted and unquoted identifiers, there are a few cases that make a difference. " { $link write-dot } " will always quote identifiers, since it's the safest option:"
{ $list
"Quoting prevents clashes with builtin DOT keywords."
"Quoting lets identifiers use whitespace."
}
$nl
"But there are a couple drawbacks:"
{ $list
{ "Node port syntax doesn't work when node names are quoted. Instead, use the edge's " { $snippet "headport" } " and " { $snippet "tailport" } " attributes (see " { $vocab-link "graphviz.attributes" } ")." }
{ "HTML-like labels, which must use angle brackets (" { $snippet "<...>" } ") instead of quotes (" { $snippet "\"...\"" } "), are currently unsupported." }
}
;

ABOUT: "graphviz.dot"
