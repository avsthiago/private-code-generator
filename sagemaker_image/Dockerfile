FROM python:3.8-slim-buster

ARG MODEL_BUCKET_NAME
ARG MODEL_KEY_PREFIX

WORKDIR /app

COPY requirements.txt /app
RUN pip install -r requirements.txt --no-cache-dir 

COPY app.py /app

EXPOSE 8080

ENV MODEL_BUCKET_NAME=${MODEL_BUCKET_NAME} \
    MODEL_KEY_PREFIX=${MODEL_KEY_PREFIX}

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "--timeout", "12000", "--worker-class", "uvicorn.workers.UvicornWorker", "app:app"]
