FROM tusproject/tusd AS builder

USER root
COPY requirements.txt .

RUN apk add py3-pip
RUN pip3 install -r requirements.txt

USER tusd
EXPOSE 1080

FROM builder

COPY hooks /srv/tusd-hooks

ENTRYPOINT tusd -behind-proxy -s3-bucket incoming -s3-endpoint ${AWS_ENDPOINT} -hooks-dir /srv/tusd-hooks -base-path /videos/upload