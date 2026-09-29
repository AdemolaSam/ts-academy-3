FROM alpine:3.20

RUN apk add --no-cache bash \
    && adduser -D -H appuser

WORKDIR /app
COPY app/ /app/
RUN chmod +x /app/*.sh

USER appuser

ENTRYPOINT ["/app/app.sh"]
CMD ["help"]
