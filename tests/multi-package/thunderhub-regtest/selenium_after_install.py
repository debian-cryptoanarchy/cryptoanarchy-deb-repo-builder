#!/usr/bin/python3

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import subprocess
from time import sleep
import sys
from selenium.common.exceptions import StaleElementReferenceException
import json

def eprint(msg):
    print(msg, file=sys.stderr)

ret = 0

default_domain = subprocess.run(["sudo", "/usr/share/selfhost/lib/get_default_domain.sh"], stdout=subprocess.PIPE).stdout.decode("utf-8")
cookie = subprocess.run(["sudo", "cat", "/var/run/thunderhub-system-regtest/sso/cookie"], stdout=subprocess.PIPE).stdout.decode("utf-8")

eprint("The default domain is " + default_domain)

chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument("ignore-certificate-errors")
driver = webdriver.Chrome(options=chrome_options)

eprint("Opening SSO account")

driver.get(default_domain + "/thunderhub-rt?token=" + cookie)

# Not sure if the names of classes stay the same, so better rely on texts
button = None
for elem in driver.find_elements_by_css_selector("button"):
    if elem.text == "Connect":
        button = elem
        break

if button is None:
    raise Exception("Missing SSO button")

button.click()

sleep(5)

eprint("Creating an invoice")
accounts = None
for elem in driver.find_elements_by_class_name("Styled__CardWithTitle-xwgv07-0"):
    if any(x.text == "Your Accounts" for x in elem.find_elements_by_css_selector("h4")):
        accounts = elem
        break

lightning_tab = None
for elem in accounts.find_elements_by_css_selector("div > div > div"):
    if any(x.text == "Lightning" for x in elem.find_elements_by_css_selector("div > div")):
            lightning_tab = elem
            break

for elem in lightning_tab.find_elements_by_class_name("ColorButton__GeneralButton-sc-1nxqgk6-0"):
    if elem.text == "Receive":
        elem.click()
        break

for elem in driver.find_elements_by_css_selector("div"):
    if any(x.text == "Amount to receive:" for x in elem.find_elements_by_css_selector("h5")):
        elem.find_element_by_css_selector("input").send_keys("200000")
        for button in elem.find_elements_by_css_selector("button"):
            if button.text != "Cancel":
                button.click()
                break
        break

sleep(2)
eprint("Retrieving Lightning invoice")
invoice = None
for elem in driver.find_elements_by_class_name("CreateInvoice__WrapRequest-yp9wpk-1"):
    try:
        eprint(elem.text)
        if elem.text.startswith("lnbcrt2m1"):
            invoice = elem.text
            break
    except StaleElementReferenceException:
        pass

subprocess.run(["sudo", "-u", "lnd-test-1", "/usr/lib/lncli/lncli", "--network", "regtest", "--rpcserver", "127.0.0.1:9802", "payinvoice", "-f", invoice])

sleep(5)

for elem in driver.find_elements_by_class_name("Navigation__NavSeparation-sc-1te9rll-4"):
    if elem.text == "Transactions":
        elem.click()
        break

sleep(2)

transactions = None
for elem in driver.find_elements_by_class_name("Styled__CardWithTitle-xwgv07-0"):
    if any(x.text == "Transactions" for x in elem.find_elements_by_css_selector("h4")):
        transactions = elem

invoice_found = False
for elem in transactions.find_elements_by_css_selector("div > div > div.Styled__SubCard-xwgv07-4"):
    if any(x.text == "Invoice" for x in elem.find_elements_by_css_selector("div")) and any(x.text == "200,000 sats" for x in elem.find_elements_by_css_selector("div")):
        invoice_found = True

if not invoice_found:
    eprint("Invoice not found")
    ret = 1

for elem in driver.find_elements_by_class_name("Navigation__NavSeparation-sc-1te9rll-4"):
    if elem.text == "Home":
        elem.click()
        break

sleep(2)

accounts = None
for elem in driver.find_elements_by_class_name("Styled__CardWithTitle-xwgv07-0"):
    if any(x.text == "Your Accounts" for x in elem.find_elements_by_css_selector("h4")):
        accounts = elem
        break

lightning_tab = None
for elem in accounts.find_elements_by_css_selector("div > div > div"):
    if any(x.text == "Lightning" for x in elem.find_elements_by_css_selector("div > div")):
            lightning_tab = elem
            break

for elem in lightning_tab.find_elements_by_class_name("ColorButton__GeneralButton-sc-1nxqgk6-0"):
    if elem.text == "Send":
        elem.click()
        break

invoice_str = subprocess.check_output(["sudo", "-u", "lnd-test-1", "/usr/lib/lncli/lncli", "--network", "regtest", "--rpcserver", "127.0.0.1:9802", "addinvoice", "5000"])

invoice = json.loads(invoice_str)["payment_request"]
r_hash = json.loads(invoice_str)["r_hash"]

for elem in driver.find_elements_by_css_selector("div"):
    if any(x.text == "Invoice or Public Key:" for x in elem.find_elements_by_css_selector("h5")):
        elem.find_element_by_css_selector("input").send_keys(invoice)
        for button in elem.find_elements_by_css_selector("button"):
            if button.text != "Cancel":
                button.click()
                break
        break

sleep(1)

for elem in driver.find_elements_by_class_name("ColorButton__GeneralButton-sc-1nxqgk6-0"):
    if elem.text == "Send":
        elem.click()
        break

sleep(5)

invoice_state = subprocess.check_output(["sudo", "-u", "lnd-test-1", "/usr/lib/lncli/lncli", "--network", "regtest", "--rpcserver", "127.0.0.1:9802", "lookupinvoice", r_hash])

if not json.loads(invoice_state)["settled"]:
    eprint("Invoice was not paid")
    ret = 1

sys.exit(ret)
