import re

# 1. Fix NivelGradienteBar
with open("Analise/lib/core/widgets/nivel_gradiente_bar.dart", "r") as f:
    text = f.read()
text = text.replace("import 'package:soloforte/core/theme/app_colors.dart';\n", "")
with open("Analise/lib/core/widgets/nivel_gradiente_bar.dart", "w") as f:
    f.write(text)

# 2. Fix classificacao_nivel
with open("Analise/lib/domain/formulas/classificacao_nivel.dart", "r") as f:
    text = f.read()
text = text.replace("if (argila > 60) nc = 4.0;", "if (argila > 60) { nc = 4.0; }")
text = text.replace("else if (argila < 15) nc = 15.0;", "else if (argila < 15) { nc = 15.0; }")
with open("Analise/lib/domain/formulas/classificacao_nivel.dart", "w") as f:
    f.write(text)

