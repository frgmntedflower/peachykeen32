# PeachyKeen32 (sh)

Name inspired by my girlfriend (<3) who just gave me a Monster Peachy Keen which is so good that I had to write a shell in ARM.

---

## ✨ Features

- REPL-style input loop (`peachykeen32>`)
- Direct syscall usage (no libc!)
- Custom string parsing and argument buffers
- Up to 3 space-separated arguments supported per command
- Easily extendable command structure
- Works in QEMU or on bare-metal ARM32

## 💻 Commands

### help
Prints a list of available commands and how to use them.

### exit
Exits the shell (calls exit(0) via syscall 1).

### fwrite <text> <filename>
Writes <text> to <filename>. If the file doesn’t exist, it’ll be created.

Example:
fwrite "Hello ARM world" hello.txt

### ndir <dirname>
Creates a new directory with the given name. (WIP)

Example:
ndir testfolder

### rand
Prints 16 bytes of entropy from /dev/urandom.

---

⚠️ Disclaimer

This is a toy shell made for fun and low-level exploration. It will yell at you, crash on unknown commands, and has no interest in POSIX compliance. You’ve been warned.

---
