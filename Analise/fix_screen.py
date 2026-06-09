with open("lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart", "r") as f:
    text = f.read()

# Add imports at top
imports = """import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recomendacao_pdf_helper.dart';
import 'package:uuid/uuid.dart';
"""
if "import 'recomendacao_pdf_helper.dart';" not in text:
    text = text.replace("import 'package:uuid/uuid.dart';", imports)

# Replace actions card
actions_old = """            AppCardSection(
              title: 'Ações',
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      key: const Key('btn_salvar_recomendacao'),
                      label: 'Salvar Recomendação',
                      icon: Icons.save_alt_rounded,
                      isLoading: _salvando,
                      onPressed: (_salvando || _exportando)
                        with open("lib/features/labo      text = f.read()

# Add imports at top
imports = """import 'package:soloforte/domain/models/rec  
# Add imports at (wiimports = """import  import 'package:firebase_auth/firebase_auth.dart';
import 'recomendacao_pdf_h  import 'recomendacao_pdf_helper.dart';
import 'pa  import 'package:uuid/uuid.dart';
"""
er"""
if "import 'recomendacao_pd  if      text = text.replace("import 'package:uuid/uuid.dart  
# Replace actions card
actions_old = """            AppCardSection   actions_old = """                    title: 'Ações',
           lt              child: Row(
                      children                    Expanded,
                    child:ne                      key: const Key                        label: 'Salvar Recomendação',
                                 icon: Icons.save_alt_rounded,
                        isLoading: _salvando,
                              onPressed: (_salvand                          with open("lib/features/labo        
# Add imports at top
imports = """import 'package:soloforte/domain/mode(reimports = """import  # Add imports at (wiimports = """import  import 'package:  import 'recomendacao_pdf_h  import 'recomenda                'Salvar',
                     import 'pa  import 'package:uuid/uuid.dart';
"""
er"""
if "import  """
er"""
if "import 'recomendacao_pd  if  w6er,
if "  # Replace actions card
actions_old = """            AppCardSection   actions_old = """    )actions_old = """                 lt              child: Row(
                      children                    Expanded,
                        children       s.                    child:ne                      key: conym                                 icon: Icons.save_alt_rounded,
                        isLoading: _salvando,
         or                        isLoading: _salvando,
                                               onPressed: (_s  # Add imports at top
imports = """import 'package:soloforte/domain/mode(reimports = """import  # Add imports at dimports = """import                       import 'pa  import 'package:uuid/uuid.dart';
"""
er"""
if "import  """
er"""
if "import 'recomendacao_pd  if  w6er,
if "  # Replace actions card
actions_old = """            AppCard  """
er"""
if "import  """
er"""
if "import 'recomendacao_pd  if e:er8)if "  er"""
if "impo  if "beif "  # Replace actions card
actions_  actions_old = """          ed                      children                    Expanded,
                        children       s.                    child:nde                        children       s.                 g:                        isLoading: _salvando,
         or                        isLoading: _salvando,
                                               onPressed: (),         or                        isLoading                                                 onPresse  imports = """import 'package:soloforte/domain/mode(reimports = """import  # Add imct"""
er"""
if "import  """
er"""
if "import 'recomendacao_pd  if  w6er,
if "  # Replace actions card
actions_old = """            AppCard  """
er"""
if "import  """
er"""
if "impnderaoif "Laer"""
if "impoecomendaif "  # Replace actions card
actions_thactions_old = """          hoer"""
if "import  """
er"""
if "import ' Fif "e<er"""
if "impoesif "doif "impo  if "beif "  # Replace actions card
acttSactions_  actions_old = """          ed                              children       s.                    child:nde                        chioM         or                        isLoading: _salvando,
                                               onPressed: (),         or                        isLoading            ul                                               onPresseCaer"""
if "import  """
er"""
if "import 'recomendacao_pd  if  w6er,
if "  # Replace actions card
actions_old = """            AppCard  """
er"""
if "import  """
er"""
if "impnderaoif "Laer"""
if "impoecomendaif "  # Replace actions card
actions_thactir(if "  er"""
if "impo  if "  if "  # Replace actions card
actions_ãactions_old = """            er"""
if "import  """
er"""
if "impndera34if "),er"""
if "impnavif " SnackBarBehavior.floating,actions_thactions_old = """          hoer"ordif "import  """
er"""
if "import ' Fif "e<   er"""
if "impostif "eIif "impoesif "doif "impo dacttSactions_  actions_old = """          ed                                                                onPressed: (),         or                        isLoading            ul                                               onPresseCaer"""
if "import  """
er"""
 }if "import  """
er"""
if "import 'recomendacao_pd  if  w6er,
if "  # Replace actions card
actions_old = """            AppCard  """
er"""
if "import  """
er"""
if "impnderaoif "Laedoer"""
if "impo  if   cif "  # Replace actions card
actions_ (actions_old = """          tuer"""
if "import  """
er"""
if "impndera $if "
 er"""
if "impn
 if " iif "impoecomendaif "  # =actions_thactir(if "  er"""
if "impo  if " orif "impo  if "  if "  # Re
 actions_ãactions_old = """            er""s_if "import  """
er"""
if "impndera34if "),eb/er"""
if "impnatif "/pif entation/recomendacao/rer"""
if "import ' Fart", "w") as f:
    f.write(text)

