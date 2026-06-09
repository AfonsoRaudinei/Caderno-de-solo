with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "r") as f:
    text = f.read()

import re
text = re.sub(r"import 'package:soloforte/core/services/app_observability.dart';\n", "", text)
text = re.sub(r"import 'package:soloforte/features/auth/application/providers/auth_usecase_providers.dart';\n", "", text)
text = re.sub(r"import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';\n", "", text)
text = re.sub(r"import 'package:soloforte/features/laboratorio/services/laudo_pdf_generator.dart';\n", "", text)

with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "w") as f:
    f.write(text)
