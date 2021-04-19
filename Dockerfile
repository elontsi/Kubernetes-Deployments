FROM python:3.9

WORKDIR /webapp

COPY requirements.txt .

COPY FlaskApp.conf .

COPY flaskapp.wsgi .

COPY webapp-cert.pem .

COPY webapp-key.pem .

RUN apt update -y

RUN apt install python3-pip -y

#RUN pip install -r requirements.txt

COPY webapp.py .

CMD ["python3.9", "webapp.py"]
