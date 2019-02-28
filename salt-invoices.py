import pickle
import requests
from datetime import datetime  
from datetime import timedelta  
from lxml import html
import os
import time
import email, smtplib, ssl
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

SLEEP = os.environ['SLEEP']
USERNAME = os.environ['SALT_USERNAME']
PASSWORD = os.environ['SALT_PASSWORD']

SMTP_USERNAME = os.environ['SMTP_USERNAME']
SMTP_PASSWORD = os.environ['SMTP_PASSWORD']
SMTP_HOST = os.environ['SMTP_HOST']
SMTP_PORT = os.environ['SMTP_PORT']
SMTP_SENDER = os.environ['SMTP_SENDER']
SMTP_RECEIVER = os.environ['SMTP_RECEIVER']

LOGIN_URL_BASE = "https://sessions.salt.ch"
URL = "https://myaccount.salt.ch/en/bills/"
DOWNLOAD_URL = "https://myaccount.salt.ch/en/bills/pdf/"


def diff(first, second):
        second = set(second)
        return [item for item in first if item not in second]


def sendMail(serial, subject, body):
    # Create a multipart message and set headers
    message = MIMEMultipart()
    message["From"] = SMTP_SENDER
    message["To"] = SMTP_RECEIVER
    message["Subject"] = subject

    # Add body to email
    message.attach(MIMEText(body, "plain"))

    if serial != False:
        filename = serial + ".pdf"
        # Open PDF file in binary mode
        with open(filename, "rb") as attachment:
            # Add file as application/octet-stream
            # Email client can usually download this automatically as attachment
            part = MIMEBase("application", "octet-stream")
            part.set_payload(attachment.read())

        # Encode file in ASCII characters to send by email    
        encoders.encode_base64(part)

        # Add header as key/value pair to attachment part
        part.add_header(
            "Content-Disposition",
            f"attachment; filename= {filename}",
        )

        # Add attachment to message and convert message to string
        message.attach(part)

    text = message.as_string()

    # Log in to server using secure context and send email
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, context=context) as server:
        server.login(SMTP_USERNAME, SMTP_PASSWORD)
        server.sendmail(SMTP_USERNAME, SMTP_RECEIVER, text)


def main():
    print("Using Username: " + USERNAME)
    session_requests = requests.session()
    print()

    # Get login csrf token
    result = session_requests.get(LOGIN_URL_BASE + "/cas/login")
    tree = html.fromstring(result.text)
    authenticity_token = list(set(tree.xpath("//form[@id='idmpform']/@action")))[0]
    lt_token = list(set(tree.xpath("//input[@name='lt']/@value")))[0]

    # Create payload
    payload = {
        "lt": lt_token,
        "execution": "e1s1",
        "_eventId": "submit",
        "username": USERNAME,
        "password": PASSWORD
    }

    # Perform login
    result = session_requests.post(LOGIN_URL_BASE + authenticity_token , data = payload, headers = dict(referer = LOGIN_URL_BASE + "/cas/login"))
    
    if result.status_code != 200:
        subject = "Error: Salt invoice bot could not login!"
        print(subject)
        body = result.status_code
        sendMail(False, subject, body)
        return

    # Scrape bills
    result = session_requests.get(URL, headers = dict(referer = URL))
    if result.status_code != 200:
        subject = "Error: sallt invoice bot could not get latest bills!"
        print(subject)
        body = result.status_code
        sendMail(False, subject, body)
        return
    tree = html.fromstring(result.content)
    bills = []
    for atag in tree.xpath("//div[@class='responsive-table']//ul/li/a"):
        link = (atag.attrib['href'])
        data = link.split('/')
        serialNumber = data[4]
        date = data[5]
        bills.extend([serialNumber])
    with open("bills.txt", "rb") as fp:
        localBills = pickle.load(fp)

    if len(bills) == 0:
        print("Error: no online bills found!")
        subject = "Error: Salt invoice bot"
        body = "No online bills found!"
        sendMail(False, subject, body)
        return
    print("Online Bills:")
    print(len(bills))
    print("Local Bills:")
    print(len(localBills))
    with open("bills.txt", "wb") as fp:
        pickle.dump(bills, fp)

    print("Serial not in localBills:")
    download = diff(bills, localBills)
    print(download)
    #downloading pdf
    for pdf in download:
        with open(pdf + ".pdf", "wb") as file:
            response = session_requests.get(DOWNLOAD_URL + pdf + "/2019-01-01") # the date gets ignored, it is used by salt to give a real client a file name when downloading
            file.write(response.content)
        print("Sending Mail...")
        subject = "Salt Invoice from bot"
        body = "Attached you can finde the latest invoice from salt."
        sendMail(pdf, subject, body)
if __name__ == '__main__':
    while True:
        main()
        print("Goint to sleep for " + SLEEP + " seconds, until:")
        print(datetime.now() + timedelta(seconds=int(SLEEP)))
        time.sleep(int(SLEEP))
