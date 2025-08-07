import os
from PIL import Image

def bmp_to_qmk_render_function(
    input_path: str,
    output_path: str,
    width: int = 128,
    height: int = 32,
    invert: bool = True,
    var_name: str = "logo",
    bytes_per_line: int = 32,
    function_name: str = "render_logo",
):
    """
    Converts a 1-bit BMP image to a full C render function compatible with QMK.
    """
    img = Image.open(input_path).convert("1")
    if img.size != (width, height):
        raise ValueError(f"Image must be {width}x{height}, not {img.size}")

    pixels = img.load()
    data = []

    for x in range(width):
        for page in range(height // 8):
            byte = 0
            for bit in range(8):
                y = page * 8 + bit
                if pixels[x, y] == 0:
                    byte |= (1 << bit)
            if invert:
                byte = ~byte & 0xFF
            data.append(byte)

    output_lines = [
        '#include "quantum.h"\n',
        '#ifdef OLED_ENABLE',
        f'void {function_name}(void) {{',
        f'  static const char PROGMEM {var_name}[] = {{',
    ]

    for i in range(0, len(data), bytes_per_line):
        line = ', '.join(f"{b:3}" for b in data[i:i + bytes_per_line])
        output_lines.append(f'    {line},')

    output_lines += [
        '  };',
        f'  oled_write_raw_P({var_name}, sizeof({var_name}));',
        '}',
        '#endif\n'
    ]

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        f.write('\n'.join(output_lines))

    print(f"✅ C render function written to {output_path}")

# === Save to File ===
if __name__ == "__main__":
    c_filename = "logo.c"
    bmp_filename = "logo.bmp"
    input_dir = "charlestheix"
    output_dir = "charlestheix"

    input_path = os.path.join(input_dir, bmp_filename)
    output_path = os.path.join(output_dir, c_filename)

    bmp_to_qmk_render_function(input_path, output_path)
