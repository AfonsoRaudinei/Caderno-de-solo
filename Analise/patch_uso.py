import re

with open('lib/domain/usecases/calcular_recomendacao_completa_usecase.dart', 'r', encoding='utf8') as f:
    data = f.read()

# Remove _validarNaoCritico from top
data = re.sub(r'_validarNaoCritico\([^;]+;\s*', '', data)

# Rewrite _validarNaoCritico so it doesn't add to avisos, or just drop it.

with open('lib/domain/usecases/calcular_recomendacao_completa_usecase.dart', 'w', encoding='utf8') as f:
    f.write(data)
