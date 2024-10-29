#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.common.exceptions import NoAlertPresentException

opts = Options()
opts.binary_location = "/home/jouni/.nix-profile/bin/firefox-esr"
opts.profile = FirefoxProfile("/home/jouni/.mozilla/firefox/personal")
# opts.profile._profile_dir = "/home/jouni/.mozilla/firefox/personal"

firefox = webdriver.Firefox(opts)
firefox.get("moz-extension://9b86197a-67ae-4c5f-a30c-d5dbf8a9070e/pages/options.html")

firefox.find_element(By.CSS_SELECTOR, "input[type='file']").send_keys(
    "/home/jouni/.config/home-manager/vimium-options.json"
)

while True:
    try:
        firefox.switch_to.alert.accept()
    except NoAlertPresentException:
        print("waiting for alert")
        firefox.implicitly_wait(1)
    else:
        break
