This plugin implements a VIM interface for [browser-connect-server][2]
in order to provide a live coding environment similar to the one
currently available in [LightTable][3].

Installation
------------

Use [pathogen][1] and clone this repo into your `~/.vim/bundle`
directory, afterwards copy the following line into your `.vimrc` file
and update the path to reflect the actual location of the
`browser-connect.vim` folder.

```vimscript
let g:bc_server_path = "/home/me/.vim/bundle/browser-connect.vim/server"
```

By default, the plugin will map it's actions to `<C-CR>`, if you would
like it not to do that simply add the following line to your `.vimrc`
file:

```vimscript
let g:bc_no_mappings = 1
```

Usage
-----

Copy the following code snippet into your template and open it inside
of a (modern) browser. Make sure that you have VIM running before you
do so.

```html
<script src="http://localhost:9000/ws"></script>
```

After doing so, you should be able to evaluate CSS buffers and JS
buffers using `<C-CR>` as well as selections of JS. The changes should be
instantly reflected in the browser.

Requirements
------------

* VIM 7.0+ compiled with +python
* Python 2.6+

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/Bogdanp/browser-connect-server
[3]: http://www.lighttable.com/
