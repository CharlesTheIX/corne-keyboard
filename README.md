# Corn Keyboard

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
    - [MacOS](#macos)
    - [Windows](#windows)
    - [Setup](#setup)
  - [C Make](#c-make)
- [Development](#development)

## Introduction

- This project uses and is heavily based on the [Mechboards/crkbd/pro](https://github.com/qmk/qmk_firmware/tree/master/keyboards/mechboards/crkbd) repository.

- This documentation aims to:
  - Integrate this repo with the [QMK](https://qmk.fm) cli
  - Keep a record of how I was able to get my Corne (Helidox) Choc keyboard from [Mechboards](https://mechboards.co.uk) flashed using my machine

- This documentation assumes the following:
  - You have some knowledge of C
  - You are using macOS (Apple Silicon) or Windows
  - You have Xcode installed if you are using macOS
  - You have [Homebrew](https://brew.sh) installed if you are using macOS

- This repository uses a Bash file to help with compiling and flashing the firmware to the controllers and will need to be made executable on your machine:

```bash
       chmod +x ./scripts.sh
```

## Dependencies

### QMK

#### MacOS

Homebrew has a tap that can be used to install QMK onto the machine.

```bash
brew install qmk/qmk/qmk

# To check if it is available
qmk --version
# 1.1.8
```

#### Windows

QMK can be downloaded directly from this [link](https://github.com/qmk/qmk_distro_msys/releases/tag/1.11.0).

Once downloaded, run the installer `QMK_MSYS.exe` - This will add the drivers and dependencies for QMK (follow the wizard).

Once the application is installed you can open the dedicated QMK terminal - this is needed to run QMK commands.

`It is required that you use the QMK terminal to run any of the compile, flash and development commands from this point using the QMK terminal`.

#### Setup

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

This step is not needed on Windows.

This project used C with QMK to create the firmware.
It may or may not be needed but during this project I installed `make` via Homebrew:

```bash
brew install make
```

## Development

List the files and what they do, based on the Mechboards initial set up.

using the sync bash script to move the current repo to the correct place to use the qmk compose and flash commands.

## Compilation

I started this project believing that the boards were Pro-Mirco (as in the product description), however it turned out that they are RP2040 boards.

This caused much confusion until I found out about [converters](https://docs.qmk.fm/feature_converters#converters) - this compilation uses a conversion:

```bash
qmk compile -e CONVERT_TO=rp2040_ce -kb charlestheix -km default

# Alternatively you can use the scripts.sh file
chmod + ./scripts.sh

# This assumes you have already run the sync command described in the development section
./scripts.sh compile
```

This will create a `.uf2` file in the ~/qmk_firmware directory.
This file will be needed in the flashing step.

## Flashing
