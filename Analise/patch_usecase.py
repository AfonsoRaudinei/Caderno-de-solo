import re

path_usecase = 'lib/domain/usecases/calcular_recomendacao_completa_usecase.dart'
with open(path_usecase, 'r', encoding='utf-8') as f:
    text = f.read()

# Remove the top level _validarNaoCritico calls
text = re.sub(r'(\s*)_validarNaoCritico.*?;\n', '', text)

# Find where `final recomendacao = base.copyWith(` happens and replace there
# Or better, just rewrite `_calcularMicrosExtras` and `_validarNaoCritico`

# For _calcularMicrosExtras
extras_replacement = r'''    ({List<MicroResultado> micros, List<String> avisos}) _calcularMicrosExtras({
      required AnaliseCompleta analise,
      required CalibracaoProfile calibracao,
      required Map<String, StatusNutriente> status,
    }) {
      final microsCard = calibracao.parametrosCards['micros'];
      if (microsCard is! Map) {
        return (micros: const <MicroResultado>[], avisos: const <String>[]);
      }
      final elementosRaw = microsCard['elementos'];
      if (elementosRaw is! Map) {
        return (micros: const <MicroResultado>[], avisos: const <String>[]);
      }

      final extras = <MicroResultado>[];
      final avisosLocais = <String>[];
      
      for (final simbolo in const <String>['Ni', 'Mo', 'Se']) {
        final cfgRaw = elementosRaw[simbolo];
        if (cfgRaw is! Map) continue;
        final cfg = Map<String, dynamic>.from(
          cfgRaw.map((key, value) => MapEntry(key.toString(), value)),
        );

        final valorAtual = _microValor(analise, simbolo);
        status[simbolo] = _statusDoValor(valorAtual);

        final via = _string(cfg['viaAplicacao'], 'Solo (correção)');
        final nc = _numNullable(cfg['ncSolo']);
        
        final avisosDoNutriente = <String>[];
        
        if (!valorAtual.isValido) {
          avisosDoNutriente.add('Micronutriente $simbolo sem teor na análise.');
          extras.add(MicroResultado(
            elemento: simbolo,
            valorAtual: 0,
            nc: nc ?? 0,
            dose: 0,
            unidade: 'g/ha',
            deficiente: false,
            via: via,
            fonte: '-',
            doseProduto: 0,
            doseProdutoLabel: 'Não analisado',
            avisosNutriente: avisosDoNutriente,
          ));
          continue;
        }
        if (nc == null) {
          avisosDoNutriente.add('Micronutriente $simbolo sem referência de NC.');
          extras.add(MicroResultado(
            elemento: simbolo,
            valorAtual: valorAtual.valor!,
            nc: 0,
            dose: 0,
            unidade: 'g/ha',
            deficiente: false,
            via: via,
            fonte: '-',
            doseProduto: 0,
            doseProdutoLabel: 'Sem ref. de NC',
            avisosNutriente: avisosDoNutriente,
          ));
          continue;
        }

        final resultado = via.contains('Solo')
            ? MicronutrientesEngine.calcularViaSolo(
                elemento: _toElemento(simbolo),
                teorSolo: valorAtual.valor!,
                percentualCorrecao: _num(cfg['percentualCorrecaoSolo'], 100),
                teorFonte: _num(cfg['teorFonteSolo'], 0),
                eficiencia: _num(cfg['eficienciaSolo'], 0),
              )
            : MicronutrientesEngine.calcularViaFoliar(
                elemento: _toElemento(simbolo),
                teorSolo: valorAtual.valor!,
                doseElemento: _num(cfg['doseElementoFoliar'], 0),
                teorFonte: _num(cfg['teorFonteFoliar'], 0),
                eficienciaFoliar: _num(cfg['eficienciaFoliar'], 0),
              );

        if (resultado.avisos.isNotEmpty) {
           avisosDoNutriente.addAll(resultado.avisos);
        }

        if (resultado.doseElemento <= 0) {
          extras.add(MicroResultado(
            elemento: simbolo,
            valorAtual: valorAtual.valor!,
            nc: nc,
            dose: 0,
            unidade: 'g/ha',
            deficiente: valorAtual.valor! < nc,
            via: via,
            fonte: '-',
            doseProduto: 0,
            doseProdutoLabel: 'Dose zero',
            avisosNutriente: avisosDoNutriente,
          ));
          continue;
        }

        final doseProdutoLabel = resultado.unidade == 'kg/ha'
            ? '${resultado.doseProduto.toStringAsFixed(2)} kg/ha produto'
            : '${resultado.doseProduto.toStringAsFixed(1)} g/ha produto';

        extras.add(
          MicroResultado(
            elemento: simbolo,
            valorAtual: valorAtual.valor!,
            nc: nc,
            dose: resultado.doseElemento,
            unidade: 'g/ha',
            deficiente: valorAtual.valor! < nc,
            via: via,
            fonte: via.contains('Solo')
                ? _string(cfg['fonteSolo'], 'Fonte solo')
                : _string(cfg['fonteFoliar'], 'Fonte foliar'),
            doseProduto: resultado.doseProduto,
            doseProdutoLabel: doseProdutoLabel,
            referencia: resultado.avisos.isEmpty ? null : resultado.avisos.join(' '),
            avisosNutriente: avisosDoNutriente,
          ),
        );
      }

      return (micros: extras, avisos: avisosLocais);
    }'''

