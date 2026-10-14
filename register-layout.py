#!/usr/bin/env python3
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

xml_path = Path(sys.argv[1])
tree = ET.parse(xml_path)
root = tree.getroot()

layout_list = None
for el in root.iter():
    if el.tag == "layoutList":
        layout_list = el
        break
if layout_list is None:
    raise SystemExit("no <layoutList> found in evdev.xml")

for layout in list(layout_list.findall("layout")):
    ci = layout.find("configItem")
    if ci is not None:
        nm = ci.find("name")
        if nm is not None and nm.text in ("nepali_mac", "nepali_unicode_romanized"):
            layout_list.remove(layout)

tree.write(xml_path, encoding="utf-8", xml_declaration=True)
tree = ET.parse(xml_path)
root = tree.getroot()
layout_list = None
for el in root.iter():
    if el.tag == "layoutList":
        layout_list = el
        break

layout = ET.SubElement(layout_list, "layout")
ci = ET.SubElement(layout, "configItem")
ET.SubElement(ci, "name").text = "nepali_unicode_romanized"
ET.SubElement(ci, "shortDescription").text = "ne"
ET.SubElement(ci, "description").text = "Nepali Unicode Romanized"
ll = ET.SubElement(ci, "languageList")
ET.SubElement(ll, "iso639Id").text = "nep"
variants = ET.SubElement(layout, "variantList")
v = ET.SubElement(variants, "variant")
vci = ET.SubElement(v, "configItem")
ET.SubElement(vci, "name").text = "unicode_romanized"
ET.SubElement(vci, "description").text = "Unicode Romanized"

tree.write(xml_path, encoding="utf-8", xml_declaration=True)
print("registered nepali_unicode_romanized in", xml_path)
