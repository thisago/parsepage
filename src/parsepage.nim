import pkg/yaml/[toJson]
import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, newHttpHeaders, getContent, close
from std/strutils import find, split, replace
from std/json import to
from std/os import createDir, `/`
from std/htmlparser import parseHtml
from std/xmltree import `$`
from std/uri import parseUri
from std/strformat import fmt
from std/cgi import xmlEncode
from pkg/nimquery import querySelectorAll
from pkg/useragent import mozilla
from pkg/fsafename import safename
import pkg/karax/[karaxdsl, vdom]

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

type
  Config* = ref object
    pages: seq[string]
    extract: seq[string] ## CSS Selectors
    outDir: string

proc main(conf: Config) {.async.} =
  for url in conf.pages:
    let
      client = newAsyncHttpClient(headers = newHttpHeaders({
        "User-Agent": mozilla
      }))
      html = parseHtml await client.getContent url
    close client
    createDir conf.outDir
    let res = buildHtml(tdiv):
      h1: text url
      for selector in conf.extract:
        section:
          h2: text selector
          for el in html.querySelectorAll selector:
            ul: code: text xmlEncode $el
    writeFile(conf.outDir / safename parseUri(url).path.replace("/", "|"), $res)

proc parsepage(config: string) =
  ## Set the `selectors` with the CSS selectors which you want to extract
  let conf = loadToJson(readFile config)[0].to Config
  waitFor main conf

when isMainModule:
  import cligen
  dispatch parsepage
