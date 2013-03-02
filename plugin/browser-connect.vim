" =======================================================================
" File:        browser-connect.vim
" Version:     0.1.0
" Description: Vim plugin that provides a Python REPL inside a buffer.
" Maintainer:  Bogdan Popa <popa.bogdanp@gmail.com>
" License:     Copyright (C) 2013 Bogdan Popa
"
"              Permission is hereby granted, free of charge, to any
"              person obtaining a copy of this software and associated
"              documentation files (the "Software"), to deal in
"              the Software without restriction, including without
"              limitation the rights to use, copy, modify, merge,
"              publish, distribute, sublicense, and/or sell copies
"              of the Software, and to permit persons to whom the
"              Software is furnished to do so, subject to the following
"              conditions:
"
"              The above copyright notice and this permission notice
"              shall be included in all copies or substantial portions
"              of the Software.
"
"              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
"              ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
"              TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
"              PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
"              THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
"              DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
"              CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
"              CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
"              IN THE SOFTWARE.
" ======================================================================

" Exit if the plugin was already loaded or compatible mode is set. {{{
if exists("g:BrowserConnectLoaded") || &cp || !has("python")
    finish
endif

if !exists("g:BrowserConnectServerPath")
  echoer "BrowserConnect: g:BrowserConnectServerPath is not set."
  finish
endif

let g:BrowserConnectLoaded = "010"
" }}}
" Python source. {{{
python <<EOF
import subprocess
import sys
import vim

from urllib2 import URLError, urlopen

class BrowserConnectConstants(object):
  SERVER_PATH     = "{0}/{1}".format(vim.eval("g:BrowserConnectServerPath"), "start")
  BASE_URL        = "http://localhost:9000"
  WS_URL          = "{0}/{1}".format(BASE_URL, "ws")
  RELOAD_CSS_URL  = "{0}/{1}".format(BASE_URL, "reloadCSS")
  EVALUATE_JS_URL = "{0}/{1}".format(BASE_URL, "evaluateJS")

class BrowserConnect(object):
  def __init__(self):
    if not self.server_running():
      sys.stdout.write("BrowserConnect: starting browser-connect-server.")
      self.run_server()

  def server_running(self):
    try:
      urlopen(BrowserConnectConstants.WS_URL)
      return True
    except URLError:
      return False

  def run_server(self):
    subprocess.Popen(["sh", BrowserConnectConstants.SERVER_PATH])

  def evaluate_buffer(self):
    if vim.current.buffer.name.endswith(".css"):
      vim.command("w")
      self.reload_css()
    else:
      self.evluate_js_buffer()

  def evaluate_js_buffer(self):
    self.evaluate_js("".join(vim.current.buffer[:]))

  def evaluate_js_selection(self):
    (sx, sy), (ex, ey) = vim.current.buffer.mark("<"), vim.current.buffer.mark(">")
    sx -= 1; sy -= 1; ex -= 1
    sl, el = vim.current.buffer[sx][sy:], vim.current.buffer[ex][:ey]
    ls = [sl] + vim.current.buffer[sx + 1:ex] + [el]
    self.evaluate_js("".join(ls))

  def reload_css(self):
    try:
      urlopen(BrowserConnectConstants.RELOAD_CSS_URL)
    except URLError:
      sys.stderr.write("BrowserConnect: could not connect to server.")

  def evaluate_js(self, body):
    try:
      urlopen(BrowserConnectConstants.EVALUATE_JS_URL, body)
    except URLError:
      sys.stderr.write("BrowserConnect: could not connect to server.")

browserConnect = BrowserConnect()
EOF
" }}}
" Mappings. {{{
if !exists("g:bc_no_mappings")
    vmap <silent><C-CR> :python browserConnect.evaluate_js_selection()<CR>
    nmap <silent><C-CR> :python browserConnect.evaluate_buffer()<CR>
    imap <silent><C-CR> <ESC>:python browserConnect.evaluate_buffer()<CR>:startinsert!<CR>
endif
" }}}
