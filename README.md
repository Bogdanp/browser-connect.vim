This plugin implements a VIM interface for [browser-connect-server][2]
in order to provide a live coding environment similar to the one
currently available in [LightTable][3].

If you would like to see it in action, a (very crude) demo video
is available [here][4].

Installation
------------

Use [pathogen][1] (or [Vundle][5]) and clone this repo into your `~/.vim/bundle`
directory. That's it, you're good to go.

Notes
-----

If you installed the plugin someplace other than
`~/.vim/bundle/browser-connect.vim` you will have to paste the
following snippet into your `.vimrc` file and update the path to
reflect the actual location of the `browser-connect.vim` folder.

```vim
let g:bc_server_path = "/home/me/.vim/bundle/browser-connect.vim/server"
```

By default, the plugin will map it's actions to `<C-CR>`. If you would
prefer that it not do that, simply add the following line to your
`.vimrc` file:

```vim
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
instantly reflected in your browser.

Requirements
------------

* VIM 7.0+ compiled with +python
* Python 2.6+
* Java 7+

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/Bogdanp/browser-connect-server
[3]: http://www.lighttable.com/
[4]: http://www.youtube.com/watch?v=Sq-zTpxStBc
[5]: https://github.com/gmarik/vundle