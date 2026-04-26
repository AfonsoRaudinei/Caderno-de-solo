import os

def replace_in_file(path, old, new):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    if old in content:
        content = content.replace(old, new)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {path} for {old}")

all_files = []
for root, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            all_files.append(os.path.join(root, f))
            
for root, dirs, files in os.walk('test'):
    for f in files:
        if f.endswith('.dart'):
            all_files.append(os.path.join(root, f))

replacements = [
    ("package:soloforte/presentation/auth/", "package:soloforte/features/auth/presentation/"),
    ("package:soloforte/presentation/historico/", "package:soloforte/features/historico/presentation/"),
    ("package:soloforte/presentation/config/", "package:soloforte/features/config/presentation/"),
    ("package:soloforte/presentation/main/", "package:soloforte/features/main/presentation/"),
]

for filepath in all_files:
    for old, new in replacements:
        replace_in_file(filepath, old, new)
        
print("Migration of remaining presentation directories complete!")
