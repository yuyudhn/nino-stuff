#! /usr/bin/env python3
import argparse
import smtplib
import logging
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# how to use:
# python3 smtp-tester.py --server 127.0.0.1 --port 25 --sender noreply@domain.com --recipient target@domain.com --subject "Testing" --message "Testing"
def send_email(server, port, sender, recipient, subject, message):
    try:
        msg = MIMEMultipart()
        msg['From'] = sender
        msg['To'] = recipient
        msg['Subject'] = subject

        msg.attach(MIMEText(message, 'plain'))

        logging.debug("Connecting to server %s:%s", server, port)
        with smtplib.SMTP(host=server, port=port) as smtp_server:
            smtp_server.set_debuglevel(1)
            if smtp_server.noop()[0] != 250:
                raise ConnectionError("Connection error")
            smtp_server.starttls()
            smtp_server.sendmail(msg['From'], msg['To'], msg.as_string())
            logging.debug("Email successfully sent to %s", recipient)
            print(f"[+] Successfully sent email to {recipient}")

    except smtplib.SMTPDataError as e:
        logging.error("SMTPDataError: %s - %s", e.smtp_code, e.smtp_error)
        raise
    except Exception as e:
        logging.error("Failed to send email: %s", e)
        raise

def main():
    parser = argparse.ArgumentParser(description='Send an email with specified parameters.')
    parser.add_argument('--server', required=True, help='SMTP server address')
    parser.add_argument('--port', type=int, required=True, help='SMTP server port')
    parser.add_argument('--sender', required=True, help='Sender email address')
    parser.add_argument('--recipient', required=True, help='Recipient email address')
    parser.add_argument('--subject', required=True, help='Email subject')
    parser.add_argument('--message', required=True, help='Email message')
    parser.add_argument('--debug', action='store_true', help='Enable debug logging')

    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
        logging.debug("Debug mode enabled")

    try:
        send_email(args.server, args.port, args.sender, args.recipient, args.subject, args.message)
    except Exception as e:
        logging.error(e)

if __name__ == "__main__":
    main()
