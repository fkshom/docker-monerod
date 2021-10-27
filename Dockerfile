FROM ubuntu:20.04 as build

RUN sed -i -e 's/archive.ubuntu.com/jp.archive.ubuntu.com/g' /etc/apt/sources.list \
    && sed -i -e 's/security.ubuntu.com/jp.archive.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget -O /tmp/monerod.tgz https://downloads.getmonero.org/linux64
RUN tar xjvf /tmp/monerod.tgz -C /tmp/
RUN mkdir /tmp/monerod/
RUN rm monerod.tgz
RUN mv /tmp/monero-x86_64-linux-gnu-v*/* /tmp/monerod/
# RUN chown -R monero:monero /home/monero/bin

FROM ubuntu:20.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash monero \
    && mkdir -p /home/monero/.bitmonero \
    && chown -R monero:monero /home/monero/.bitmonero

RUN mkdir /home/monero/log/
RUN mkdir /home/monero/bin/
RUN chown monero:monero /home/monero/log/
RUN chown monero:monero /home/monero/bin/

COPY --chown=monero:monero --from=build /tmp/monerod/* /home/monero/bin/

EXPOSE 18080
EXPOSE 18081
EXPOSE 18089

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--non-interactive", "--config", "/home/monero/monerod.conf"]
