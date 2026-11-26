# Shader paketlerini (shaders/*.glsl) tek tek dosyalara böler: "//== tür" ile başlayan bölümler → assets/fx/<tür>.glsl
# Ana efekt bölümleri (alt geçiş adı olmayanlar, "_" içermeyenler) ready.txt'ye eklenir.
import os, re, sys, glob
D = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(D, '../../app/src/main/assets/fx')
ready = set(open(os.path.join(D, 'ready.txt')).read().split()) if os.path.exists(os.path.join(D, 'ready.txt')) else set()
n = 0
for f in sorted(glob.glob(os.path.join(D, 'shaders', '*.glsl'))):
    parts = re.split(r'^//== ', open(f, encoding='utf-8').read(), flags=re.M)
    for part in parts[1:]:
        head, body = part.split('\n', 1)
        name = head.split()[0]
        open(os.path.join(OUT, name + '.glsl'), 'w', encoding='utf-8').write('// ' + name + '\n' + body.strip() + '\n'); n += 1
        if '-noready' not in head:
            base = name.rsplit('_', 1)[0] if re.search(r'_[a-z]$', name) else name
            ready.add(base)
    for extra in re.findall(r'^//\+ready (.+)$', open(f, encoding='utf-8').read(), flags=re.M): ready.update(extra.split())
open(os.path.join(D, 'ready.txt'), 'w').write('\n'.join(sorted(ready)) + '\n')
print(n, 'shader yazıldı,', len(ready), 'hazır efekt')
