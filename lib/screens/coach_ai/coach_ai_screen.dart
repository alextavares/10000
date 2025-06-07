import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';

// Modelo para mensagem de chat
class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}

class CoachAiScreen extends StatefulWidget {
  const CoachAiScreen({super.key});

  @override
  State<CoachAiScreen> createState() => _CoachAiScreenState();
}

class _CoachAiScreenState extends State<CoachAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Adicionar algumas mensagens de exemplo para visualização
    _messages.addAll([
      ChatMessage(text: 'Olá! Como posso te ajudar a alcançar seus objetivos hoje?', isUserMessage: false, timestamp: DateTime.now().subtract(const Duration(minutes: 2))),
      ChatMessage(text: 'Eu gostaria de algumas dicas para manter o foco.', isUserMessage: true, timestamp: DateTime.now().subtract(const Duration(minutes: 1))),
      ChatMessage(text: 'Claro! Uma técnica eficaz é a Pomodoro. Que tal começarmos por aí?', isUserMessage: false, timestamp: DateTime.now()),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUserMessage: true, timestamp: DateTime.now()));
      // Simular resposta da IA (será substituído pela lógica real do Genkit)
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.insert(0, ChatMessage(text: 'Entendido! Processando sua mensagem: "$text"', isUserMessage: false, timestamp: DateTime.now()));
          _scrollToBottom();
        });
      });
    });

    _messageController.clear();
    _scrollToBottom();
    // Lógica para enviar mensagem para o Genkit e receber resposta virá aqui
  }

  void _scrollToBottom() {
    // Adiciona um pequeno delay para garantir que o ListView foi atualizado antes de rolar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // O topo, pois a lista está invertida (reverse: true)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: AppTheme.aiBackgroundColor,
              padding: const EdgeInsets.all(8.0),
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Envie uma mensagem para começar a conversar com seu Coach AI.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.subtitleColor),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true, // Mostra as mensagens mais recentes em baixo
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        // _buildMessageBubble será implementado na Subtarefa 12.3
                        // Por enquanto, um Text simples:
                        return Align(
                          alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                            decoration: BoxDecoration(
                              color: message.isUserMessage ? AppTheme.primaryColor : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUserMessage ? Colors.white : AppTheme.textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Divider(height: 1, color: AppTheme.dividerColor),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: AppTheme.surfaceColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              onSubmitted: (value) => _sendMessage(),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.send, color: AppTheme.primaryColor),
            onPressed: _sendMessage,
            tooltip: 'Enviar mensagem',
          ),
        ],
      ),
    );
  }
}
