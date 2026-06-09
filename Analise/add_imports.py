with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "r") as f:
    lines = f.readlines()

new_imports = [
    "import 'package:soloforte/domain/models/recomendacao_model.dart';\n",
    "import 'package:firebase_auth/firebase_auth.dart';\n",
    "import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_pdf_helper.dart';\n",
    "import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';\n",
]

for imp in new_imports:
    if imp not in lines:
        lines.insert(0, imp)

with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "w") as f:
    f.writelines(lines)
