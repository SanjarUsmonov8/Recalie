import 'package:flutter/material.dart';
import 'package:recalie/data/local/local_repository.dart';

class SubjectTextPage extends StatefulWidget {
  const SubjectTextPage({
    super.key,
    required this.repository,
    required this.subject,
    this.startEditing = false,
  });

  final LocalRepository repository;
  final SavedPictureGroup subject;
  final bool startEditing;

  @override
  State<SubjectTextPage> createState() => _SubjectTextPageState();
}

class _SubjectTextPageState extends State<SubjectTextPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.subject.textContent ?? '',
  );
  late bool _isEditing = widget.startEditing;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleMode() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    setState(() => _isSaving = true);
    await widget.repository.updateSubjectText(
      widget.subject.id,
      _controller.text,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    key: const Key('subjectTextModeButton'),
                    tooltip: _isEditing ? 'Save and read' : 'Edit text',
                    onPressed: _isSaving ? null : _toggleMode,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isEditing
                                ? Icons.menu_book_rounded
                                : Icons.edit_rounded,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                _isEditing ? 'Editing' : 'Reading mode',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isEditing
                    ? TextField(
                        key: const Key('subjectTextEditor'),
                        controller: _controller,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Write the information you want to recall.',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          _controller.text.isEmpty
                              ? 'There is no text in this memory set yet.'
                              : _controller.text,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.65),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
