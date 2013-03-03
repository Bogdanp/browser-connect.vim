" =======================================================================
" File:        browser-connect.vim
" Version:     0.2.2
" Description: Live browser interaction for VIM.
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
if exists("g:bc_loaded") || &cp || !has("python")
    finish
endif

if !exists("g:bc_server_path")
    let g:bc_server_path = "~/.vim/bundle/browser-connect.vim/server"
endif

if !exists("g:bc_server_port")
    let g:bc_server_port = "9001"
endif

let g:bc_loaded = "010"
" }}}
" Python source. {{{
python <<EOF
import subprocess
import os
import sys
import vim

from urllib2 import URLError, urlopen

class BrowserConnectConstants(object):
  SERVER_PATH     = os.path.expanduser("{0}/start".format(vim.eval("g:bc_server_path")))
  SERVER_PORT     = str(vim.eval("g:bc_server_port"))
  BASE_URL        = "http://localhost:{0}".format(SERVER_PORT)
  WS_URL          = "{0}/{1}".format(BASE_URL, "ws")
  RELOAD_CSS_URL  = "{0}/{1}".format(BASE_URL, "reloadCSS")
  RELOAD_PAGE_URL = "{0}/{1}".format(BASE_URL, "reloadPage")
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
    subprocess.Popen([
      "sh", BrowserConnectConstants.SERVER_PATH,
      "-Dhttp.port={0}".format(BrowserConnectConstants.SERVER_PORT)])

  def evaluate_buffer(self):
    if vim.current.buffer.name.endswith(".css"):
      vim.command("w")
      self.reload_css()
    else:
      self.evaluate_js_buffer()

  def evaluate_js_buffer(self):
    self.evaluate_js("".join(vim.current.buffer[:]))

  def evaluate_js_selection(self):
    (sx, sy), (ex, ey) = vim.current.buffer.mark("<"), vim.current.buffer.mark(">")

    sx -= 1
    sy -= 1
    ex -= 1

    sl, el = vim.current.buffer[sx][sy:], vim.current.buffer[ex][:ey]

    lines = [sl] + vim.current.buffer[sx + 1:ex] + [el]
    self.evaluate_js("".join(lines))

  def reload_css(self):
    self.call(BrowserConnectConstants.RELOAD_CSS_URL)

  def reload_page(self):
    self.call(BrowserConnectConstants.RELOAD_PAGE_URL)

  def evaluate_js(self, body):
    self.call(BrowserConnectConstants.EVALUATE_JS_URL, body)

  def call(self, url, data=None):
    try:
      if data is None: urlopen(url)
      else: urlopen(url, data)
    except URLError:
      sys.stderr.write("BrowserConnect: could not connect to server.")
    

browserConnect = BrowserConnect()
EOF
" }}}
" Functions. {{{
function! s:EvaluateSelection(beg, end)
    python browserConnect.evaluate_js_selection()
endfunction

function! s:EvaluateBuffer()
    python browserConnect.evaluate_buffer()
endfunction

function! s:ReloadPage()
    python browserConnect.reload_page()
endfunction
" }}}
" Commands. {{{
command! -range -nargs=0 BCEvaluateSelection call s:EvaluateSelection(<line1>, <line2>)
command!        -nargs=0 BCEvaluateBuffer    call s:EvaluateBuffer()
command!        -nargs=0 BCReloadPage        call s:ReloadPage()
" }}}
" Mappings. {{{
if !exists("g:bc_no_mappings")
    vmap <silent><LocalLeader>be :BCEvaluateSelection<CR>
    nmap <silent><LocalLeader>be :BCEvaluateBuffer<CR>
    nmap <silent><LocalLeader>br :BCReloadPage<CR>
endif
" }}}
" Autocommands. {{{
if !exists("g:bc_no_au")
    au BufWritePost *.html,*.js :BCReloadPage
    au BufWritePost *.css :BCEvaluateBuffer
endif
" }}}
