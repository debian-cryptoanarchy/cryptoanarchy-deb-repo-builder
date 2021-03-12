#!/usr/bin/python3

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import subprocess
from time import sleep
import sys
from lnpbp_testkit.cadr import network
# This is not public, but we control the API, so let's break privacy for now
from lnpbp_testkit.parsing import parse_simple_config
import requests
from requests.auth import HTTPBasicAuth
import json

def eprint(msg):
    print(msg, file=sys.stderr)

class NBXplorer:
    def __init__(self):
        config = parse_simple_config("/etc/nbxplorer-regtest/nbxplorer.conf")

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
store_id = driver.find_element_by_id("Id").get_attribute("value")

eprint("Setting up a chain hot wallet")

driver.get(default_domain + "/btcpay-rt/stores/" + store_id + "/onchain/BTC/generate/hotwallet")
driver.find_element_by_id("Continue").click()

eprint("Waiting for genmacaroon")

while subprocess.call(["sudo", "test", "-e", "/var/lib/lnd-system-regtest/invoice/invoice+readonly.macaroon"]) != 0:
    sleep(1)

eprint("Setting up lightning")

driver.get(default_domain + "/btcpay-rt/stores/" + store_id + "/lightning/BTC")
driver.find_element_by_id("internal-ln-node-setter").click()
driver.find_element_by_id("save").click()

eprint("Setting up PayJoin")

driver.find_element_by_id("PayJoinEnabled").click()
driver.find_element_by_id("Save").click()

eprint("Creating an invoice")

driver.get(default_domain + "/btcpay-rt/invoices/create/")
driver.find_element_by_id("Amount").send_keys("10")
driver.find_element_by_id("Amount").send_keys(Keys.RETURN)

eprint("Retrieving payment details")

driver.find_element_by_class_name("invoice-checkout-link").click()
payment_link = driver.find_element_by_class_name("payment__details__instruction__open-wallet__btn").get_attribute("href")

if payment_link.find("pj=") < 0:
    eprint("PayJoin disabled")
    ret = 1

eprint("Attempting to pay " + payment_link)
network().auto_pay(payment_link)

sleep(10)

if driver.find_element_by_class_name("success-message").text != "This invoice has been paid":
    eprint("Failed to pay chain address")
    ret = 1

eprint("Creating an invoice")

driver.get(default_domain + "/btcpay-rt/invoices/create/")
driver.find_element_by_id("Amount").send_keys("10")
driver.find_element_by_id("Amount").send_keys(Keys.RETURN)

eprint("Retrieving Lightning invoice")

driver.find_element_by_class_name("invoice-checkout-link").click()
driver.find_element_by_class_name("payment__currencies").click()

for element in driver.find_elements_by_class_name("vexmenuitem"):
    a = element.find_element_by_css_selector("a")
    if a.text.find("Lightning") > 0:
        a.click()
        break

sleep(1)

payment_link = driver.find_element_by_class_name("payment__details__instruction__open-wallet__btn").get_attribute("href")
network().auto_pay(payment_link)

sleep(5)

if driver.find_element_by_class_name("success-message").text != "This invoice has been paid":
    eprint("Failed to pay Lightning invoice")
    ret = 1

sys.exit(ret)
