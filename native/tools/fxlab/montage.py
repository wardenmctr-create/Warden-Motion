# Kategori tanıtım videosu: efekt önizlemelerinden ızgara (Türkçe adlarla) → MP4
# Kullanım: python3 montage.py <kareler klasörü> <çıktı.mp4> <başlık> tür1 tür2 ...
import sys, os, json, subprocess
from PIL import Image, ImageDraw, ImageFont
src, out, title, types = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
cat = {e['type']: e for e in json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../app/src/main/assets/fx/catalog.json')))['effects']}
FONT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../app/src/main/res/font/inter_bold.otf')
f1 = ImageFont.truetype(FONT, 15); f2 = ImageFont.truetype(FONT, 26)
types = [t for t in types if os.path.isdir(os.path.join(src, t)) and len(os.listdir(os.path.join(src, t))) >= 20]
cols = 6; T = 170; LH = 40; rows = (len(types) + cols - 1) // cols
W = cols * T + (cols + 1) * 8; H = 64 + rows * (T + LH) + 8
W += W % 2; H += H % 2
tmp = os.path.join(src, '_m'); os.makedirs(tmp, exist_ok=True)
frames = {t: sorted(os.listdir(os.path.join(src, t))) for t in types}
n = min(len(v) for v in frames.values())
for i in range(n):
    im = Image.new('RGB', (W, H), (11, 20, 48)); d = ImageDraw.Draw(im)
    d.text((16, 16), title, font=f2, fill=(247, 248, 250))
    for k, t in enumerate(types):
        r, c = divmod(k, cols); x = 8 + c * (T + 8); y = 64 + r * (T + LH)
        fr = Image.open(os.path.join(src, t, frames[t][i])).convert('RGB').resize((T, T), Image.LANCZOS)
        im.paste(fr, (x, y))
        name = cat[t]['name']
        while d.textlength(name, font=f1) > T and len(name) > 4: name = name[:-2] + '…' if not name.endswith('…') else name[:-3] + '…'
        d.text((x + T / 2, y + T + 6), name, font=f1, fill=(220, 233, 255), anchor='ma')
    im.save(os.path.join(tmp, f'{i:03d}.png'))
subprocess.run(['ffmpeg', '-v', 'error', '-y', '-framerate', '12', '-stream_loop', '2', '-i', os.path.join(tmp, '%03d.png'), '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '24', '-preset', 'slow', '-movflags', '+faststart', out], check=True)
print(out, os.path.getsize(out) // 1024, 'KB')