text = re.sub(r'    \(\{List<MicroResultado> micros, List<String> avisos\}\) _calcularMicrosExtras.*?return \(micros: extras, avisos: avisos\);\n    \}', extras_replacement, text, flags=re.DOTALL)


# Now we also need to append missing base micros that were skipped. We can do it right before `return RecomendacaoResult(`
append_base = r'''
    final todosMicrosBase = <MicroResultado>[...base.micros];
    final calibracaoMicros = calibracao.parametrosCards['micros']?['elementos'] as Map?;
    if (calibracaoMicros != null) {
      for (final s in ['B', 'Cu', 'Fe', 'Mn', 'Zn']) {
        final cfg = calibracaoMicros[s];
        if (cfg is! Map) continue;
        
        final valNullable = _valorNutrienteByName(analise, s);
        if (!valNullable.analisado) {
          final jaExiste = todosMicrosBase.any((m) => m.elemento == s);
          if (!jaExiste) {
             final via = _string(cfg['viaAplicacao'], 'Solo');
             todosMicrosBase.add(MicroResultado(
               elemento: s,
               valorAtual: 0,
               nc: _numNullable(cfg['ncSolo']) ?? 0,
               dose: 0,
               unidade: 'g/ha',
               deficiente: false,
               via: via,
               fonte: '-',
               doseProduto: 0,
               doseProdutoLabel: 'Não analisado',
               avisosNutriente: ['$s não analisado — dose não calculada.'],
             ));
          } else {
             // Atualiza o existente que foi gerado com avisos
             final i = todosMicrosBase.indexWhere((m) => m.elemento == s);
             todosMicrosBase[i] = todosMicrosBase[i].copyWith(
                avisosNutriente: [...todosMicrosBase[i].avisosNutriente, '$s não analisado — dose não calculada.'],
                doseProdutoLabel: 'Não analisado',
             );
          }
        }
      }
    }

    final citacoes = <String, String>{
'''

text = text.replace('    final citacoes = <String, String>{', append_base)

# Insert the helper method `_valorNutrienteByName`
helper = r'''  ValorNutriente _valorNutrienteByName(AnaliseCompleta analise, String nome) {
    return switch(nome) {
      'B' => analise.b,
      'Cu' => analise.cu,
      'Fe' => analise.fe,
      'Mn' => analise.mn,
      'Zn' => analise.zn,
      _ => const ValorNutriente(valor: null, analisado: false)
    };
  }

  ValorNutriente _preferirS(AnaliseCompleta analise) {'''

text = text.replace('  ValorNutriente _preferirS(AnaliseCompleta analise) {', helper)

# Update the `recomendacao` instantiation
text = text.replace('micros: [...base.micros, ...microsExtrasResult.micros],', 'micros: [...todosMicrosBase, ...microsExtrasResult.micros],')

with open(path_usecase, 'w', encoding='utf-8') as f:
    f.write(text)
