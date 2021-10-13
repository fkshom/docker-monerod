FROM ubuntu:20.04 as build

# RUN apt-get update && apt-get install -y --no-install-recommends \
#       wget \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
RUN sed -i -e 's/archive.ubuntu.com/jp.archive.ubuntu.com/g' /etc/apt/sources.list
RUN sed -i -e 's/security.ubuntu.com/jp.archive.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
      wget \
      ca-certificates

WORKDIR /tmp
RUN wget https://downloads.getmonero.org/linux64
RUN tar xjvf linux64 -C /tmp/
RUN mkdir /tmp/monerod/
RUN rm linux64
RUN mv /tmp/monero-x86_64-linux-gnu-v*/* /tmp/monerod/
# RUN chown -R monero:monero /home/monero/bin

FROM ubuntu:20.04

# Add user and setup directories for monerod
RUN useradd -ms /bin/bash monero \
    && mkdir -p /home/monero/.bitmonero \
    && chown -R monero:monero /home/monero/.bitmonero

RUN mkdir /home/monero/log/
RUN mkdir /home/monero/bin/
RUN chown monero:monero /home/monero/log/
RUN chown monero:monero /home/monero/bin/

COPY --chown=monero:monero --from=build /tmp/monerod/* /home/monero/bin/

USER monero

WORKDIR /home/monero

EXPOSE 18080
EXPOSE 18081
EXPOSE 18089

# Start monerod with required --non-interactive flag and sane defaults that are overridden by user input (if applicable)
ENTRYPOINT ["/home/monero/bin/monerod"]
# CMD ["--non-interactive", "--restricted-rpc", "--rpc-bind-ip=0.0.0.0", "--confirm-external-bind"]
CMD ["--non-interactive", "--config", "/home/monero/monerod.conf"]