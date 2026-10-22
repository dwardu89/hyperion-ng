FROM debian:bullseye

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y wget gpg sudo && \
    sudo apt-get update && sudo apt-get install wget gpg apt-transport-https lsb-release && \
    wget -qO /tmp/hyperion.pub.key https://releases.hyperion-project.org/hyperion.pub.key && \
    gpg --dearmor -o - /tmp/hyperion.pub.key > /usr/share/keyrings/hyperion.pub.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hyperion.pub.gpg] https://apt.releases.hyperion-project.org/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hyperion.list && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hyperion.pub.gpg] https://nightly.apt.releases.hyperion-project.org/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hyperion.nightly.list && \
    apt-get update && \
    apt-get install -y hyperion && \
    apt-get -y --purge autoremove gpg && \
    apt-get clean


# Flatbuffers Server port
EXPOSE 19400

# JSON-RPC Server Port
EXPOSE 19444

# Protocol Buffers Server port
EXPOSE 19445

# Boblight Server port
EXPOSE 19333

# Philips Hue Entertainment mode (UDP)
EXPOSE 2100

# HTTP and HTTPS Web UI default ports
EXPOSE 8090
EXPOSE 8092

ENV UID=1000
ENV GID=1000

RUN groupadd -f hyperion
RUN useradd -r -s /bin/bash -g hyperion hyperion

RUN echo "#!/bin/bash" > /start.sh
RUN echo "groupmod -g \$2 hyperion" >> /start.sh
RUN echo "usermod -u \$1 hyperion" >> /start.sh
RUN echo "chown -R hyperion:hyperion /config" >> /start.sh
RUN echo "sudo -u hyperion /usr/bin/hyperiond -v --service -u /config" >> /start.sh

RUN chmod 777 /start.sh

VOLUME /config

CMD [ "bash", "-c", "/start.sh ${UID} ${GID}" ]
