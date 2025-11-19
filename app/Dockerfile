FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY . .

FROM gcr.io/distroless/python3.12

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app /app

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/uvicorn" ]
CMD [ "app:app", "--host", "0.0.0.0", "--port", "8080"]