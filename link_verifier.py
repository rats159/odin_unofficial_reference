from collections import deque, defaultdict
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
    page_ids: dict[str, set[str]] = {}
    heading_refs: dict[str, list[str]] = defaultdict(list)

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

        page_ids[url] = {tag["id"] for tag in soup.find_all(id=True)}

        for tag in soup.find_all("a", href=True):
            href = tag["href"].strip()
            abs_url = urljoin(url, href)
            parsed = urlparse(abs_url)
            norm = normalize_url(abs_url)

            if parsed.fragment:
                heading_refs[norm].append(parsed.fragment)

            if norm not in queued:
                queued.add(norm)
                queue.append(norm)

    if len(dead) != 0:
        print("Dead links:")
        for item in dead:
            print(f"  {item}")
    else:
        print("No dead links")

    broken_headings = [
        f"{page_url}#{heading}"
        for page_url, refs in heading_refs.items()
        for heading in refs
        if heading not in page_ids.get(page_url, set())
    ]

    if len(broken_headings) != 0:
        print("Missing headers:")
        for target in broken_headings:
            print(f"  {target}")
    else:
        print("No missing headers")


main()