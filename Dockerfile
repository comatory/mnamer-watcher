FROM python:3.12-alpine

RUN apk add --no-cache inotify-tools bash git
RUN pip install --no-cache-dir git+https://github.com/jkwill87/mnamer.git@2.6.0
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
