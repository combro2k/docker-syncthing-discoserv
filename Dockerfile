FROM combro2k/debian-debootstrap:8
MAINTAINER Martijn van Maurik <docker@vmaurik.nl>

ADD resources/bin/run /usr/local/bin/run

RUN useradd discosrv -b /var/discosrv && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install tar curl ca-certificates sudo -yq && \
    mkdir -p /opt/discosrv /var/discosrv && cd /opt/discosrv && \
    curl -k -L https://build.syncthing.net/job/discosrv/lastSuccessfulBuild/artifact/discosrv-linux-amd64.tar.gz | tar zxv --strip-components=1 && \
    chmod +x /usr/local/bin/run && chown -R discosrv:discosrv /opt/discosrv /var/discosrv

WORKDIR /opt/discosrv

VOLUME ["/var/discosrv"]

EXPOSE 8443/tcp

CMD ["/usr/local/bin/run"]
