import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/report_provider.dart';
import 'providers/user_provider.dart';
import 'models/report_model.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  @override
  void initState() {
    super.initState();

    // Ejecutar después de que el primer frame haya sido renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final reportsProvider = Provider.of<ReportsProvider>(
        context,
        listen: false,
      );

      reportsProvider.loadReports(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Reports")),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reports.isEmpty) {
            return const Center(child: Text("No reports found"));
          }

          return ListView.builder(
            itemCount: provider.reports.length,
            itemBuilder: (_, index) {
              final ReportModel report = provider.reports[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text(report.title),
                  subtitle: Text("Created: ${report.createdAt}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final reportsProvider = Provider.of<ReportsProvider>(
                        context,
                        listen: false,
                      );

                      try {
                        await reportsProvider.downloadReport(report.reportFile);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Download started for ${report.reportFile}'),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Error downloading report: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
