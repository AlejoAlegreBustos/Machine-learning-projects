import json

# Nombre de tu archivo
filename = r'computer-vision\ViT-Xray-Explainability\VIT_Xray.ipynb'

# 1. Leemos el archivo
with open(filename, 'r', encoding='utf-8') as f:
    data = json.load(f)

# 2. Buscamos y eliminamos la sección corrupta 'widgets'
if 'widgets' in data['metadata']:
    del data['metadata']['widgets']
    print("✅ Sección 'widgets' eliminada correctamente.")
else:
    print("ℹ️ No se encontró la sección 'widgets'.")

# 3. Guardamos el archivo limpio
with open(filename, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=1)

print("¡Listo! Intenta subir el archivo a GitHub de nuevo.")