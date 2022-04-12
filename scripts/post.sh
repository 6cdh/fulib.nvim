#!/bin/sh

fennel -c fnl/fulib/init.fnl > lua/fulib/init.lua
cat fnl/fulib/init.fnl | fennel scripts/doc.fnl | prettier --parser markdown > docs.md
