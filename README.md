# Corne Keyboard

_Correct as of: August 2025_

_Resources:_

- _[QMK documentation](https://docs.qmk.fm/newbs)_
- _[Josean's video](https://www.youtube.com/watch?v=AA8fw2MbpYg)_
- _[BXO511's comment](https://www.reddit.com/r/olkb/comments/10baza0/hex_to_uf2_for_rp2040/)_
- _[Mechboards repository](https://github.com/qmk/qmk_firmware/tree/master/keyboards/mechboards/crkbd)_

## Table of Contents

- [Introduction](#introduction)
- [Dependencies](#dependencies)
  - [QMK](#qmk)
  - [C Make](#c-make)
- [Development](#development)
  - [Commands](#commands)
    - [clone](#clone)
    - [generate_logos](#generate_logos)
    - [sync](#sync)
    - [compile](#compile)
    - [flash](#flash)
  - [File Structure](#file-structure)

## Introduction

- This project uses and is heavily based on the [Mechboards/crkbd/pro](https://github.com/qmk/qmk_firmware/tree/master/keyboards/mechboards/crkbd) repository.

- This documentation aims to:

  - Integrate this repo with the [QMK](https://qmk.fm) cli
  - Keep a record of how I was able to get my Corne (Helidox) Choc keyboard from [Mechboards](https://mechboards.co.uk) flashed using my machine

- This documentation assumes the following:

  - You have some knowledge of C
  - You are using macOS (Apple Silicon)
  - You have Xcode installed
  - You have [Homebrew](https://brew.sh) installed

- This repository uses a Bash file to help with compiling and flashing the firmware to the controllers and will need to be made executable on your machine:

```bash
chmod +x ./.scripts.sh
```

## Dependencies

### QMK

Homebrew has a tap that can be used to install QMK onto the machine.

```bash
brew install qmk/qmk/qmk

# To check if it is available
qmk --version
# 1.1.8
```

Setup the QMK environment by cloning the QMK firmware into your home path - this is the default location.

You may be prompted for inputs, this record selected the defaults - I may have made things more complicated because of this.

```bash
qmk setup
# Creates a directory at ~/qmk_firmware
```

> ---
>
> `NOTE:` QMK Toolbox
>
> There is a tool that can be installed called [QMK Toolbox](https://qmk.fm/toolbox).
> It was downloaded for this record but never used due to the microchips in the build.
>
> ---

### C make

This project used C with QMK to create the firmware.

It may or may not be needed but during this project I installed `make` via Homebrew:

```bash
brew install make
```

## Development

### Commands

The .scripts.sh file contains a number of helper command to aid with development:

#### clone

This script is used for creating a new keyboard based on an existing one, it will take all the files from the [KEYBOARD] and copy them to the [NEW_KEYBOARD]:

```bash
# KEYBOARD default: default
# NEW_KEYBOARD default: test
./.scripts.sh clone [KEYBOARD?] [NEW_KEYBOARD?]
```

#### generate_logos

This command is used to convert the master_logo.bmp and slave_logo.bmp images into byte arrays that can be used on the oled display, it will take the bmp files from the [KEYBOARD]/assets directory and run the python code to generate the [KEYBOARD]/logos.c file.

**`NOTE`:** The bmp image files should be created in a canvas of 128 x 32 px (the size of the OLEDs).

```bash
# KEYBOARD default: default
./.scripts.sh generate_logos [KEYBOARD?]
```

#### sync

This command is used for copying your firmware code to the QMK directory so that it can be compiled using QMK CLI, it will take all the files from the [KEYBOARD] directory and copy them to ~/qmk_firmware/keyboards/[KEYBOARD].

```bash
# KEYBOARD default: default
./.scripts.sh sync [KEYBOARD?]
```

#### compile

This command is used to compile the firmware for a given [KEYMAP] and move the firmware file to the repository for the flashing command, it will use QMK to make the firmware and then move the firmware file to [KEYBOARD]/firmware.uf2.

**`NOTE`:** The command assumes that you have run the `sync` command before this command.

```bash
# KEYBOARD default: default
# KEYMAP default: default
./.scripts.sh compile [KEYBOARD?] [KEYMAP?]
```

#### flash

This command is used to flash the firmware onto a controller presenting as a predefined volume, it will copy the firmware.uf2 file found in the [KEYBOARD] directory, to the controller volume, re-flashing the controller automatically.

**`NOTE`:** The command assumes that you have run the `compile` command before this command.

```bash
# KEYBOARD default: default
./.scripts.sh flash [KEYBOARD?]
```

### File Structure

- .python
  - [generate_logos.py](./.python/generate_logos.py)
- [KEYBOARD]
  - assets
  - keymaps
    - [KEYMAP]
      - [keymap.c](./default/keymaps/default/keymap.c)
      - [rules.mk](./default/keymaps/default/rules.mk)
  - [config.h](./default/config.h)
  - [keyboard.json](./default/keyboard.json)
  - [logos.c](./default/logos.c)
  - [oled.c](./default/oled.c)
  - [post_rules.mk](./default/post_rules.mk)
- [.scripts.sh](./.scripts.sh)

> ---
>
> #### .python
>
> > This directory contains python development automation scripts.
>
> #### [KEYBOARD]
>
> > This directory containers the all the files associated with the keyboard - when running any automation scripts and you have to refer to [KEYBOARD], this directory will be the root target.
>
> ##### assets
>
> > Used to store files that are not used in the compilation of the firmware but are part of the development workflow.
> >
> > For example, to use the generate_logos command the files `slave_logo.bmp` and `master_logo.bmp` must exist in this directory.
>
> ##### keymaps
>
> > This directory contains the keymaps available fo build into the selected keyboard.
> >
> > Each [KEYMAP] directory should contain two files: `keymap.c` and `rules.mk`.
> >
> > keymap.c contains the keyboard layout - use the [documentation](https://docs.qmk.fm/keycodes) for more details on key codes.
> >
> > rules.mk sets the available functionality of the keyboard.
>
> ##### config.h
>
> > This file contains the configurations of the keyboard, for example setting which RGB modes are available.
>
> ##### keyboard.json
>
> > This file contains the metadata for the keyboard setup.
>
> ##### logos.c
>
> > This file is generated using the generate_logos command and contains the byte maps generated from the master_logo.bmp and slave_logo.bmp in the [KEYBOARD]/assets.
>
> ##### oled
>
> > This file contains the code for handling what is displayed on the oled displays.
>
> > It uses the [QMK quantum library for C](https://docs.qmk.fm).
>
> ##### post_rules.mk
>
> > This file is used to import the external files, for example oled.c.
>
> #### .scripts.sh
>
> > This file handles the development commands.
>
> ---

## Compilation

I started this project believing that the boards were Pro-Mirco (as in the product description), however it turned out that they are RP2040 boards.

This caused much confusion until I found out about [converters](https://docs.qmk.fm/feature_converters#converters) - this compilation uses a conversion:

```bash
qmk compile -e CONVERT_TO=rp2040_ce -kb [KEYBOARD] -km [KEYMAP]

# Alternatively you can use the scripts.sh file
chmod + ./.scripts.sh

# This assumes you have already run the sync command described in the development section
# KEYBOARD default: default
# KEYMAP default: default
./scripts.sh compile [KEYBOARD?] [KEYMAP?]
```

This will create a `.uf2` file in the ~/qmk_firmware directory, if you ran the 'compile' command, then the firmware file will be moved to the [KEYBOARD] directory.

This file will be needed in the flashing step.

## Flashing

> ---
>
> To start, disconnect the keyboards power and trc connections.
>
> Both parts of the Corne board will need to be flashed so repeat this process for both halves, starting with the master half.
>
> ---

The controllers will need to be in boot mode to be able to flash them - you can do this by holding down the button located at the last column (from the controller) and the top row, as you connect the power to the controller.

If the controller's OLED blank and the volume 'RPI-RP2' should be available - a shortcut for this directory should appear on the desktop, to confirm:

```bash
cd /Volumes/RPI-RP2
```

`If you cannot enter this directory then the controller is not in boot mode.`

Otherwise, run the `flash` command if you have a compiled file ready, otherwise run the `all` command to sync, compile and flash:

```bash
# If firmware update to date and compiled
# KEYBOARD default: default
./.scripts.sh flash [KEYBOARD?]

# To run all steps
# KEYBOARD default: default
./.scripts.sh all [KEYBOARD?]

# To run all steps except the generate_logo
# KEYBOARD default: default
./.scripts.sh all_no_logo [KEYBOARD?]
```

Once this is run and it is complete the controller should reboot itself.

Repeat for the slave side.
