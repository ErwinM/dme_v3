#!/bin/sh

m4 $1 > expanded.s
asm.rb -f=expanded.s

