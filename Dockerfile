FROM python:alpine
WORKDIR /app
COPY . /app
RUN pip3 install requirements.txt
CMD python /app/salt-invoices.py