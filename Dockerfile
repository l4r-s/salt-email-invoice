FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN rm -rf data/bills.txt

CMD [ "python","-u","./salt-invoices.py" ]