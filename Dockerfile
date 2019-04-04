# Build Stage
FROM zackijack/alpine-golang-build-image:latest:1.11.6 AS build-stage

LABEL app="build-ofood"
LABEL REPO="https://github.com/zackijack/ofood"

ENV PROJPATH=/go/src/github.com/zackijack/ofood

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/zackijack/ofood
WORKDIR /go/src/github.com/zackijack/ofood

RUN make build-alpine

# Final Stage
FROM zackijack/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/zackijack/ofood"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/ofood/bin

WORKDIR /opt/ofood/bin

COPY --from=build-stage /go/src/github.com/zackijack/ofood/bin/ofood /opt/ofood/bin/
RUN chmod +x /opt/ofood/bin/ofood

# Create appuser
RUN adduser -D -g '' ofood
USER ofood

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/ofood/bin/ofood"]
