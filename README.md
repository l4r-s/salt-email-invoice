# Salt invoice download / email script

This script downloads and emails all invoices which are not currently in the local database (/app/bills.txt).

## Usage

A cronjob with docker is the preffered way to use this script. The following evironment variables need to be defined:

~~~bash
export SALT_USERNAME="Your-salt.ch-Username"
export SALT_PASSWORD="Your-salt.ch-Password"
export SMTP_USERNAME="Your-SMTP-Server-Username"
export SMTP_PASSWORD="Your-SMTP-Server-Password"
export SMTP_HOST="Your-SMTP-Servername"
export SMTP_PORT="Your-SMTP-Port" # usaually: 465
export SMTP_SENDER="FROM-Address"
export SMTP_RECEIVER="Receiver-EMail-Address"
~~~