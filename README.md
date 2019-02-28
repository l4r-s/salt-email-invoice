# Salt invoice download / email script

This script downloads and emails all invoices which are not currently in the local database (/app/bills.txt).

## Usage

The following evironment variables need to be defined:

~~~bash
$ cat tests/env.list.example
SLEEP=43200
SALT_USERNAME=username
SALT_PASSWORD=12345
SMTP_USERNAME=admin@test.com
SMTP_PASSWORD=12345
SMTP_HOST=mail.test.com
SMTP_PORT=465
SMTP_SENDER=bot@test.com
SMTP_RECEIVER=receiver@test.com
~~~

Run the container with:

~~~bash
docker run -d --env-file tests/envs.list.example -v /local/path:/usr/src/app/data l4rs/salt-email-invoice:latest
~~~