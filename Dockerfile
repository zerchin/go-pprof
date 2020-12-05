FROM golang:1.15

RUN apt-get update && \
    apt-get install -y graphviz && \
    apt-get clean 

COPY flameGraph/stackcollapse-go.pl /usr/local/bin/stackcollapse-go.pl
COPY flameGraph/flamegraph.pl /usr/local/bin/flamegraph.pl

