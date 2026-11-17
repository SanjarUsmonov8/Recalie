import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recalie/features/ai/ai_coach_api.dart';

class RecalieAiController extends ChangeNotifier {
  RecalieAiController({this._api});

  final AiCoachApi? _api;
  final inputController = TextEditingController();
  final List<AiCoachMessage> messages = [];
  final List<RecalieAiConversation> history = [];

  AiCoachApi? _activeApi;
  Uint8List? pendingImage;
  String pendingImageMimeType = '';
  bool working = false;
  String? errorMessage;
  int _requestGeneration = 0;

  bool get hasImage => pendingImage != null;

  AiCoachApi _resolveApi() => _activeApi ??= _api ?? AiCoachApi();

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      errorMessage = 'Choose an image smaller than 5 MB.';
      notifyListeners();
      return;
    }
    final lowerPath = picked.path.toLowerCase();
    pendingImageMimeType = lowerPath.endsWith('.png')
        ? 'image/png'
        : lowerPath.endsWith('.webp')
        ? 'image/webp'
        : 'image/jpeg';
    pendingImage = bytes;
    errorMessage = null;
    notifyListeners();
  }

  void removePendingImage() {
    pendingImage = null;
    pendingImageMimeType = '';
    notifyListeners();
  }

  Future<void> send([String? suggestedPrompt]) async {
    if (working) {
      stop();
      return;
    }
    var text = (suggestedPrompt ?? inputController.text).trim();
    final imageBytes = pendingImage;
    final imageMimeType = pendingImageMimeType;
    if (text.isEmpty && imageBytes == null) return;
    if (text.isEmpty) {
      text = 'Help me understand and actively recall this image.';
    }

    final recentHistory = List<AiCoachMessage>.from(messages);
    inputController.clear();
    pendingImage = null;
    pendingImageMimeType = '';
    messages.add(
      AiCoachMessage(role: 'user', content: text, imageBytes: imageBytes),
    );
    working = true;
    errorMessage = null;
    final generation = ++_requestGeneration;
    notifyListeners();

    AiCoachApi api;
    try {
      api = _resolveApi();
    } on AiCoachException catch (error) {
      if (generation != _requestGeneration) return;
      working = false;
      errorMessage = error.message;
      notifyListeners();
      return;
    }

    try {
      final reply = await api.send(
        message: text,
        history: recentHistory,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );
      if (generation != _requestGeneration) return;
      messages.add(AiCoachMessage(role: 'assistant', content: reply));
    } on AiCoachException catch (error) {
      if (generation != _requestGeneration) return;
      errorMessage = error.message;
    } finally {
      if (generation == _requestGeneration) {
        working = false;
        notifyListeners();
      }
    }
  }

  void stop() {
    _requestGeneration++;
    _activeApi?.cancel();
    working = false;
    notifyListeners();
  }

  void newChat() {
    stop();
    if (messages.isNotEmpty) {
      history.add(
        RecalieAiConversation(
          createdAt: DateTime.now(),
          messages: List<AiCoachMessage>.from(messages),
        ),
      );
    }
    messages.clear();
    errorMessage = null;
    removePendingImage();
    notifyListeners();
  }

  void openConversation(RecalieAiConversation conversation) {
    stop();
    if (messages.isNotEmpty) {
      history.add(
        RecalieAiConversation(
          createdAt: DateTime.now(),
          messages: List<AiCoachMessage>.from(messages),
        ),
      );
    }
    messages
      ..clear()
      ..addAll(conversation.messages);
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _activeApi?.close();
    inputController.dispose();
    super.dispose();
  }
}

class RecalieAiConversation {
  const RecalieAiConversation({
    required this.createdAt,
    required this.messages,
  });

  final DateTime createdAt;
  final List<AiCoachMessage> messages;

  String get preview {
    for (final message in messages) {
      if (message.role == 'user' && message.content.trim().isNotEmpty) {
        return message.content.trim();
      }
    }
    return 'Image recall conversation';
  }
}

class RecalieAiCoachPage extends StatelessWidget {
  const RecalieAiCoachPage({
    required this.controller,
    required this.onBack,
    required this.onPremium,
    required this.onSettings,
    super.key,
  });

  final RecalieAiController controller;
  final VoidCallback onBack;
  final VoidCallback onPremium;
  final VoidCallback onSettings;

