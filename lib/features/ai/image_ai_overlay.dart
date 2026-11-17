import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:recalie/features/ai/ai_coach_api.dart';

class ImageAiOverlay extends StatefulWidget {
  const ImageAiOverlay({
    super.key,
    required this.imageBytes,
    required this.onClose,
  });

  final Uint8List imageBytes;
  final VoidCallback onClose;

  @override
  State<ImageAiOverlay> createState() => _ImageAiOverlayState();
}

class _ImageAiOverlayState extends State<ImageAiOverlay> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  AiCoachApi? _api;
  final List<AiCoachMessage> _messages = [];

  bool _imageAttached = false;
  bool _working = false;
  String? _error;
  int _requestGeneration = 0;

  @override
  void didUpdateWidget(covariant ImageAiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.imageBytes, widget.imageBytes)) {
      _imageAttached = false;
    }
  }

  @override
  void dispose() {
    _requestGeneration++;
    _api?.close();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleImage() {
    if (widget.imageBytes.lengthInBytes > 5 * 1024 * 1024) {
      setState(() {
        _error = 'This image is larger than 5 MB and cannot be shared yet.';
      });
      return;
    }
    setState(() {
      _imageAttached = !_imageAttached;
      _error = null;
    });
  }

  Future<void> _send() async {
    if (_working) {
      _stop();
      return;
    }
    var prompt = _inputController.text.trim();
    if (prompt.isEmpty && _imageAttached) {
      prompt = 'Help me understand and memorize this image.';
    }
    if (prompt.isEmpty) return;

    final attachImage = _imageAttached;
    final imageBytes = attachImage ? widget.imageBytes : null;
    final history = List<AiCoachMessage>.from(_messages);
    final generation = ++_requestGeneration;
    setState(() {
      _working = true;
      _error = null;
      _messages.add(
        AiCoachMessage(role: 'user', content: prompt, imageBytes: imageBytes),
      );
      _inputController.clear();
      _imageAttached = false;
    });
    _scrollToEnd();

    AiCoachApi api;
    try {
      api = _api ??= AiCoachApi();
    } on AiCoachException catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _working = false;
        _error = error.message;
      });
      return;
    }

    try {
      final reply = await api.send(
        message: prompt,
        history: history,
        imageBytes: imageBytes,
        imageMimeType: imageBytes == null ? '' : _imageMimeType(imageBytes),
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _messages.add(AiCoachMessage(role: 'assistant', content: reply));
        _working = false;
      });
      _scrollToEnd();
    } catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _working = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _stop() {
    _api?.cancel();
    setState(() {
      _requestGeneration++;
      _working = false;
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _imageMimeType(Uint8List bytes) {
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF101A2C) : const Color(0xFFF3F7FF);
    final card = dark ? const Color(0xFF192640) : Colors.white;

    return Material(
      color: surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 6),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ask about this image',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close image AI',
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty && !_working
                ? _ImageAiWelcome(cardColor: card)
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _messages.length + (_working ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const _ImageAiThinking();
                      }
                      return _ImageAiMessage(
                        message: _messages[index],
                        cardColor: card,
                      );
                    },
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 54),
                    padding: const EdgeInsets.only(left: 18, right: 6),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: .15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: dark ? .2 : .08,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Ask about this image',
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 17,
                              ),
                            ),
                          ),
                        ),
                        IconButton.filled(
                          tooltip: _working ? 'Stop' : 'Send',
                          onPressed: _send,
                          icon: Icon(
                            _working
                                ? Icons.stop_rounded
                                : Icons.arrow_upward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  selected: _imageAttached,
                  label: _imageAttached
                      ? 'Current image attached'
                      : 'Attach current image',
                  child: Tooltip(
                    message: _imageAttached
                        ? 'Remove current image'
                        : 'Attach current image',
                    child: InkWell(
                      key: const Key('imageAiAttachButton'),
                      onTap: _toggleImage,
                      borderRadius: BorderRadius.circular(27),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _imageAttached ? colors.primary : card,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: colors.primary.withValues(
                              alpha: _imageAttached ? 1 : .18,
                            ),
                          ),
                        ),
                        child: Icon(
                          _imageAttached
                              ? Icons.check_rounded
                              : Icons.image_outlined,
                          color: _imageAttached
                              ? colors.onPrimary
                              : colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageAiWelcome extends StatelessWidget {
  const _ImageAiWelcome({required this.cardColor});

  final Color cardColor;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          'Attach the image, then ask for an explanation, summary, quiz, or memory aid.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
        ),
      ),
    ),
  );
}

class _ImageAiMessage extends StatelessWidget {
  const _ImageAiMessage({required this.message, required this.cardColor});

  final AiCoachMessage message;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.role == 'user';
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fromUser ? colors.primary : cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(fromUser ? 20 : 5),
            bottomRight: Radius.circular(fromUser ? 5 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.memory(
                  message.imageBytes!,
                  width: 150,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 9),
            ],
            Text(
              message.content,
              style: TextStyle(
                color: fromUser ? colors.onPrimary : null,
                fontWeight: fromUser ? FontWeight.w700 : FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageAiThinking extends StatelessWidget {
  const _ImageAiThinking();

  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    ),
  );
}
