import 'package:flutter/material.dart';

/// Enumeração para os estágios fenológicos da soja
enum SojaStage {
  ve('VE - Emergência'),
  v1('V1 - Primeiro nó'),
  v2('V2 - Segundo nó'),
  v3('V3 - Terceiro nó'),
  vn('Vn - Enésimo nó'),
  r1('R1 - Início do florescimento'),
  r2('R2 - Florescimento pleno'),
  r3('R3 - Início do desenvolvimento de vagem'),
  r4('R4 - Vagem plena'),
  r5('R5 - Início do enchimento de grãos'),
  r6('R6 - Grão cheio'),
  r7('R7 - Início da maturação'),
  r8('R8 - Maturação plena');

  final String label;
  const SojaStage(this.label);
}

class CropPhenologyTracker extends StatefulWidget {
  const CropPhenologyTracker({super.key});

  @override
  State<CropPhenologyTracker> createState() => _CropPhenologyTrackerState();
}

class _CropPhenologyTrackerState extends State<CropPhenologyTracker> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos numéricos
  final _nBalanceController = TextEditingController();
  final _soilPHController = TextEditingController();
  
  // Estado para o estágio da soja
  SojaStage? _selectedStage;

  @override
  void dispose() {
    _nBalanceController.dispose();
    _soilPHController.dispose();
    super.dispose();
  }

  void _calcularAdubo() {
    if (_formKey.currentState!.validate()) {
      // Lógica de cálculo (exemplo simplificado)
      final nBalance = double.tryParse(_nBalanceController.text) ?? 0.0;
      final ph = double.tryParse(_soilPHController.text) ?? 0.0;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Calculando para ${_selectedStage?.label}...\n'
            'Balanço N: $nBalance, pH: $ph',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreador Fenológico'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Acompanhamento de Safra',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Dropdown para Estágio da Soja
              DropdownButtonFormField<SojaStage>(
                initialValue: _selectedStage,
                decoration: const InputDecoration(
                  labelText: 'Estágio da Soja',
                  prefixIcon: Icon(Icons.grass),
                  border: OutlineInputBorder(),
                ),
                items: SojaStage.values.map((SojaStage stage) {
                  return DropdownMenuItem<SojaStage>(
                    value: stage,
                    child: Text(stage.label),
                  );
                }).toList(),
                onChanged: (SojaStage? newValue) {
                  setState(() {
                    _selectedStage = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione um estágio' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo para Balanço de Nitrogênio (N)
              TextFormField(
                controller: _nBalanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Balanço de Nitrogênio (N_balance)',
                  prefixIcon: Icon(Icons.science),
                  suffixText: 'kg/ha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o balanço de N';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Insira um valor numérico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo para pH do Solo
              TextFormField(
                controller: _soilPHController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'pH do Solo (soilPH)',
                  prefixIcon: Icon(Icons.water_drop),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o pH do solo';
                  }
                  final ph = double.tryParse(value);
                  if (ph == null) {
                    return 'Insira um valor numérico válido';
                  }
                  if (ph < 0 || ph > 14) {
                    return 'O pH deve estar entre 0 e 14';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Botão Calcular Adubo
              FilledButton.icon(
                onPressed: _calcularAdubo,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.calculate),
                label: const Text(
                  'Calcular Adubo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
