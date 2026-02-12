flatten:
    mkdir -p assets
    -rm assets/*
    cp docs/*/assets/* assets/

convert-no-mermaid:
    pandoc docs/*/*.md --css docs/style.css --toc --toc-depth=2 -s -o result.html   
 
convert:
    pandoc docs/*/*.md --css docs/style.css --toc --toc-depth=2 -s -F mermaid-filter -o result.html   

[default]
build: flatten convert

build-no-mermaid: flatten convert-no-mermaid

commit:
    git commit -am "upd8"

alias bnm := build-no-mermaid
