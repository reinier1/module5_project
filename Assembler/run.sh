#!/bin/bash
make all||exit 1
./mod5asm ./test.s
