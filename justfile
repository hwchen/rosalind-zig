run bin:
    zig build {{bin}}

cp-data p:
    mv ~/Downloads/rosalind_{{p}}.txt input/{{p}}.txt
