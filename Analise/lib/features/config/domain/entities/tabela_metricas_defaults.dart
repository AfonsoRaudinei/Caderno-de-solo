import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:uuid/uuid.dart';

/// Valores-padrão embutidos no app (seed inicial).
///
/// São carregados pelo [TabelaMetricasRepository] na PRIMEIRA execução,
/// quando não há nenhum dado salvo localmente ou na nuvem.
/// A partir daí, o usuário pode editá-los pela UI de Configurações.
///
/// Fontes:
///   - IAC Boletim 100 (2016) — Fósforo NC Resina
///   - Fancelli & Dourado Neto (2000 / ESALQ) — NC Mehlich-1
///   - Embrapa Cerrado (Sousa & Lobato, 2004) — NC Fósforo Cerrado
///   - Manual CFSEMG / UFLA (Ribeiro et al., 1999) — NC Fósforo UFLA
///   - IAC Boletim 100 (2016) — FEP e Fator Solo
///   - Fancelli (2020 / ESALQ) — NC Potássio e FEK
class TabelaMetricasDefaults {
  const TabelaMetricasDefaults._();

  static const _uuid = Uuid();
  static final _now = DateTime(2026, 1, 1); // data de seed fixa

  // ── Chaves canônicas ──────────────────────────────────────────────────────

  static const kFosforoNcResina = 'fosforo_nc_resina';
  static const kFosforoNcMehlich = 'fosforo_nc_mehlich';
  static const kFosforoFep = 'fosforo_fep';
  static const kFosforoFatorSolo = 'fosforo_fator_solo';
  static const kFosforoNcCerrado = 'fosforo_nc_cerrado';
  static const String kFosforoNcRsSc = 'fosforo_nc_rssc';
  static const String kFosforoNcUfla = 'fosforo_nc_ufla';
  static const String kPotassioNcTeor = 'potassio_nc_teor';
  static const String kPotassioFek = 'potassio_fek';
  static const String kPotassioAntagonismos = 'potassio_antagonismos';
  static const String kCalagemMetasAlbrecht = 'calagem_metas_albrecht';
  static const String kCalagemSmp = 'calagem_smp';
  static const String kCalagemMetasV = 'calagem_metas_v';

  // ── Tabelas ───────────────────────────────────────────────────────────────

