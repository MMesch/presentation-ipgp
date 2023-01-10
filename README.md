---
title: NixOS and Computational Reproducibility
subtitle: WHY YOU WON'T NEED TO INSTALL SOFTWARE ANYMORE SOON
author: Matthias Meschede
save_diagrams: true
---

# Part 1: Reproducibility

# I. Depth

## Why reproducing something _always_ is impossible

## "Could you pass me the salt?"

## "Could you pass me the salt, _please_?"

## ¿Me podrias pasar la sal?

## 塩をくれませんか？

## किं त्वं लवणं मां पारयितुं शक्नोषि ?

## The Eagle Has Landed

## Symbols are not everything

We need to interpret messages. The action depends on the interpreter as much as on the message.

##

![Nasa's Golden Record](../The_Sounds_of_Earth.jpg)

## now programming: What happens here?

```python
print "Hello World"
```

## It depends

- interpret with a text editor and the code appears.
- interpret with Python 2 and "Hello World" appears.
- interpret with Python 3 and an error appears.

## Send description of the interpreter as well?

## 

We need

1. the program
2. the interpreter of the program
3. the interpreter of the interpreter of the program
4. the interpreter of the interpreter of the interpreter of the program
5. ...

## Infinite Recursion. This never ends.

## More concrete

1. code
1. code of all dependencies
1. code of compilers/interpreters
1. code/description of the operating system
1. hardware description
1. the physical environment in which the hardware is running
1. description of the physical laws
1. ?

## Even more concrete

1. `print "Hello World"`
2. ship code + build/run instructions for Python2 + all its dependencies
3. ship code for gcc and all its dependencies to compile Python
4. ship code/binaries for the Linux on which this should run
5. ship exact description of the Laptop you are using
6. ship exact description of the environment in which you use the Laptop (plugged in, connected to nuclear power plant)
7. ship exact description of the physical laws ...
8. ...

## Conclusion: Cut the chain!

... but where?

# Example

## Stability

1. code (least)
2. ecosystem dependencies
3. system dependencies
4. OS kernel
5. hardware (most)

## Naive

1. code 🗸
2. ecosystem dependencies
3. system dependencies
4. OS kernel
5. hardware

## Ecocsystem (pip, conda, ...)

1. code 🗸
2. ecosystem dependencies 🗸
3. system dependencies (some)
4. OS kernel
5. hardware

## Docker

1. code 🗸
2. ecosystem dependencies 🗸
3. system dependencies 🗸
4. OS kernel
5. hardware

## Nix

1. code 🗸
2. ecosystem dependencies 🗸
3. system dependencies 🗸
4. OS kernel (optional)
5. hardware (optional)

# II. Hermeticity

## Why reproducing something _most of the time_ is hard

## Programs interact with their environment (Side Effects)

- external files are used
- user input is required
- sensor data is captured
- random numbers are generated
- order is determined by hardware (race condition)
- timestamps can be used

## Uncontrolled side effects ↣ no reproducibility

## This is not unlike lab experiments

# III. Conclusions

##

- _Perfect_ Reproducibility is a dream
- High levels of reproducibility are possible. Alignment on _stable standards_ and
  _hermeticity_ are key.

# PART 2: NixOS

## Every program ships everything down to the OS kernel

## NixOS enforces hermeticity by default

- the content of every accessed external file/internet has to be declared
- timestamps are reset to 01-01-1970
- no user input
- limited hardware access

## Other benefits

- unlike just shipping one big blob (Docker) Nix keeps dependencies in isolated
  building blocks from which new environments can be generated.
- building blocks are gathered in a huge online library called _nixpkgs_ with
  80000+ packages.

## Consequence

- Every program comes as a highly reproducible closure that includes everything
(source code, source code of all dependencies, all build commands, ...) required
to build and run it.
- Every closure has a unique name that is derived from its content.
- closure building blocks are stored in a database (local or remote)

## Show example for Python3 in terminal

## Example JupyterWith graph

![Jupyter graph](../jupyter-graph.png)

## Example Nixpkgs graph

![Nixpkgs graph](../nixpkgs-graph.png)

## Show file to generate this presentation

## Show nixpkgs repository on GitHub

## What about installing software?

# Things you can do with NixOS

##

Run code from 10 years ago

##

Take file from colleague and run it instantly

##

Use code from colleagues and build something on top

##

Use esoteric scripts/tools and be sure that they will still work tomorrow

##

Design a whole reproducible development environment in a text file

##

Describe your whole system in a file with detailed configuration and instantly get it on reinstall

##

Configure a whole reproducible system with multiple servers that talk to each other in a single text file

# Further Reading

##

- [Website](https://nixos.org/)
- [Nix dev tutorials](https://nix.dev/)
- [Nix pills series](https://nixos.org/guides/nix-pills/)
- [Lecture series about history](https://www.youtube.com/playlist?list=PLt4-_lkyRrOMWyp5G-m_d1wtTcbBaOxZk)
- [Configuration collection](https://nixos.wiki/wiki/Configuration_Collection)
