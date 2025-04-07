import argparse

def parse_hex(hex_str):
    hex_str = hex_str.strip('#')
    if len(hex_str) == 3:
        hex_str = ''.join([c * 2 for c in hex_str])
    elif len(hex_str) != 6:
        raise ValueError(f"Invalid hex code: {hex_str}")
    try:
        r = int(hex_str[0:2], 16)
        g = int(hex_str[2:4], 16)
        b = int(hex_str[4:6], 16)
    except ValueError:
        raise ValueError(f"Invalid hex code: {hex_str}")
    return r, g, b

def blend_color(rgb, bg_rgb, alpha):
    r, g, b = rgb
    bg_r, bg_g, bg_b = bg_rgb
    alpha = max(0.0, min(1.0, alpha))
    r_mixed = round(r * alpha + bg_r * (1 - alpha))
    g_mixed = round(g * alpha + bg_g * (1 - alpha))
    b_mixed = round(b * alpha + bg_b * (1 - alpha))
    return (r_mixed, g_mixed, b_mixed)

def ansi_fg(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"

def main():
    parser = argparse.ArgumentParser(description='Convert HEX to RGBA with alpha blending.')
    parser.add_argument('hex', help='Input HEX code (with or without #)')
    parser.add_argument('--alpha', type=float, help='Specific alpha value (0.00-1.00)')
    parser.add_argument('--background', default='FFFFFF', help='Background color (default: white)')
    args = parser.parse_args()

    try:
        r, g, b = parse_hex(args.hex)
    except ValueError as e:
        print(f"Error: {e}")
        return

    try:
        bg_r, bg_g, bg_b = parse_hex(args.background)
    except ValueError as e:
        print(f"Background error: {e}")
        return

    alphas = [round(i/10, 1) for i in range(1, 11)] if not args.alpha else [round(args.alpha, 2)]
    if any(a < 0 or a > 1 for a in alphas):
        print("Error: Alpha must be between 0.00 and 1.00")
        return

    original_hex = f"#{args.hex.strip('#').upper()}"
    for alpha in alphas:
        mixed_r, mixed_g, mixed_b = blend_color((r,g,b), (bg_r,bg_g,bg_b), alpha)
        mixed_hex = f"#{mixed_r:02X}{mixed_g:02X}{mixed_b:02X}"
        alpha_fmt = f"{alpha:.2f}" if args.alpha else f"{alpha:.1f}"
        rgba = f"rgba( {r}, {g}, {b}, {alpha_fmt})"

        part1 = f"{ansi_fg(r,g,b)}{original_hex}\033[0m"
        part2 = f"{ansi_fg(mixed_r,mixed_g,mixed_b)}{rgba}\033[0m"
        part3 = f"{ansi_fg(mixed_r,mixed_g,mixed_b)}{mixed_hex}\033[0m"
        print(f"{part1} -> {part2} -> {part3}")

if __name__ == "__main__":
    main()
