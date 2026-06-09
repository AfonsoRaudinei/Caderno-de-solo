import re

path = 'lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart'
try:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Find the imports of old widgets
    if 'RecomendacaoMicrosSoloSection' in text:
        text = text.replace('RecomendacaoMicrosSoloSection(resultado: resultado),', 'RecomendacaoMicrosUnificadosSection(resultado: resultado),')
        text = text.replace('RecomendacaoMicrosFoliarSection(resultado: resultado),', '')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Screen Done")
except Exception as e:
    print(e)
