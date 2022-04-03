import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, newHttpHeaders, getContent, close
from std/strutils import find, split
# from std/htmlparser import parseHtml

from pkg/useragent import mozilla
# from pkg/scraper import findAll, text

proc extract(html: string; selectors: seq[string]): seq[string] =
  # let xml = parseHtml html
  for selector in selectors:
    # result.add xml.findAll(selector).text
    let parts = selector.split ":"
    if parts.len == 2:
      let
        s = html.find parts[0]
        e = html.find parts[1]
      if s >= 0 and e >= 0:
        result.add html[s..e]
    else:
      echo "Wrong selector syntax: " & selector

proc main(page: string; output: string; selectors: seq[string]) {.async.} =
  let client = newAsyncHttpClient(headers = newHttpHeaders({
    "User-Agent": mozilla
  }))

  let html = await client.getContent page
  let extracted = html.extract selectors
  echo extracted

  close client

proc parsepage(pages: seq[string]; outputFile: string; selectors: seq[string]) =
  ## Set the `selectors` with the CSS selectors which you want to extract
  for page in pages:
    waitFor main(page, outputFile, selectors)

when isMainModule:
  import cligen
  dispatch parsepage
