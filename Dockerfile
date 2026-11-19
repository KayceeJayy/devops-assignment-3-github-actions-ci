FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="DevOps Diagnostic Tool"
LABEL org.opencontainers.image.description="Assignment 3 CI/CD"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       coreutils \
       hostname \
       procps \
       iputils-ping \
       mawk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/devops-tool

COPY app/app.sh ./app/app.sh

RUN chmod 0755 ./app/app.sh

USER 10001:10001

ENTRYPOINT ["/opt/devops-tool/app/app.sh"]

CMD ["help"]
