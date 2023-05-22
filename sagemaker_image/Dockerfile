FROM python:3.8-slim-buster

WORKDIR /app

COPY requirements.txt /app
RUN pip install -r requirements.txt --no-cache-dir 

COPY app.py /app

EXPOSE 8080

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "--timeout", "12000", "--worker-class", "uvicorn.workers.UvicornWorker", "app:app"]
