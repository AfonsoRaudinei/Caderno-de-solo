with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "r") as f:
    text = f.read()

text = text.replace("RecomendacaoMicrosSoloSection(resultado: resultado),", "RecomendacaoMicrosUnificadosSection(resultado: resultado),")
text = text.replace("RecomendacaoMicrosFoliarSection(resultado: resultado),", "")

with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "w") as f:
    f.write(text)
