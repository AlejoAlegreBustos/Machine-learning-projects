import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/login_provider.dart';
import 'providers/report_provider.dart';
import 'profile.dart';
import 'form.dart';
import 'myreports.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Accedemos al usuario logueado desde LoginProvider
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.name ?? 'User'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Botón Profile
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: const Text('Profile'),
            ),
            const SizedBox(height: 20),

            // Botón New Report
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SecondPage(userId: user?.id ?? ''),
                  ),
                );
              },
              child: const Text('New report'),
            ),

            const SizedBox(height: 20),

            // Botón My Reports
            // HomePage.dart
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ReportsProvider(),
                      child: const MyReportsPage(), // no necesita userId
                    ),
                  ),
                );
              },
              child: const Text('My reports'),
            ),
          ],
        ),
      ),
    );
  }
}
