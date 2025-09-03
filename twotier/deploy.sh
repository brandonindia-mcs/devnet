docker login -u contosorealtime -p `cat $DOCKERHUBPAT`
compose build
compose push