import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateSendButton);
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateSendButton);
    _messageController.dispose();
    super.dispose();
  }

  void _updateSendButton() {
    final canSend =
        _messageController.text.trim().isNotEmpty && !widget.isLoading;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _sendMessage() {
    if (_canSend) {
      final message = _messageController.text.trim();
      _messageController.clear();
      widget.onSendMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !widget.isLoading,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color:
                    _canSend ? const Color(0xFF176FF1) : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _canSend ? _sendMessage : null,
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _canSend ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _canSend ? Colors.white : Colors.grey.shade600,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
