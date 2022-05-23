FROM python:3-alpine

COPY requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

COPY app.py /var/server/app.py

CMD python /var/server/app.py
