import 'package:flutter/material.dart';

class TestCharactersScreen extends StatefulWidget {
  const TestCharactersScreen({super.key});

  @override
  State<TestCharactersScreen> createState() => _TestCharactersScreenState();
}

class _TestCharactersScreenState extends State<TestCharactersScreen> {
  final TextEditingController _controller = TextEditingController();
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _displayText = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Teste de Caracteres Especiais'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite texto com caracteres especiais:',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Ex: São Paulo, Atenção, José',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.text,
              autocorrect: true,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            const Text(
              'Texto digitado:',
              style: TextStyle(color: Colors.pinkAccent, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _displayText.isEmpty ? 'Nenhum texto digitado' : _displayText,
                style: TextStyle(
                  color: _displayText.isEmpty ? Colors.grey : Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Informações do Sistema:',
              style: TextStyle(color: Colors.pinkAccent, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Locale: ${Localizations.localeOf(context)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Platform: ${Theme.of(context).platform}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Keyboard Type: TextInputType.text',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
