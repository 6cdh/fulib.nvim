# fulib.nvim

A functional library written in Fennel, also a nvim plugin.

## Status

Beta. Breaking changes may occur.

## Install

Install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

``` lua
use '6cdh/fulib.nvim'
```

or any other plugin manger you like.

Or add the following lua code into the head of your init file if you use this plugin in
your nvim config file.

``` lua
local fulib_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/fulib.nvim'
if vim.fn.empty(vim.fn.glob(fulib_path)) > 0 then
    vim.api.nvim_command(
        string.format(
            '!git clone https://github.com/6cdh/fulib.nvim --depth 1 %s',
            fulib_path
        )
    )
end
```

## Document

See [docs.md](docs.md)

## Test

Executing tests requires

-   [Fennel](https://github.com/bakpakin/Fennel) in your PATH.

Clone this repo and run

``` shell
cd fulib.nvim/test
fennel tests.fnl
```
