FROM eclipse-temurin:21-jre-jammy

RUN rm -f /etc/apt/sources.list.d/*.sources && \
    echo "deb http://mirror.arvancloud.ir/ubuntu jammy main restricted universe" > /etc/apt/sources.list && \
    echo "deb http://mirror.arvancloud.ir/ubuntu jammy-updates main restricted universe" >> /etc/apt/sources.list && \
    echo "deb http://mirror.arvancloud.ir/ubuntu jammy-security main restricted universe" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        iverilog \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-lxml \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]