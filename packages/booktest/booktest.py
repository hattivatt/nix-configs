import argparse
import posixpath
import sys
import zipfile
import xml.etree.ElementTree as ET

EPUB_TYPE = "{http://www.idpf.org/2007/ops}type"


def tag(element):
    return element.tag.rsplit("}", 1)[-1]


def text(element):
    return " ".join("".join(element.itertext()).split())


def show_ncx(element, depth=0):
    count = 0
    for child in element:
        if tag(child) == "navPoint":
            label = child.find("{*}navLabel")
            target = child.find("{*}content")
            title = text(label) if label is not None else "(без названия)"
            href = target.get("src", "") if target is not None else ""
            print(f"{'  ' * depth}- {title} → {href}")
            count += 1 + show_ncx(child, depth + 1)
        else:
            count += show_ncx(child, depth)
    return count


def show_nav(element, depth=0):
    count = 0
    for child in element:
        name = tag(child)
        if name == "li":
            for label in child:
                if tag(label) in ("a", "span"):
                    href = label.get("href", "")
                    print(f"{'  ' * depth}- {text(label)} → {href}")
                    count += 1
                elif tag(label) == "ol":
                    count += show_nav(label, depth + 1)
        else:
            count += show_nav(child, depth)
    return count


def inspect(path):
    print(f"\n=== {path} ===")
    found = False
    with zipfile.ZipFile(path) as archive:
        container = ET.fromstring(archive.read("META-INF/container.xml"))
        rootfile = container.find(".//{*}rootfile")
        if rootfile is None:
            raise ValueError("Не найден package document")
        opf_path = rootfile.attrib["full-path"]
        opf = ET.fromstring(archive.read(opf_path))

        for item in opf.findall(".//{*}manifest/{*}item"):
            is_nav = "nav" in item.get("properties", "").split()
            is_ncx = item.get("media-type") == "application/x-dtbncx+xml"
            if not (is_nav or is_ncx):
                continue

            from urllib.parse import unquote

            entry = posixpath.normpath(
                posixpath.join(
                    posixpath.dirname(opf_path),
                    unquote(item.attrib["href"]),
                )
            )
            root = ET.fromstring(archive.read(entry))
            print(f"\n{'EPUB 3 NAV' if is_nav else 'NCX'}: {entry}")
            count = 0
            if is_nav:
                for nav in root.iter():
                    if tag(nav) == "nav":
                        if "toc" in nav.get(EPUB_TYPE, "").split():
                            count += show_nav(nav)
            else:
                navmap = root.find(".//{*}navMap")
                if navmap is not None:
                    count = show_ncx(navmap)

            print(f"Пунктов: {count}")
            if count <= 1:
                print("ПРЕДУПРЕЖДЕНИЕ: пустое или одноэлементное оглавление")
            found = True

    if not found:
        print("ПРЕДУПРЕЖДЕНИЕ: оглавление в manifest не найдено")


parser = argparse.ArgumentParser()
parser.add_argument("files", nargs="+")
args = parser.parse_args()
failed = False

for filename in args.files:
    try:
        inspect(filename)
    except (OSError, ValueError, KeyError, ET.ParseError) as error:
        print(f"ОШИБКА: {filename}: {error}", file=sys.stderr)
        failed = True

sys.exit(1 if failed else 0)
