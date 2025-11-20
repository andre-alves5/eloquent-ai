FROM python:3.11-slim AS builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM gcr.io/distroless/python3-debian12

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app /app

USER nonroot

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/uvicorn" ]
CMD [ "app:app", "--host", "0.0.0.0", "--port", "8080"]
