import 'package:flutter/material.dart';
import 'package:recalie/features/ai/ai_coach_api.dart';

class AiCoachPanel extends StatefulWidget {
  const AiCoachPanel({super.key});

  @override
  State<AiCoachPanel> createState() => _AiCoachPanelState();
}

class _AiCoachPanelState extends State<AiCoachPanel>
    with AutomaticKeepAliveClientMixin {
  static const _suggestions = [
    'Help me create active-recall questions.',
    'How should I review a difficult memory set?',
    'Explain spaced repetition simply.',
  ];

  AiCoachApi? _api;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<AiCoachMessage> _messages = [];
  bool _loading = false;
  bool _cancelled = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _api?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;
    AiCoachApi api;
    try {
      api = _api ??= AiCoachApi();
    } on AiCoachException catch (error) {
      setState(() => _error = error.message);
      return;
    }
    final history = List<AiCoachMessage>.from(_messages);
    _controller.clear();
    setState(() {
      _messages.add(AiCoachMessage(role: 'user', content: text));
      _loading = true;
      _cancelled = false;
      _error = null;
    });
    _scrollToBottom();
    try {
      final reply = await api.send(message: text, history: history);
      if (!mounted || _cancelled) return;
      setState(() {
        _messages.add(AiCoachMessage(role: 'assistant', content: reply));
      });
    } on AiCoachException catch (error) {
      if (!mounted || _cancelled) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted && !_cancelled) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _stop() {
    _cancelled = true;
    _api?.cancel();
    setState(() => _loading = false);
  }

  void _newChat() {
    _api?.cancel();
    setState(() {
      _messages.clear();
      _loading = false;
      _cancelled = false;
      _error = null;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = Theme.of(context).colorScheme;
    final availableHeight = MediaQuery.sizeOf(context).height - 236;
    return SizedBox(
      height: availableHeight.clamp(430.0, 720.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.filledTonal(
              tooltip: 'New chat',
              onPressed: _messages.isEmpty ? null : _newChat,
              icon: const Icon(Icons.add_comment_rounded),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyCoach(suggestions: _suggestions, onSelected: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(2, 10, 2, 18),
                    itemCount:
                        _messages.length +
                        (_loading ? 1 : 0) +
                        (_error == null ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return _MessageBubble(message: _messages[index]);
                      }
                      if (_loading && index == _messages.length) {
                        return const _ThinkingBubble();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.error),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_loading,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ask AI Coach',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton.filled(
                  tooltip: _loading ? 'Stop' : 'Send',
                  onPressed: _loading ? _stop : _send,
                  icon: Icon(
                    _loading ? Icons.stop_rounded : Icons.arrow_upward_rounded,
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

class _EmptyCoach extends StatelessWidget {
  const _EmptyCoach({required this.suggestions, required this.onSelected});

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI Coach',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask for help with active recall, memory sets, and study plans.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            for (final suggestion in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActionChip(
                  label: Text(suggestion, textAlign: TextAlign.center),
                  onPressed: () => onSelected(suggestion),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiCoachMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? colors.primary : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(5) : null,
            bottomLeft: isUser ? null : const Radius.circular(5),
          ),
        ),
        child: SelectableText(
          message.content,
          style: TextStyle(
            color: isUser ? colors.onPrimary : colors.onSurface,
            height: 1.42,
          ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}
