from collections import deque
from urllib.parse import urljoin, urlparse
import requests
from bs4 import BeautifulSoup


def normalize_url(url: str) -> str:
    parsed = urlparse(url)
    return parsed._replace(fragment="").geturl()


def main() -> None:
    start_url = "http://localhost:8000"

    session = requests.Session()

    queue = deque([start_url])
    queued = {start_url}
    crawled = set()

    dead = []

    while queue:
        url = queue.popleft()

        if not url.startswith("http://localhost:8000"):
            continue

        if url in crawled:
            continue

        crawled.add(url)

        try:
            resp = session.get(url, allow_redirects=True)
        except requests.RequestException as exc:
            print(f"ERROR: {url} {exc}")
            continue

        if resp.status_code >= 400:
            dead.append(url)
            continue

        soup = BeautifulSoup(resp.text, "html.parser")
        for tag in soup.find_all("a", href=True):
            href = tag["href"].strip()
            abs_url = urljoin(url, href)
            if abs_url not in queued:
                queued.add(abs_url)
                queue.append(abs_url)

    if len(dead) == 0:
        print("no dead links")
    for item in dead:
        print(item)

main()