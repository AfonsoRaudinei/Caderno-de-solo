import re

with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "r") as f:
    content = f.read()

pattern = r"  LaudoRecomendacao _toLaudo\(.*?\}\n\nclass _Badge"
replacement = "class _Badge"
new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "w") as f:
    f.write(new_content)
