import json, sys
d = json.load(open('../../app/src/main/assets/fx/catalog.json'))
cats = [int(x) for x in sys.argv[1].split(',')]
kinds = sys.argv[2].split(',') if len(sys.argv) > 2 else None
for e in d['effects']:
    if e['cat'] not in cats or e.get('hidden'): continue
    if kinds and e['kind'] not in kinds: continue
    ps = []
    for p in e['params']:
        x = p['kind']
        if x == 'jog': x = f"{p['min']:g}..{p['max']:g}{p.get('unit','')}" + ('XY' if p.get('two') else '') + ('XYZ' if p.get('three') else '')
        elif x == 'choice': x = '/'.join(p['opts'])
        elif x == 'color': x = 'renk'
        d0 = p['def'] if not isinstance(p['def'], list) else 'grad'
        ps.append(f"{p['k']}[{x}]={d0}" + (f",{p.get('defY'):g}" if p.get('two') else ''))
    print(f"{e['type']}|{e['kind']}|{e['name']}: {e['desc'][:80]} || " + "; ".join(ps))
