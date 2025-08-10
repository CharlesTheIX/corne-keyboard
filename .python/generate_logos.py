#!/bin/env python3

import os
from PIL import Image

WIDTH = 128
HEIGHT = 32
INVERT = True
BYTES_PER_LINE = 128
SLAVE_VAR_NAME = "slave_logo"
MASTER_VAR_NAME = "master_logo"
SLAVE_FUNC_NAME = "render_slave_logo"
MASTER_FUNC_NAME = "render_master_logo"
KEYBOARD_DEFAULT = os.getenv('QMK_KEYBOARD_DEFAULT')

def bmp_to_byte_array(bmp_path: str):
    img = Image.open(bmp_path).convert("1")
    if img.size != (WIDTH, HEIGHT):
        raise ValueError(f"Image must be {WIDTH}x{HEIGHT}, not {img.size}")

    data = []
    pixels = img.load()
    pages = HEIGHT // 8
    for page in range(pages):
        for x in range(WIDTH):
            byte = 0
            for bit in range(8):
                y = page * 8 + bit
                if pixels[x, y] == 0:
                    byte |= (1 << bit)
            if INVERT:
                byte = ~byte & 0xFF
            data.append(byte)

    return data

def bmp_to_qmk_render_function(master_bmp_path: str, slave_bmp_path: str, c_output: str):
    slave_data = bmp_to_byte_array(slave_bmp_path)
    master_data = bmp_to_byte_array(master_bmp_path)
    output_lines = [
        '#include "quantum.h"',
        '',
        '#ifdef OLED_ENABLE',
        f'void {MASTER_FUNC_NAME}(void) {{',
        f'  static const char PROGMEM {MASTER_VAR_NAME}[] = {{',
    ]

    for i in range(0, len(master_data), BYTES_PER_LINE):
        line = ', '.join(f"{b:3}" for b in master_data[i:i + BYTES_PER_LINE])
        output_lines.append(f'    {line},')

    output_lines += [
        '  };',
        f'  oled_write_raw_P({MASTER_VAR_NAME}, sizeof({MASTER_VAR_NAME}));',
        '}',
        '',
        f'void {SLAVE_FUNC_NAME}(void) {{',
        f'  static const char PROGMEM {SLAVE_VAR_NAME}[] = {{',
    ]

    for i in range(0, len(slave_data), BYTES_PER_LINE):
        line = ', '.join(f"{b:3}" for b in slave_data[i:i + BYTES_PER_LINE])
        output_lines.append(f'    {line},')

    output_lines += [
        '  };',
        f'  oled_write_raw_P({SLAVE_VAR_NAME}, sizeof({SLAVE_VAR_NAME}));',
        '}',
        '#endif'
    ]

    os.makedirs(os.path.dirname(c_output), exist_ok=True)
    with open(c_output, "w") as f:
        f.write('\n'.join(output_lines))

    print(f"C render function written to {c_output}")

if __name__ == "__main__":
    keyboard = input(f"Enter keyboard name (default: '{KEYBOARD_DEFAULT}'): ").strip() or f"{KEYBOARD_DEFAULT}"
    c_output = f"./{keyboard}/logos.c"

    master_bmp = f"./{keyboard}/assets/master_logo.bmp"
    if not os.path.exists(master_bmp):
        raise FileNotFoundError(f"Image file not found: {master_bmp}")

    slave_bmp = f"./{keyboard}/assets/slave_logo.bmp"
    if not os.path.exists(slave_bmp):
        raise FileNotFoundError(f"Image file not found: {slave_bmp}")
    
    bmp_to_qmk_render_function(master_bmp, slave_bmp, c_output)
