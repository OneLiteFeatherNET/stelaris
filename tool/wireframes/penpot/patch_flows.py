"""Add prototype flows (start points) to the page of a built .penpot file.

@penpot/library cannot create flows, so build.mjs writes them to a side
file and this script inserts them into files/<file>/pages/<page>.json.
"""
import json
import os
import shutil
import sys
import tempfile
import zipfile

penpot_file, flows_file = sys.argv[1:]
spec = json.load(open(flows_file))
page_path = f"files/{spec['fileId']}/pages/{spec['pageId']}.json"

tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".penpot").name
with zipfile.ZipFile(penpot_file) as src, \
        zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as dst:
    for item in src.infolist():
        data = src.read(item.filename)
        if item.filename == page_path:
            page = json.loads(data)
            page["flows"] = {f["id"]: f for f in spec["flows"]}
            data = json.dumps(page).encode()
        dst.writestr(item, data)
shutil.move(tmp, penpot_file)
os.chmod(penpot_file, 0o644)
print(f"{len(spec['flows'])} flows -> {page_path}")
