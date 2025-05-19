import 'package:flutter/material.dart';
import '../services/genkit_service.dart';

class GenkitTestScreen extends StatefulWidget {
  const GenkitTestScreen({super.key});

  @override
  State<GenkitTestScreen> createState() => _GenkitTestScreenState();
}

class _GenkitTestScreenState extends State<GenkitTestScreen> {
  // Choose the appropriate URL based on platform
  // For web testing: 'http://localhost:3000'
  // For Android emulator: 'http://10.0.2.2:3000'
  // For iOS simulator: 'http://localhost:3000'
  // For physical devices: Use the actual IP address of your computer on the network
  // 
  // Try different URLs if you're having connection issues:
  // - 'http://10.0.2.2:3000' (Android emulator default)
  // - 'http://localhost:3000' (Web/iOS)
  // - 'http://127.0.0.1:3000' (Alternative localhost)
  final GenkitService _genkitService = GenkitService(baseUrl: 'http://10.0.2.2:3000');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _onboardingAnswerController = TextEditingController();
  
  String _helloResult = '';
  Map<String, dynamic> _onboardingResult = {};
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _onboardingAnswerController.dispose();
    super.dispose();
  }

  Future<void> _testHelloFlow() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _genkitService.testHelloFlow(_nameController.text);
      setState(() {
        _helloResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _testOnboardingFlow() async {
    if (_onboardingAnswerController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an answer';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _genkitService.processOnboardingAnswer(_onboardingAnswerController.text);
      setState(() {
        _onboardingResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genkit Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Genkit Flows',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Hello Flow Test
            const Text(
              'Hello Flow Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testHelloFlow,
              child: const Text('Test Hello Flow'),
            ),
            if (_helloResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Result: $_helloResult',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Onboarding Flow Test
            const Text(
              'Onboarding Flow Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _onboardingAnswerController,
              decoration: const InputDecoration(
                labelText: 'Enter your answer to an onboarding question',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testOnboardingFlow,
              child: const Text('Test Onboarding Flow'),
            ),
            if (_onboardingResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Question: ${_onboardingResult['nextQuestion'] ?? 'None'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Onboarding Complete: ${_onboardingResult['onboardingComplete'] ?? false}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Extracted Data:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _onboardingResult['extractedData'] != null
                            ? _onboardingResult['extractedData'].toString()
                            : 'None',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  'Error: $_errorMessage',
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
