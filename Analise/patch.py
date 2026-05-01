import re

from pathlib import Path

with open('lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

imports = """\nimport 'package:soloforte/core/widgets/nivel_gradiente_bar.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/formulas/micronutrientes_engine.dart';'''
if "nivel_gradiente_bar.dart" not in c:
    c = c.replace("import 'package:soloforte/core/theme/app_colors.dart';", "import 'package:soloforte/core/theme/app_colors.dart';" + mimports)

blocks = """_buildIdentificacao(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildQualidadeSolo(resultado.analise),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildCalcario(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildGesso(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildComparativoVPercent(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildFosforo(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildPotassio(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildMicros(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildOQueComprar(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildMicrosSolo(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildMicrosFoliar(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildAvisos(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),
    _buildArgumentos(resultado),
    const Divider(height: 32, thickness: 0.5, color: AppColors.borderSoft),'''

c = re.sub(r'_buildIdentificacao\(resultado\),.*?_buildArgumentos\(resultado\),', blocks, c, flags=re.SINGLELINE)

with open('lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("ok")