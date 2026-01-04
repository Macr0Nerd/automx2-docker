FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y curl build-essential libpq-dev mariadb-client \
    && apt-get clean

COPY scripts/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

WORKDIR /etc/automx2
COPY contrib/automx2-sample.conf ./automx2.conf
COPY contrib/seed-example.json ./provider.json

WORKDIR /var/www/automx2

RUN python -m venv .venv
COPY pyproject.toml README.md ./
COPY src/automx2 src/automx2

RUN touch .initialize

RUN ./.venv/bin/pip install -U pip wheel setuptools
RUN ./.venv/bin/pip install psycopg2 pymysql
RUN ./.venv/bin/pip install .

RUN useradd -d /srv/www/automx2 automx2
RUN chown -R automx2:automx2 /var/www/automx2
USER automx2:automx2

RUN ls -lA

ENV AUTOMX2_ENV=production
ENV AUTOMX2_HOST=0.0.0.0
ENV AUTOMX2_PORT=4243

EXPOSE 4243

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["%%CMD%%"]