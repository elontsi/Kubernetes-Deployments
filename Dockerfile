FROM elontsi007/python

WORKDIR /webapp

COPY FlaskApp.conf .

COPY flaskapp.wsgi .

COPY webapp-cert.pem .

COPY webapp-key.pem .

COPY webapp.py .

USER root

RUN apt-get update -y

CMD ["python3.9", "webapp.py"]
