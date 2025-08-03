# Corne Keyboard

# Table of Content

- [Introduction](#introduction)
- [QML Setup](#qmk-setup)
- [Development](#development)

## Introduction

- This documentation is for creating and set up of a Corne keyboard on macOS.

- This documentation assumes that you already have Homebrew install on the machine you are developing on.

- This project assumes some knowledge of the C programming language.

## QMK setup

Install QMK using Homebrew:

```bash
brew install qmk/qmk/qmk
```

Navigate to the [QMK toolbox Github](https://github.com/qmk/qmk_toolbox/releases) in a browser and download the .pkg file for macOS.

Once downloaded, run the installation of the application (note that you may need to go to you privacy settings and allow this application to open and run).

Once the installation of the toolbox is complete, setup a QMK project.

Running this command will clone the qmk firmware repo to `~/qmk_firmware`.

```bash
# Follow the prompts of this command
qmk setup
```

The name of the keyboard is required to continue, this can be found by using the command:

```bash
qmk list-keyboards

# As this project uses a Corne keyboard I can find the name of the key board using
qmk list-keyboards | grep "crkbd"

# This project is using the crkbd/rev1
# NOTE - I may need to use mechboards/crkbd/pro
```

To setup a new keymap run:

```bash
qmk new-keymap -kb crkbd/rev1 -km CharlesTheIX
# NOTE - This command ask you for a converter, I am currently using option [1] - None
```

This will create a new keymap setup in the `~/qmk_firmware/keyboards/crkbd/keymaps/CharlesTheIX`.

Change your working directory to this location to start development.

```bash
cd ~/qmk_firmware/keyboards/crkbd/keymaps/CharlesTheIX
```

`This repository is the contents of that keymap directory.`

## Development
