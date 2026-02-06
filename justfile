flatten:
    mkdir -p assets
    -rm assets/*
    cp docs/*/assets/* assets/
 
convert:
    pandoc docs/*/*.md --css docs/style.css --toc --toc-depth=2  -s -F mermaid-filter -o result.html   

[default]
build: flatten convert

commit:
    git commit -am "upd8"