  static List<TabelaMetricas> build() => [
        // ── Fósforo: NC Resina IAC ──────────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoNcResina,
          nome: 'NC Fósforo — Resina (IAC Bol.100)',
          descricao: 'Nível Crítico de P extraído por Resina de Troca Iônica. '
              'Fonte: IAC Boletim 100 (Raij et al., 2016).',
          unidade: 'mg/dm³',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 15% argila (arenoso)',
              'argilaMin': 0,
              'argilaMax': 15,
              'valor': 12.0
            },
            {
              'faixa': '15–35% (médio)',
              'argilaMin': 15,
              'argilaMax': 35,
              'valor': 20.0
            },
            {
              'faixa': '35–60% (argiloso)',
              'argilaMin': 35,
              'argilaMax': 60,
              'valor': 30.0
            },
            {
              'faixa': '> 60% (muito argiloso)',
              'argilaMin': 60,
              'argilaMax': 999,
              'valor': 40.0
            },
          ],
        ),

        // ── Fósforo: NC Mehlich-1 ───────────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoNcMehlich,
          nome: 'NC Fósforo — Mehlich-1',
          descricao: 'Nível Crítico de P extraído por Mehlich-1. '
              'Fonte: Fancelli & Dourado Neto (ESALQ/USP).',
          unidade: 'mg/dm³',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 15% (arenoso)',
              'argilaMin': 0,
              'argilaMax': 15,
              'valor': 8.0
            },
            {
              'faixa': '15–35% (médio)',
              'argilaMin': 15,
              'argilaMax': 35,
              'valor': 12.0
            },
            {
              'faixa': '35–60% (argiloso)',
              'argilaMin': 35,
              'argilaMax': 60,
              'valor': 18.0
            },
            {
              'faixa': '> 60% (muito argiloso)',
              'argilaMin': 60,
              'argilaMax': 999,
              'valor': 25.0
            },
          ],
        ),

        // ── Fósforo: FEP (Fator de Eficiência de Parcelamento) ─────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoFep,
          nome: 'FEP — Fator de Eficiência do Fósforo',
          descricao: 'Fator de eficiência de P (%) por textura. '
              'Fonte: IAC Boletim 100 (Raij et al., 2016).',
          unidade: '%',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 15% (arenoso)',
              'argilaMin': 0,
              'argilaMax': 15,
              'valor': 30.0
            },
            {
              'faixa': '15–35% (médio)',
              'argilaMin': 15,
              'argilaMax': 35,
              'valor': 20.0
            },
            {
              'faixa': '35–60% (argiloso)',
              'argilaMin': 35,
              'argilaMax': 60,
              'valor': 15.0
            },
            {
              'faixa': '> 60% (muito argiloso)',
              'argilaMin': 60,
              'argilaMax': 999,
              'valor': 10.0
            },
          ],
        ),

        // ── Fósforo: Fator Solo ─────────────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoFatorSolo,
          nome: 'Fator Solo — Fósforo',
          descricao: 'Fator de capacidade tampão do solo para P, por textura. '
              'Fonte: IAC Boletim 100 (Raij et al., 2016).',
          unidade: 'adimensional',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 15% (arenoso)',
              'argilaMin': 0,
              'argilaMax': 15,
              'valor': 2.0
            },
            {
              'faixa': '15–35% (médio)',
              'argilaMin': 15,
              'argilaMax': 35,
              'valor': 3.0
            },
            {
              'faixa': '35–60% (argiloso)',
              'argilaMin': 35,
              'argilaMax': 60,
              'valor': 4.0
            },
            {
              'faixa': '> 60% (muito argiloso)',
              'argilaMin': 60,
              'argilaMax': 999,
              'valor': 5.0
            },
          ],
        ),

        // ── Fósforo: NC Embrapa Cerrado ────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoNcCerrado,
          nome: 'NC Fósforo — Embrapa Cerrado',
          descricao: 'Nível Crítico de P para solos do Cerrado. '
              'Fonte: Sousa & Lobato, 2004 (Embrapa Cerrados).',
          unidade: 'mg/dm³',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 10% argila',
              'argilaMin': 0,
              'argilaMax': 10,
              'valor': 15.0
            },
            {
              'faixa': '10–20%',
              'argilaMin': 10,
              'argilaMax': 20,
              'valor': 15.0
            },
            {'faixa': '21–40%', 'argilaMin': 20, 'argilaMax': 40, 'valor': 8.0},
            {'faixa': '41–60%', 'argilaMin': 40, 'argilaMax': 60, 'valor': 4.0},
            {'faixa': '> 60%', 'argilaMin': 60, 'argilaMax': 999, 'valor': 3.0},
          ],
        ),

        // ── Fósforo: NC Embrapa RS/SC ──────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoNcRsSc,
          nome: 'NC Fósforo — Embrapa RS/SC',
          descricao: 'Nível Crítico de P para solos do Sul do Brasil. '
              'Fonte: SBCS/CQFS RS/SC (2016).',
          unidade: 'mg/dm³',
          updatedAt: _now,
          linhas: [
            {'faixa': '< 10%', 'argilaMin': 0, 'argilaMax': 10, 'valor': 21.0},
            {
              'faixa': '10–20%',
              'argilaMin': 10,
              'argilaMax': 20,
              'valor': 18.0
            },
            {
              'faixa': '21–40%',
              'argilaMin': 20,
              'argilaMax': 40,
              'valor': 12.0
            },
            {'faixa': '41–60%', 'argilaMin': 40, 'argilaMax': 60, 'valor': 9.0},
            {'faixa': '> 60%', 'argilaMin': 60, 'argilaMax': 999, 'valor': 6.0},
          ],
        ),

        // ── Fósforo: NC UFLA/CFSEMG ───────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kFosforoNcUfla,
          nome: 'NC Fósforo — UFLA / CFSEMG',
          descricao: 'Nível Crítico de P para Minas Gerais. '
              'Fonte: Ribeiro et al., 1999 (UFLA/CFSEMG).',
          unidade: 'mg/dm³',
          updatedAt: _now,
          linhas: [
            {'faixa': '< 10%', 'argilaMin': 0, 'argilaMax': 10, 'valor': 20.0},
            {
              'faixa': '10–20%',
              'argilaMin': 10,
              'argilaMax': 20,
              'valor': 16.0
            },
            {
              'faixa': '21–40%',
              'argilaMin': 20,
              'argilaMax': 40,
              'valor': 10.0
            },
            {'faixa': '41–60%', 'argilaMin': 40, 'argilaMax': 60, 'valor': 6.0},
            {'faixa': '> 60%', 'argilaMin': 60, 'argilaMax': 999, 'valor': 4.0},
          ],
        ),

        // ── Potássio: NC Teor Absoluto ─────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kPotassioNcTeor,
          nome: 'NC Potássio — Teor Absoluto',
          descricao:
              'Nível Crítico de K por teor absoluto (mg/dm³), por textura. '
              'Fonte: IAC Boletim 100 / Fancelli (ESALQ, 2020).',
          unidade: 'mg/dm³',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 15% (arenoso)',
              'argilaMin': 0,
              'argilaMax': 15,
              'valor': 40.0
            },
            {
              'faixa': '15–35% (médio)',
              'argilaMin': 15,
              'argilaMax': 35,
              'valor': 60.0
            },
            {
              'faixa': '35–60% (argiloso)',
              'argilaMin': 35,
              'argilaMax': 60,
              'valor': 80.0
            },
            {
              'faixa': '> 60% (muito argiloso)',
              'argilaMin': 60,
              'argilaMax': 999,
              'valor': 100.0
            },
          ],
        ),

        // ── Potássio: FEK Base ─────────────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kPotassioFek,
          nome: 'FEK — Fator de Eficiência do Potássio',
          descricao: 'Fator de eficiência de K (%) por textura. '
              'Fonte: Fancelli (ESALQ, 2020).',
          unidade: '%',
          updatedAt: _now,
          linhas: [
            {
              'faixa': '< 15% (arenoso)',
              'argilaMin': 0,
              'argilaMax': 15,
              'valor': 50.0
            },
            {
              'faixa': '15–35% (médio)',
              'argilaMin': 15,
              'argilaMax': 35,
              'valor': 60.0
            },
            {
              'faixa': '35–60% (argiloso)',
              'argilaMin': 35,
              'argilaMax': 60,
              'valor': 65.0
            },
            {
              'faixa': '> 60% (muito argiloso)',
              'argilaMin': 60,
              'argilaMax': 999,
              'valor': 70.0
            },
          ],
        ),

        // ── Potássio: Limites de Antagonismo ──────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kPotassioAntagonismos,
          nome: 'Limites de Antagonismo — Potássio',
          descricao: 'Limites de K% na CTC, relação K:Mg e K:Ca para '
              'geração de avisos técnicos de antagonismo. '
              'Fonte: Fancelli (ESALQ, 2020) / Comissão de Fertilidade RS.',
          unidade: 'múltiplas',
          updatedAt: _now,
          linhas: [
            {
              'faixa': 'K% na CTC (alerta acima de)',
              'argilaMin': 0,
              'argilaMax': 999,
              'chaveValor': 'limite_k_ctc',
              'valor': 7.0
            },
            {
              'faixa': 'Relação K:Mg (alerta acima de)',
              'argilaMin': 0,
              'argilaMax': 999,
              'chaveValor': 'limite_k_mg',
              'valor': 1.0
            },
            {
              'faixa': 'Relação K:Ca (alerta acima de)',
              'argilaMin': 0,
              'argilaMax': 999,
              'chaveValor': 'limite_k_ca',
              'valor': 0.4
            },
          ],
        ),

        // ── Calagem: Metas Albrecht ──────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kCalagemMetasAlbrecht,
          nome: 'Metas Albrecht — Calagem',
          descricao: 'Participação ideal de bases na CTC segundo Albrecht. '
              'Valores padrão para a maioria das culturas.',
          unidade: '% na CTC',
          updatedAt: _now,
          linhas: [
            {
              'faixa': 'Cálcio (Ca%)',
              'argilaMin': 0,
              'argilaMax': 999,
              'chaveValor': 'pct_ca',
              'valor': 65.0
            },
            {
              'faixa': 'Magnésio (Mg%)',
              'argilaMin': 0,
              'argilaMax': 999,
              'chaveValor': 'pct_mg',
              'valor': 15.0
            },
            {
              'faixa': 'Potássio (K%)',
              'argilaMin': 0,
              'argilaMax': 999,
              'chaveValor': 'pct_k',
              'valor': 4.0
            },
          ],
        ),

        // ── Calagem: Tabela SMP ──────────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kCalagemSmp,
          nome: 'Tabela SMP — Calagem',
          descricao: 'Necessidade de Calagem (t/ha) baseada no pH SMP. '
              'Fonte: SBCS/CQFS RS/SC.',
          unidade: 't/ha',
          updatedAt: _now,
          linhas: [
            {
              'faixa': 'pH SMP <= 4.5',
              'phMin': 0.0,
              'phMax': 4.5,
              'valor': 15.0
            },
            {
              'faixa': 'pH SMP 4.6–5.0',
              'phMin': 4.5,
              'phMax': 5.0,
              'valor': 10.0
            },
            {
              'faixa': 'pH SMP 5.1–5.5',
              'phMin': 5.0,
              'phMax': 5.5,
              'valor': 5.0
            },
            {
              'faixa': 'pH SMP 5.6–6.0',
              'phMin': 5.5,
              'phMax': 6.0,
              'valor': 2.5
            },
            {'faixa': 'pH SMP > 6.0', 'phMin': 6.0, 'phMax': 9.9, 'valor': 0.0},
          ],
        ),

        // ── Calagem: Metas V% ──────────────────────────────────────────
        TabelaMetricas(
          id: _uuid.v4(),
          chave: kCalagemMetasV,
          nome: 'Metas V% — Saturação por Bases',
          descricao: 'Saturação por Bases alvo (V2) por grupo de cultura.',
          unidade: '%',
          updatedAt: _now,
          linhas: [
            {
              'faixa': 'Grupo 1 (Exigentes: Soja, Milho, Algodão)',
              'chaveValor': 'v_alvo_g1',
              'valor': 70.0
            },
            {
              'faixa': 'Grupo 2 (Médios: Trigo, Feijão)',
              'chaveValor': 'v_alvo_g2',
              'valor': 60.0
            },
            {
              'faixa': 'Grupo 3 (Rústicos: Pastagem)',
              'chaveValor': 'v_alvo_g3',
              'valor': 50.0
            },
          ],
        ),
      ];
}
