FROM elontsi007/python

WORKDIR /webapp

COPY FlaskApp.conf .

COPY flaskapp.wsgi .

COPY webapp-cert.pem .

COPY webapp-key.pem .

RUN apt-get update -y

COPY webapp.py .

CMD ["python3.9", "webapp.py"]
