import pkg/yaml/[toJson]
import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, newHttpHeaders, getContent, close
from std/strutils import find, split, replace
from std/json import `{}`, keys, getStr, to
from std/os import createDir, `/`
from std/htmlparser import parseHtml
from std/xmltree import `$`
from std/uri import parseUri
from std/strformat import fmt
from std/cgi import xmlEncode
from std/base64 import encode

from pkg/nimquery import querySelectorAll
from pkg/useragent import mozilla
from pkg/fsafename import safename
import pkg/karax/[karaxdsl, vdom, vstyles]

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
    extract: seq[tuple[key, selector: string]] ## CSS Selectors
    outDir: string

proc main(conf: Config) {.async.} =
  var files: seq[string]
  for url in conf.pages:
    echo url
    let
      client = newAsyncHttpClient(headers = newHttpHeaders({
        "User-Agent": mozilla
      }))
      html = parseHtml await client.getContent url
    close client
    createDir conf.outDir
    let res = buildHtml(main):
      link(rel = "stylesheet", href = "https://unpkg.com/mvp.css")
      header:
        h1:
          a(href = url, referrerpolicy = "no-referrer", rel = "external"):
            text url
      section:
        for (name, selector) in conf.extract:
          tdiv:
            h2(style = style({display: "inline"})): text name
            sup: text selector
            # h2: text selector
            for el in html.querySelectorAll selector:
              let code = $el
              pre:
                a(href = "https://code.ozzuu.com/#" & encode code,
                  target = "_blank", referrerpolicy = "no-referrer",
                  rel = "external", style = style({fontWeight: "normal"})):
                    text "Preview"
                code: text code
          hr()
    let outFile =
      conf.outDir / safename parseUri(url).path[1..^2].replace("/", "-") & ".html"
    files.add outFile
    outFile.writeFile $res
  let indexContent = buildHtml(main):
    link(rel = "stylesheet", href = "https://unpkg.com/mvp.css")
    h1: text "Index"
    for file in files:
      li: a(href = file): text file
  writeFile(conf.outDir / "index.html", $indexContent)
    

proc parsepage(config: string) =
  ## Set the `selectors` with the CSS selectors which you want to extract
  let node = loadToJson(readFile config)[0]
  var conf = new Config
  conf.pages = node{"pages"}.to seq[string]
  conf.outDir = node{"outDir"}.getStr
  let extract = node{"extract"}
  for key in extract.keys:
    conf.extract.add (key, extract{key}.getStr)
  waitFor main conf

when isMainModule:
  import cligen
  dispatch parsepage
