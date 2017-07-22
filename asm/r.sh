#!/bin/sh

gcc -E $1 > aout.ss
ruby asm.rb -f=aout.ss
cp ./A_ram.mif /Users/erwinmatthijssen/Dropbox\ \(Persoonlijk\)/HACK/PLAY/asm.mif
cp ./A.bin /Users/erwinmatthijssen/Dropbox\ \(Persoonlijk\)/HACK/PLAY/asm.bin