  static const prompts = [
    'Turn a topic into active-recall questions.',
    'Help me improve a difficult memory set.',
    'Why do I forget something after reviewing it?',
    'Build a focused spaced-repetition strategy for me.',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            _AiHeader(
              controller: controller,
              onBack: onBack,
              onPremium: onPremium,
              onSettings: onSettings,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  if (controller.messages.isEmpty && !controller.working) {
                    return _AiEmptyState(
                      errorMessage: controller.errorMessage,
                      onPromptSelected: (prompt) => controller.send(prompt),
                    );
                  }
                  return _AiMessages(controller: controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  const _AiHeader({
    required this.controller,
    required this.onBack,
    required this.onPremium,
    required this.onSettings,
  });

  final RecalieAiController controller;
  final VoidCallback onBack;
  final VoidCallback onPremium;
  final VoidCallback onSettings;

  Future<void> _showHistory(BuildContext context) async {
    final conversations = controller.history.reversed.toList();
    final selected = await showModalBottomSheet<RecalieAiConversation>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat history',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (conversations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: Text('No saved chats yet.')),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return ListTile(
                        tileColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        leading: const Icon(Icons.forum_rounded),
                        title: Text(
                          conversation.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_shortDate(conversation.createdAt)),
                        onTap: () => Navigator.pop(context, conversation),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) controller.openConversation(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        _TopCircleButton(
          tooltip: 'Back',
          onPressed: onBack,
          icon: Icons.arrow_back_rounded,
        ),
        const SizedBox(width: 7),
        _TopCapsule(
          children: [
            IconButton(
              tooltip: 'History',
              onPressed: () => _showHistory(context),
              icon: const Icon(Icons.history_rounded),
            ),
            _TopDivider(color: colors.outlineVariant),
            IconButton(
              tooltip: 'New chat',
              onPressed: controller.newChat,
              icon: const Icon(Icons.add_comment_rounded),
            ),
          ],
        ),
        const Spacer(),
        _TopCapsule(
          children: [
            IconButton(
              tooltip: 'Premium',
              onPressed: onPremium,
              icon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF38BDF8),
                    Color(0xFF2563EB),
                    Color(0xFF8B5CF6),
                  ],
                ).createShader(bounds),
                child: const Icon(Icons.workspace_premium_rounded),
              ),
            ),
            _TopDivider(color: colors.outlineVariant),
            IconButton(
              tooltip: 'Settings',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _AiEmptyState extends StatelessWidget {
  const _AiEmptyState({
    required this.onPromptSelected,
    required this.errorMessage,
  });

  final ValueChanged<String> onPromptSelected;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 96),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height - 260,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF60A5FA),
                    Color(0xFF2563EB),
                    Color(0xFF7C3AED),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: .22),
                    blurRadius: 26,
                    offset: const Offset(0, 11),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/recalie_logo_1024.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 17),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF60A5FA),
                  Color(0xFF2563EB),
                  Color(0xFF7C3AED),
                ],
              ).createShader(bounds),
              child: Text(
                'Recalie AI Coach',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Ask about active recall, memory sets, study material, or spaced repetition.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final prompt in RecalieAiCoachPage.prompts)
                  ActionChip(
                    avatar: Icon(
                      Icons.psychology_alt_rounded,
                      size: 17,
                      color: colors.primary,
                    ),
                    label: Text(prompt),
                    onPressed: () => onPromptSelected(prompt),
                  ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiMessages extends StatefulWidget {
  const _AiMessages({required this.controller});

  final RecalieAiController controller;

  @override
  State<_AiMessages> createState() => _AiMessagesState();
}

class _AiMessagesState extends State<_AiMessages> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _AiMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 104),
      itemCount:
          widget.controller.messages.length +
          (widget.controller.working ? 1 : 0) +
          (widget.controller.errorMessage == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index < widget.controller.messages.length) {
          return _MessageBubble(message: widget.controller.messages[index]);
        }
        if (widget.controller.working &&
            index == widget.controller.messages.length) {
          return const _ThinkingBubble();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            widget.controller.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.error),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiCoachMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fromUser = message.role == 'user';
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .79,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fromUser
              ? colors.primaryContainer
              : colors.surfaceContainerHigh,
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
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  message.imageBytes!,
                  width: 210,
                  height: 145,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 9),
            ],
            SelectableText(
              message.content,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 56,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const LinearProgressIndicator(minHeight: 3),
      ),
    );
  }
}

class RecalieAiComposer extends StatelessWidget {
  const RecalieAiComposer({required this.controller, super.key});

  final RecalieAiController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 66),
                padding: const EdgeInsets.fromLTRB(18, 6, 7, 6),
                decoration: _bottomDecoration(isDark),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.inputController,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (!controller.working) controller.send();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Ask Recalie AI',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: controller.working ? 'Stop' : 'Send',
                      onPressed: () => controller.send(),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          controller.working
                              ? Icons.stop_rounded
                              : Icons.arrow_upward_rounded,
                          key: ValueKey(controller.working),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 66,
              height: 66,
              decoration: _bottomDecoration(isDark),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (controller.pendingImage != null)
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: ClipOval(
                        child: Image.memory(
                          controller.pendingImage!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: 'Add an image',
                      onPressed: controller.pickImage,
                      icon: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: colors.primary,
                        size: 27,
                      ),
                    ),
                  if (controller.pendingImage != null)
                    Positioned(
                      right: 3,
                      top: 3,
                      child: IconButton.filled(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 26,
                          height: 26,
                        ),
                        padding: EdgeInsets.zero,
                        tooltip: 'Remove image',
                        onPressed: controller.removePendingImage,
                        icon: const Icon(Icons.close_rounded, size: 15),
                      ),
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

BoxDecoration _bottomDecoration(bool isDark) => BoxDecoration(
  color: isDark ? const Color(0xFF172033) : Colors.white,
  borderRadius: BorderRadius.circular(30),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? .2 : .1),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ],
);

class _TopCapsule extends StatelessWidget {
  const _TopCapsule({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF172033) : Colors.white,
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _TopCapsule(
      children: [
        IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon)),
      ],
    );
  }
}

class _TopDivider extends StatelessWidget {
  const _TopDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 25, color: color.withValues(alpha: .7));
  }
}

String _shortDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}
