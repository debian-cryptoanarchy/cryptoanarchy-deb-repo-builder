#!/usr/bin/python3

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import subprocess
from time import sleep
import sys
from lnpbp_testkit.cadr import network
# This is not public, but we control the API, so let's break privacy for now
from lnpbp_testkit.parsing import parse_simple_config_lines
import requests
from requests.auth import HTTPBasicAuth
import json

def eprint(msg):
    print(msg, file=sys.stderr)

class NBXplorer:
    def __init__(self):
        config = subprocess.run(["sudo", "cat", "/etc/nbxplorer-regtest/nbxplorer.conf"], stdout=subprocess.PIPE).stdout.decode("utf-8").split('\n')
        config = parse_simple_config_lines(config)

        self._port = config["port"]
        cookie = subprocess.run(["sudo", "cat", "/var/lib/nbxplorer-regtest/RegTest/.cookie"], stdout=subprocess.PIPE)
        username, password = cookie.stdout.decode("utf-8").split(':')
        self._username = username
        self._password = password

        eprint("port: %s, username: %s, password: %s" % (self._port, self._username, self._password))

    def is_synced(self):
        url = "http://localhost:%s/v1/cryptos/btc/status" % self._port
        eprint(url)
        response = requests.get(url, auth=HTTPBasicAuth(self._username, self._password))
        eprint(response.text)
        return response.json()["isFullySynched"]

network().warm_up()

nbxplorer = NBXplorer()

while not nbxplorer.is_synced():
    sleep(1)

ret = 0

default_domain = subprocess.run(["sudo", "/usr/share/selfhost/lib/get_default_domain.sh"], stdout=subprocess.PIPE).stdout.decode("utf-8")

eprint("The default domain is " + default_domain)

chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument("ignore-certificate-errors")
driver = webdriver.Chrome(chrome_options=chrome_options)

eprint("Registering an admin account")

driver.get(default_domain + "/btcpay-rt")
driver.find_element_by_id("Email").send_keys("admin@example.com")
driver.find_element_by_id("Password").send_keys("super secure password")
driver.find_element_by_id("ConfirmPassword").send_keys("super secure password")
driver.find_element_by_id("ConfirmPassword").send_keys(Keys.RETURN)

eprint("Setting up a test store")

driver.get(default_domain + "/btcpay-rt/stores/create")
driver.find_element_by_id("Name").send_keys("Test")
driver.find_element_by_id("Name").send_keys(Keys.RETURN)
store_url = driver.current_url
store_id = store_url[(store_url.rfind('/') + 1):]

eprint("Setting up a chain hot wallet")

driver.get(store_url + "/onchain/BTC/generate/hotwallet")
driver.find_element_by_id("Continue").click()

eprint("Waiting for genmacaroon")

while subprocess.call(["sudo", "test", "-e", "/var/lib/lnd-system-regtest/invoice/invoice+readonly.macaroon"]) != 0:
    sleep(1)

eprint("Setting up lightning")

driver.get(store_url + "/lightning/BTC/settings")
driver.find_element_by_id("save").click()

eprint("Creating an invoice")

driver.get(default_domain + "/btcpay-rt/invoices/create/?storeId=" + store_id)
driver.find_element_by_id("Amount").send_keys("10")
driver.find_element_by_id("Amount").send_keys(Keys.RETURN)

eprint("Retrieving payment details")

driver.find_element_by_class_name("invoice-checkout-link").click()
sleep(5)
payment_link = driver.find_element_by_id("PayInWallet").get_attribute("href")

if payment_link.find("pj=") < 0:
    eprint("PayJoin disabled")
    ret = 1

eprint("Attempting to pay " + payment_link)
network().auto_pay(payment_link)

sleep(10)

if driver.find_element_by_css_selector("div.top h4").text != "Invoice Paid":
    eprint("Failed to pay chain address")
    ret = 1

eprint("Creating an invoice")

driver.get(default_domain + "/btcpay-rt/invoices/create/?storeId=" + store_id)
driver.find_element_by_id("Amount").send_keys("10")
driver.find_element_by_id("Amount").send_keys(Keys.RETURN)

eprint("Retrieving Lightning invoice")

driver.find_element_by_class_name("invoice-checkout-link").click()
sleep(1)
driver.find_element_by_class_name("payment-method").click()

sleep(1)

payment_link = driver.find_element_by_id("PayInWallet").get_attribute("href")
network().auto_pay(payment_link)

sleep(5)

if driver.find_element_by_css_selector("div.top h4").text != "Invoice Paid":
    eprint("Failed to pay Lightning invoice")
    ret = 1

sys.exit(ret)
