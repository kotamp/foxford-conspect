fs = require 'fs'
JSDOM = require('jsdom').JSDOM

files = fs.readdirSync('./source')

content = files.map (item) ->
  fs.readFileSync('./source/' + item, encoding: 'utf8')

DOMs = content.map (item) -> new JSDOM(item)

headers = DOMs.map (dom) ->
  return dom.window.document.querySelector('div.conspect_banner h1')?.innerHTML

texts = DOMs.map (dom) ->
  return dom.window.document.querySelector('div.page_content_main')?.innerHTML

hiddenTitles = DOMs.map (dom) ->
  el = dom.window.document.querySelector('div.hidden_title')
  if el?
    return parseInt el.innerHTML.slice(9)

o = 
  file: files
  content: content
  DOM: DOMs
  header: headers
  text: texts
  number: hiddenTitles

wrap = (o) ->
  k = Object.keys o
  v = Object.values o

  res = []

  minLength = v.map((e) -> e.length).reduce (prev, now) ->
    if now < prev then now else prev

  for i in [0...minLength]
    newObject = {}
    for j in [0...k.length]
      newObject[k[j]] = o[k[j]][i]
    res.push newObject
  return res

sorted = wrap(o).sort (a, b) ->
  a.number - b.number

mathjax = '''<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>'''

template = (title, text, index) -> '''
<!doctype html>
<html><head><link rel="stylesheet" href="../page.css"><title>''' + index + '. ' + title + '''</title></head><body><h1>''' + index + '. ' + title + '''</h1>
<div class="page_content_main">''' + text + '''</div>''' + mathjax + '''</body></html>'''

count = 1

sorted.forEach (e) ->
  fs.createWriteStream('./o/' + (count++) + '.html')
  .end template e.header, e.text, e.number

index = '''<!doctype html>
<html><head><link rel="stylesheet" href="index.css"><title>Фоксфорд Информатика</title></head><body><h1>Конспект фоксфорда по информатике. Ботай, мужик. 👶</h1><ul>'''

index += sorted.map((e, i) ->
  '<li>' +
  '<a href="./o/' + (i+1) + '.html">' + e.number + '. ' + e.header + '</a>' +
  '</li>'
).join('')

index += '</ul></body></html>'

fs.createWriteStream('./index.html').end index


