import os
import subprocess
from dotenv import load_dotenv

# Load env vars
load_dotenv(dotenv_path=os.path.basename(".creds"))

# Setup variables
HOSTNAME = os.getenv('HOSTNAME')
GH_ORGANIZATION = os.getenv("GH_ORGANIZATION")
IDLE_TIME_IN_SEC = os.getenv("GH_IDLE_TIMEOUT")
IDLE_TIME_IN_SEC_FORMATTED = "{} seconds ago".format(IDLE_TIME_IN_SEC)
ACTIONS_SERVICE = "actions.runner.{}.spot-runner-{}.service".format(GH_ORGANIZATION, HOSTNAME)

# Check runner service logs
RESULT = subprocess.Popen(["journalctl", "-u", ACTIONS_SERVICE, "--since", IDLE_TIME_IN_SEC_FORMATTED, "--no-pager"], stdout=subprocess.PIPE).stdout.read()

if "No entries" in RESULT: 
    print("No entries. Triggering cleanup...")
    CLEANUP_RESULT = subprocess.Popen(["./cleanup.sh"], stdout=subprocess.PIPE).stdout.read()
    print(CLEANUP_RESULT)
else:
    print("With entries")
    print(RESULT)
