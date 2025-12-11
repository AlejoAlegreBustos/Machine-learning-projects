import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/provider_form.dart';
import 'providers/prediction_provider.dart';
import 'models/prediction_result.dart'; // Importar el modelo para el diálogo

class SecondPage extends StatelessWidget {
  final String userId; // Recibe el userId al crear la página

  const SecondPage({super.key, required this.userId});

  // Método para mostrar el resultado de la predicción en un modal
  void _showPredictionResultDialog(
    BuildContext context, 
    PredictionResult result,
    PredictionProvider predictionProvider,
  ) {
    // Usar showDialog para un modal persistente
    showDialog(
      context: context,
      barrierDismissible: true, // Se puede cerrar haciendo tap fuera
      builder: (BuildContext dialogContext) {
        // Usamos un Consumer anidado para reaccionar al estado de guardado/carga
        return Consumer<PredictionProvider>(
          builder: (context, predProvider, child) {
            
            // Función para manejar el guardado dentro del Consumer para acceder a su estado
            void handleSaveReport() async {
              final bool success = await predProvider.saveReport(userId);
              
              // Mostrar feedback en la Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(predProvider.saveMessage!), 
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }

            // Deshabilitar el botón si ya se guardó o está cargando
            final bool isSaved = predProvider.saveMessage?.contains('succesfully') == true;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: Text('Prediction results', 
                style: TextStyle(color: result.prediction == 1 ? Colors.green : Colors.red),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Classification:', 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      result.result,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: result.prediction == 1 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text('Model confidence: ${(result.confidence * 100).toStringAsFixed(2)}%'),
                    const SizedBox(height: 15),
                    Text('¡You can download the detailed report or save this result to your history!'),
                    
                    // Muestra el mensaje de guardado/error dentro del modal
                    if (predProvider.saveMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          predProvider.saveMessage!,
                          style: TextStyle(
                            color: isSaved ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                // Botón 1: Descargar PDF
                TextButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download PDF'),
                  onPressed: predProvider.isLoading ? null : () {
                    // Lógica de descarga (el provider solo hace la llamada, la UI maneja el guardado en disco)
                    predProvider.downloadReport(result.reportFile);
                    Navigator.of(dialogContext).pop(); // Cerrar el diálogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading pdf...')),
                    );
                  },
                ),
                // Botón 2: Guardar Reporte
                ElevatedButton.icon(
                  icon: predProvider.isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(
                    predProvider.isLoading ? 'Saving...' : 'Save report',
                  ),
                  onPressed: predProvider.isLoading || isSaved
                      ? null // Deshabilitar si está cargando o si ya se guardó con éxito
                      : handleSaveReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSaved ? Colors.grey : Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Limpiar el estado de la predicción (incluyendo el resultado y el mensaje de guardado) al cerrar el diálogo
      predictionProvider.resetPredictionState();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MultiProvider para asegurarnos de que el StartupFormProvider se crea aquí.
    // PredictionProvider se obtiene del MultiProvider global definido en main.dart,
    // para no crear una instancia distinta que el diálogo no ve.
    return MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (_) => StartupFormProvider(userId: userId)),
      ],
      // Consumer2 para acceder al Provider del formulario y al de la predicción.
      child: Consumer2<StartupFormProvider, PredictionProvider>(
        builder: (context, providerForm, providerPrediction, _) {
          
          // Lógica para mostrar el diálogo si la predicción es exitosa
          if (providerPrediction.predictionResult != null && 
              providerPrediction.errorMessage == null &&
              !providerPrediction.isLoading) {
            
            // Usamos addPostFrameCallback para evitar llamar a showDialog durante el build
            WidgetsBinding.instance.addPostFrameCallback((_) {
                _showPredictionResultDialog(
                  context, 
                  providerPrediction.predictionResult!, 
                  providerPrediction,
                );
            });
          }

          // Manejo de errores de predicción
          if (providerPrediction.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${providerPrediction.errorMessage!}'),
                    backgroundColor: Colors.red,
                  ),
                );
                // No llamamos a resetPredictionState aquí porque lo hará el diálogo al cerrarse, 
                // pero sí lo hacemos en el proveedor si el error es de conexión/API.
                // En este caso, el error se limpia en el SnackBar.
            });
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Start up Form'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Form(
                  key: providerForm.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Startup info',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Startup Name
                      providerForm.buildTextField(
                        'Startup Name',
                        providerForm.startupNameController,
                        isNumber: false,
                      ),
                      const SizedBox(height: 8),

                      // Founded Year
                      providerForm.buildTextField(
                        'Founded Year',
                        providerForm.foundedYearController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),

                      // Employee Count
                      providerForm.buildTextField(
                        'Employee Count',
                        providerForm.employeeCountController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),

                      // Funding Amount (planned investment in this round)
                      providerForm.buildTextField(
                        'Funding Amount USD',
                        providerForm.fundingAmountUsdController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),

                      // Funding Date
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Funding Date',
                          border: OutlineInputBorder(),
                        ),
                        child: ListTile(
                          title: Text(
                            providerForm.fundingDate == null
                                ? 'Select date'
                                : providerForm.fundingDate!
                                      .toLocal()
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async =>
                              await providerForm.pickFundingDate(context),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Funding Round
                      providerForm.buildDropdown(
                        'Funding Round',
                        providerForm.fundingRound,
                        providerForm.fundingRounds,
                        providerForm.setFundingRound,
                      ),
                      providerForm.buildOtherField(
                        providerForm.fundingRound,
                        providerForm.otherFundingRoundController,
                        'Specify Other Funding Round',
                      ),
                      const SizedBox(height: 8),

                      // Co-investors
                      providerForm.buildTextField(
                        'Co-investors count',
                        providerForm.coInvestorsCountController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),

                      // // Lead Investor
                      // providerForm.buildDropdown(
                      //   'Lead Investor',
                      //   providerForm.leadInvestor,
                      //   providerForm.leadInvestors,
                      //   providerForm.setLeadInvestor,
                      // ),
                      // providerForm.buildOtherField(
                      //   providerForm.leadInvestor,
                      //   providerForm.otherLeadInvestorController,
                      //   'Specify Other Lead Investor',
                      // ),
                      // const SizedBox(height: 8),

                      // // Country
                      // providerForm.buildDropdown(
                      //   'Country',
                      //   providerForm.country,
                      //   providerForm.countriesList,
                      //   providerForm.setCountry,
                      // ),
                      // providerForm.buildOtherField(
                      //   providerForm.country,
                      //   providerForm.otherCountryController,
                      //   'Specify Other Country',
                      // ),
                      const SizedBox(height: 8),

                      // Region
                      providerForm.buildDropdown(
                        'Region',
                        providerForm.region,
                        providerForm.regions,
                        providerForm.setRegion,
                      ),
                      providerForm.buildOtherField(
                        providerForm.region,
                        providerForm.otherRegionController,
                        'Specify Other Region',
                      ),
                      const SizedBox(height: 8),

                      // Industry
                      providerForm.buildDropdown(
                        'Industry',
                        providerForm.industry,
                        providerForm.industries,
                        providerForm.setIndustry,
                      ),
                      providerForm.buildOtherField(
                        providerForm.industry,
                        providerForm.otherIndustryController,
                        'Specify Other Industry',
                      ),
                      const SizedBox(height: 8),

                      // Revenue & Valuation (current, before this round
                      providerForm.buildTextField(
                        'Current Annual Revenue USD',
                        providerForm.estimatedRevenueUsdController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),
                      providerForm.buildTextField(
                        'Current Valuation USD',
                        providerForm.estimatedValuationUsdController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 8),

                      // Exited
                      SizedBox(
                        width: 150,
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Exited'),
                          value: providerForm.exited,
                          onChanged: (v) => providerForm.setExited(v ?? false),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // // Tags
                      // const Text('Tags'),
                      // const SizedBox(height: 8),
                      // Wrap(
                      //   spacing: 8,
                      //   children: providerForm.tags.keys.map((key) {
                      //     return FilterChip(
                      //       label: Text(key.replaceFirst('tag_', '')),
                      //       selected: providerForm.tags[key] ?? false,
                      //       onSelected: (sel) => providerForm.setTag(key, sel),
                      //     );
                      //   }).toList(),
                      // ),
                      // const SizedBox(height: 20),

                      // Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: providerPrediction.isLoading 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.analytics),
                            onPressed: providerPrediction.isLoading
                                ? null
                                : () {
                                    if (!providerForm.validateForm()) return;

                                    final Map<String, dynamic> jsonData =
                                        providerForm.buildJsonForApi();

                                    final List<double> features =
                                        (jsonData['features'] as List<dynamic>)
                                            .cast<double>();

                                    final String userIdFromForm = providerForm.userId;
                                    final String startupName = providerForm.startupNameController.text.trim();

                                    // 3. LLAMAR AL PROVEEDOR DE PREDICCIÓN (pasando features, userId y nombre de startup)
                                    providerPrediction.fetchPrediction(
                                      features,
                                      userIdFromForm,
                                      startupName,
                                    );

                                    // Mostrar Snackbar temporal para indicar que la solicitud fue enviada
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Prediccion requested. Waiting for server answer...'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    if (kDebugMode) {
                                      debugPrint('--- JSON for API ---');
                                      debugPrint(jsonData.toString());
                                    }
                                  },
                            label: Text(providerPrediction.isLoading ? 'Processing...' : 'Predict IPO Success'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => providerForm.resetForm(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}