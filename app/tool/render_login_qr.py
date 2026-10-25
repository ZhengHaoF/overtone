import os
import re
import sys

import segno

log_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.environ["TEMP"], "dart_dailystyle.log"
)
with open(log_path, encoding="utf-8", errors="ignore") as fh:
    log = fh.read()

if log.startswith("http"):
    url = log.strip()
    print("url:", url)
else:
    m = re.search(r"qrContent=(\S+)", log) or re.search(r"(https://music\.163\.com/\S+)", log)
    if not m:
        print("no qrContent in log")
        sys.exit(1)
    url = m.group(1)
    print("url:", url)
out = os.path.join(os.environ["TEMP"], "overtone_login_qr.png")
segno.make(url, error="m").save(out, scale=8, border=4)
print("saved:", out)
