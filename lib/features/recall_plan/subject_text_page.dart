import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recalie/data/local/local_repository.dart';
import 'package:recalie/features/photo_groups/memory_set_style.dart';
import 'package:recalie/features/recall_plan/recall_review_completion.dart';

const _pageSeparator = '\f';

class SubjectTextPage extends StatefulWidget {
  const SubjectTextPage({
    super.key,
    required this.repository,
    required this.subject,
    this.startEditing = false,
    this.initialPage = 0,
  });
  final LocalRepository repository;
  final SavedPictureGroup subject;
  final bool startEditing;
  final int initialPage;

  @override
  State<SubjectTextPage> createState() => _SubjectTextPageState();
}

class _SubjectTextPageState extends State<SubjectTextPage> {
  late final PageController _pageController = PageController(
    initialPage: _page,
  );
  late final List<TextEditingController> _pages = _makePages();
  late int _page = widget.initialPage.clamp(0, _pages.length - 1);
  late bool _editing = widget.startEditing;
  bool _saving = false;
  bool _drawing = false;
  bool _covering = false;
  bool _notes = false;
  double _coverFraction = .5;
  _TextCoverDirection _coverDirection = _TextCoverDirection.right;
  bool _solidCover = false;
  Offset _notePosition = const Offset(.5, .5);
  final Map<int, List<_TextStroke>> _strokes = {};
  final Map<int, List<_PageNote>> _pageNotes = {};
  Set<int> _reviewedPages = {};
  _TextAnnotationTool _drawingTool = _TextAnnotationTool.pen;
  _TextEraserMode _eraserMode = _TextEraserMode.line;
  bool _straightLine = false;
  double _drawingThickness = 5;
  double _drawingOpacity = .95;
  Color _drawingColor = Colors.red;
  bool _showDrawingPreview = true;
  final List<List<_TextStroke>> _undoHistory = [];
  final List<List<_TextStroke>> _redoHistory = [];

  String get _markupPreferenceKey => 'subject_text_markup_${widget.subject.id}';
  String get _reviewPreferenceKey =>
      'subject_text_reviewed_${widget.subject.id}';

  @override
  void initState() {
    super.initState();
    _loadMarkup();
    _loadReviewedPages();
  }

  Future<void> _loadReviewedPages() async {
    final value = await widget.repository.readPreference(_reviewPreferenceKey);
    final reviewed = <int>{};
    if (value != null && value.isNotEmpty) {
      for (final part in value.split(',')) {
        final page = int.tryParse(part);
        if (page != null && page >= 0 && page < _pages.length) {
          reviewed.add(page);
        }
      }
    }
    if (mounted) setState(() => _reviewedPages = reviewed);
  }

  Future<void> _togglePageReviewed() async {
    final wasReviewed = _reviewedPages.contains(_page);
    setState(() {
      if (!_reviewedPages.add(_page)) _reviewedPages.remove(_page);
    });
    await widget.repository.savePreference(
      _reviewPreferenceKey,
      (_reviewedPages.toList()..sort()).join(','),
    );
    if (!wasReviewed) {
      final completed = await completeTodayIfEveryItemIsReviewed(
        repository: widget.repository,
        subjectId: widget.subject.id,
      );
      if (completed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Today\'s recall is complete.')),
        );
      }
    }
  }

  Future<void> _loadMarkup() async {
    final stored = await widget.repository.readPreference(_markupPreferenceKey);
    if (stored == null || stored.isEmpty) return;
    try {
      final data = jsonDecode(stored) as Map<String, dynamic>;
      final storedStrokes = data['strokes'] as Map<String, dynamic>?;
      final storedLines = data['lines'] as Map<String, dynamic>? ?? const {};
      final storedNotes = data['notes'] as Map<String, dynamic>? ?? const {};
      final strokes = <int, List<_TextStroke>>{};
      final notes = <int, List<_PageNote>>{};
      if (storedStrokes != null) {
        for (final entry in storedStrokes.entries) {
          strokes[int.parse(entry.key)] = (entry.value as List<dynamic>)
              .map(
                (stroke) => _TextStroke.fromJson(
                  Map<String, dynamic>.from(stroke as Map),
                ),
              )
              .toList();
        }
      } else {
        for (final entry in storedLines.entries) {
          strokes[int.parse(entry.key)] = (entry.value as List<dynamic>)
              .map(
                (stroke) => _TextStroke(
                  tool: _TextAnnotationTool.pen,
                  straight: false,
                  thickness: 4,
                  opacity: 1,
                  color: memoryNumberCircleColor,
                  points: (stroke as List<dynamic>)
                      .map(
                        (point) => Offset(
                          ((point as List<dynamic>)[0] as num).toDouble(),
                          (point[1] as num).toDouble(),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList();
        }
      }
      for (final entry in storedNotes.entries) {
        notes[int.parse(entry.key)] = (entry.value as List<dynamic>)
            .map(
              (note) =>
                  _PageNote.fromJson(Map<String, dynamic>.from(note as Map)),
            )
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _strokes
          ..clear()
          ..addAll(strokes);
        _pageNotes
          ..clear()
          ..addAll(notes);
      });
    } on Object {
      // Ignore damaged legacy markup; the written text remains available.
    }
  }

  Future<void> _saveMarkup() {
    final data = <String, dynamic>{
      'strokes': _strokes.map(
        (page, strokes) => MapEntry(
          '$page',
          strokes.map((stroke) => stroke.toJson()).toList(),
        ),
      ),
      'notes': _pageNotes.map(
        (page, notes) =>
            MapEntry('$page', notes.map((note) => note.toJson()).toList()),
      ),
    };
    return widget.repository.savePreference(
      _markupPreferenceKey,
      jsonEncode(data),
    );
  }

  List<TextEditingController> _makePages() {
    final text = widget.subject.textContent ?? '';
    return (text.contains(_pageSeparator) ? text.split(_pageSeparator) : [text])
        .map((page) => TextEditingController(text: page))
        .toList();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.repository.updateSubjectText(
        widget.subject.id,
        _pages.map((page) => page.text).join(_pageSeparator),
      );
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save pages: $error')));
    }
  }

  Future<void> _toggleEditing() async {
    if (!_editing) {
      setState(() {
        _editing = true;
        _drawing = _covering = _notes = false;
      });
      return;
    }
    await _save();
    if (mounted && !_saving) setState(() => _editing = false);
  }

  Future<void> _addPage() async {
    setState(() {
      _pages.add(TextEditingController());
      _editing = true;
      _page = _pages.length - 1;
    });
    await _save();
    if (!mounted) return;
    await _pageController.animateToPage(
      _page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<String?> _noteEditor([String initial = '']) {
    var value = initial;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.viewInsetsOf(context).bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: initial,
                autofocus: true,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Write your note…',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) => update(() => value = text),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: value.trim().isEmpty
                      ? null
                      : () => Navigator.of(sheetContext).pop(value.trim()),
                  child: const Text('Save note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createNote() async {
    final text = await _noteEditor();
    if (text == null) return;
    setState(() {
      (_pageNotes[_page] ??= []).add(_PageNote(_notePosition, text));
      _notePosition = const Offset(.5, .5);
    });
    await _saveMarkup();
  }

  Future<void> _leave() async {
    await _save();
    await _saveMarkup();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _toggleDrawing() async {
    if (_drawing) {
      await _saveMarkup();
      if (!mounted) return;
    }
    setState(() {
      _drawing = !_drawing;
      _covering = _notes = _editing = false;
      _showDrawingPreview = true;
      _undoHistory.clear();
      _redoHistory.clear();
    });
  }

  List<_TextStroke> _strokeSnapshot() =>
      (_strokes[_page] ?? const []).map((stroke) => stroke.copyWith()).toList();

  void _recordUndo() {
    _undoHistory.add(_strokeSnapshot());
    if (_undoHistory.length > 50) _undoHistory.removeAt(0);
    _redoHistory.clear();
  }

  void _undoDrawing() {
    if (_undoHistory.isEmpty) return;
    setState(() {
      _redoHistory.add(_strokeSnapshot());
      _strokes[_page] = _undoHistory.removeLast();
    });
  }

  void _redoDrawing() {
    if (_redoHistory.isEmpty) return;
    setState(() {
      _undoHistory.add(_strokeSnapshot());
      _strokes[_page] = _redoHistory.removeLast();
    });
  }

  void _selectDrawingTool(_TextAnnotationTool tool) {
    setState(() {
      _drawingTool = tool;
      if (tool == _TextAnnotationTool.highlighter) {
        _drawingOpacity = .35;
        _drawingThickness = 14;
      } else if (tool == _TextAnnotationTool.pen) {
        _drawingOpacity = .95;
        _drawingThickness = 5;
      } else {
        _drawingOpacity = 1;
        _drawingThickness = 14;
      }
      _showDrawingPreview = true;
    });
  }

  Offset _normalizedPoint(Offset position, Size size) => Offset(
    (position.dx / size.width).clamp(0.0, 1.0),
    (position.dy / size.height).clamp(0.0, 1.0),
  );

  void _startDrawing(Offset position, Size size) {
    _recordUndo();
    final point = _normalizedPoint(position, size);
    if (_drawingTool == _TextAnnotationTool.eraser) {
      _eraseAt(point, size);
      return;
    }
    setState(() {
      _showDrawingPreview = false;
      (_strokes[_page] ??= []).add(
        _TextStroke(
          tool: _drawingTool,
          straight: _straightLine,
          thickness: _drawingThickness,
          opacity: _drawingOpacity,
          color: _drawingColor,
          points: [point],
        ),
      );
    });
  }

  void _continueDrawing(Offset position, Size size) {
    final point = _normalizedPoint(position, size);
    if (_drawingTool == _TextAnnotationTool.eraser) {
      _eraseAt(point, size);
      return;
    }
    final strokes = _strokes[_page];
    if (strokes == null || strokes.isEmpty) return;
    setState(() {
      final stroke = strokes.last;
      if (stroke.straight) {
        if (stroke.points.length == 1) {
          stroke.points.add(point);
        } else {
          stroke.points[1] = point;
        }
      } else {
        stroke.points.add(point);
      }
    });
  }

  void _finishDrawing() {
    final strokes = _strokes[_page];
    if (strokes == null || strokes.isEmpty) return;
    final stroke = strokes.last;
    if (stroke.points.length == 1) {
      stroke.points.add(stroke.points.first + const Offset(.001, .001));
    }
  }

  void _eraseAt(Offset point, Size size) {
    final strokes = _strokes[_page];
    if (strokes == null || strokes.isEmpty) return;
    final pixelPoint = Offset(point.dx * size.width, point.dy * size.height);
    final radius = (_drawingThickness * 1.35).clamp(10.0, 34.0);
    setState(() {
      if (_eraserMode == _TextEraserMode.line) {
        final index = strokes.lastIndexWhere(
          (stroke) => stroke.points.any(
            (saved) =>
                (Offset(saved.dx * size.width, saved.dy * size.height) -
                        pixelPoint)
                    .distance <=
                radius + stroke.thickness / 2,
          ),
        );
        if (index >= 0) strokes.removeAt(index);
      } else {
        for (final stroke in strokes) {
          stroke.points.removeWhere(
            (saved) =>
                (Offset(saved.dx * size.width, saved.dy * size.height) -
                        pixelPoint)
                    .distance <=
                radius,
          );
        }
        strokes.removeWhere((stroke) => stroke.points.length < 2);
      }
      _showDrawingPreview = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final page in _pages) {
      page.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: _leave,
                      ),
                      const Spacer(),
                      _ToolCapsule(
                        notes: _notes,
                        cover: _covering,
                        drawing: _drawing,
                        onNotes: () => setState(() {
                          _notes = !_notes;
                          _drawing = _covering = _editing = false;
                          _notePosition = const Offset(.5, .5);
                        }),
                        onCover: () => setState(() {
                          _covering = !_covering;
                          _drawing = _notes = _editing = false;
                          _coverFraction = .5;
                        }),
                        onDrawing: _toggleDrawing,
                      ),
                      const SizedBox(width: 5),
                      _PageControlsCapsule(
                        page: _page + 1,
                        reviewed: _reviewedPages.contains(_page),
                        editing: _editing,
                        saving: _saving,
                        onAdd: _addPage,
                        onMode: _saving ? null : _toggleEditing,
                        onReview: _togglePageReviewed,
                      ),
                    ],
                  ),
                ),
                if (_covering)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _TextCoverDirectionPicker(
                          direction: _coverDirection,
                          onChanged: (direction) => setState(() {
                            _coverDirection = direction;
                            _coverFraction = .5;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _TextCoverOpacityPicker(
                          solid: _solidCover,
                          onChanged: (value) =>
                              setState(() => _solidCover = value),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: _drawing || _covering || _notes
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    onPageChanged: (value) => setState(() => _page = value),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: .72,
                          child: Material(
                            color: dark
                                ? const Color(0xFF172033)
                                : Colors.white,
                            elevation: dark ? 0 : 5,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: LayoutBuilder(
                              builder: (context, box) => Stack(
                                fit: StackFit.expand,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: _editing && index == _page
                                        ? TextField(
                                            key: const Key('subjectTextEditor'),
                                            controller: _pages[index],
                                            expands: true,
                                            minLines: null,
                                            maxLines: null,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            decoration:
                                                const InputDecoration.collapsed(
                                                  hintText:
                                                      'Write what you want to recall…',
                                                ),
                                          )
                                        : SingleChildScrollView(
                                            child: SelectableText(
                                              _pages[index].text.isEmpty
                                                  ? 'This page is empty.'
                                                  : _pages[index].text,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(height: 1.65),
                                            ),
                                          ),
                                  ),
                                  IgnorePointer(
                                    child: CustomPaint(
                                      painter: _TextStrokePainter(
                                        _strokes[index] ?? const [],
                                      ),
                                    ),
                                  ),
                                  if (_drawing && index == _page)
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: (details) => _startDrawing(
                                        details.localPosition,
                                        box.biggest,
                                      ),
                                      onPanUpdate: (details) =>
                                          _continueDrawing(
                                            details.localPosition,
                                            box.biggest,
                                          ),
                                      onPanEnd: (_) => _finishDrawing(),
                                    ),
                                  if (_covering && index == _page)
                                    _PageCover(
                                      fraction: _coverFraction,
                                      dark: dark,
                                      direction: _coverDirection,
                                      solid: _solidCover,
                                      onChanged: (value) => setState(
                                        () => _coverFraction = value,
                                      ),
                                    ),
                                  if (!_drawing && !_covering)
                                    _NotesLayer(
                                      notes: _pageNotes[index] ?? const [],
                                      adding: _notes && index == _page,
                                      draft: _notePosition,
                                      onMove: (value) =>
                                          setState(() => _notePosition = value),
                                      onCreate: _createNote,
                                      onOpen: (note) async {
                                        final text = await _noteEditor(
                                          note.text,
                                        );
                                        if (text != null && mounted) {
                                          setState(() => note.text = text);
                                          await _saveMarkup();
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_drawing && _showDrawingPreview)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: _TextDrawingPreview(
                      tool: _drawingTool,
                      thickness: _drawingThickness,
                      opacity: _drawingOpacity,
                      color: _drawingColor,
                    ),
                  ),
                ),
              ),
            if (_drawing)
              Positioned(
                left: 18,
                right: 18,
                bottom: 24,
                child: _TextDrawingToolbar(
                  tool: _drawingTool,
                  eraserMode: _eraserMode,
                  straight: _straightLine,
                  thickness: _drawingThickness,
                  opacity: _drawingOpacity,
                  color: _drawingColor,
                  canUndo: _undoHistory.isNotEmpty,
                  canRedo: _redoHistory.isNotEmpty,
                  onToolChanged: _selectDrawingTool,
                  onEraserModeChanged: (value) => setState(() {
                    _eraserMode = value;
                    _showDrawingPreview = true;
                  }),
                  onStraightChanged: (value) => setState(() {
                    _straightLine = value;
                    _showDrawingPreview = true;
                  }),
                  onThicknessChanged: (value) => setState(() {
                    _drawingThickness = value;
                    _showDrawingPreview = true;
                  }),
                  onOpacityChanged: (value) => setState(() {
                    _drawingOpacity = value;
                    _showDrawingPreview = true;
                  }),
                  onColorChanged: (value) => setState(() {
                    _drawingColor = value;
                    _showDrawingPreview = true;
                  }),
                  onUndo: _undoDrawing,
                  onRedo: _redoDrawing,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: memoryNumberCircleColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    ),
  );
}

class _ToolCapsule extends StatelessWidget {
  const _ToolCapsule({
    required this.notes,
    required this.cover,
    required this.drawing,
    required this.onNotes,
    required this.onCover,
    required this.onDrawing,
  });
  final bool notes;
  final bool cover;
  final bool drawing;
  final VoidCallback onNotes;
  final VoidCallback onCover;
  final VoidCallback onDrawing;
  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: memoryNumberCircleColor,
      borderRadius: BorderRadius.circular(23),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Tool(
          tooltip: 'Page notes',
          selected: notes,
          onTap: onNotes,
          child: const Icon(Icons.note_add_rounded, size: 23),
        ),
        Container(width: 1, height: 24, color: Colors.white30),
        _Tool(
          tooltip: 'Partial cover',
          selected: cover,
          onTap: onCover,
          child: const _TextPartialCoverToolIcon(),
        ),
        Container(width: 1, height: 24, color: Colors.white30),
        _Tool(
          tooltip: drawing ? 'Save drawing' : 'Draw on page',
          selected: drawing,
          onTap: onDrawing,
          child: Icon(
            drawing ? Icons.check_rounded : Icons.draw_rounded,
            size: drawing ? 27 : 23,
          ),
        ),
      ],
    ),
  );
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.child,
  });
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.white24 : Colors.transparent,
        ),
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: child,
        ),
      ),
    ),
  );
}

class _PageControlsCapsule extends StatelessWidget {
  const _PageControlsCapsule({
    required this.page,
    required this.reviewed,
    required this.editing,
    required this.saving,
    required this.onAdd,
    required this.onMode,
    required this.onReview,
  });

  final int page;
  final bool reviewed;
  final bool editing;
  final bool saving;
  final VoidCallback onAdd;
  final VoidCallback? onMode;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: memoryNumberCircleColor,
      borderRadius: BorderRadius.circular(23),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CapsuleAction(
          tooltip: 'Add page',
          icon: Icons.add_rounded,
          onTap: onAdd,
        ),
        Container(width: 1, height: 24, color: Colors.white30),
        _CapsuleAction(
          key: const Key('subjectTextModeButton'),
          tooltip: editing ? 'Reading mode' : 'Edit page',
          icon: editing ? Icons.menu_book_rounded : Icons.edit_rounded,
          onTap: onMode,
          loading: saving,
        ),
        Container(width: 1, height: 24, color: Colors.white30),
        _CapsuleReviewAction(page: page, reviewed: reviewed, onTap: onReview),
      ],
    ),
  );
}

class _CapsuleReviewAction extends StatelessWidget {
  const _CapsuleReviewAction({
    required this.page,
    required this.reviewed,
    required this.onTap,
  });

  final int page;
  final bool reviewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: reviewed ? 'Mark page as not recalled' : 'Mark page as recalled',
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: 42,
        child: Center(
          child: reviewed
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 27)
              : Text(
                  '$page',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    ),
  );
}

class _CapsuleAction extends StatelessWidget {
  const _CapsuleAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: 42,
        child: Center(
          child: loading
              ? const SizedBox.square(
                  dimension: 19,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 23),
        ),
      ),
    ),
  );
}

enum _TextAnnotationTool { pen, highlighter, eraser }

enum _TextEraserMode { line, area }

class _TextStroke {
  _TextStroke({
    required this.tool,
    required this.straight,
    required this.thickness,
    required this.opacity,
    required this.color,
    required this.points,
  });

  factory _TextStroke.fromJson(Map<String, dynamic> json) => _TextStroke(
    tool: _TextAnnotationTool.values.firstWhere(
      (tool) => tool.name == json['tool'],
      orElse: () => _TextAnnotationTool.pen,
    ),
    straight: json['straight'] as bool? ?? false,
    thickness: (json['thickness'] as num? ?? 4).toDouble(),
    opacity: (json['opacity'] as num? ?? 1).toDouble(),
    color: Color(json['color'] as int? ?? memoryNumberCircleColor.toARGB32()),
    points: (json['points'] as List<dynamic>? ?? const [])
        .map(
          (point) => Offset(
            ((point as List<dynamic>)[0] as num).toDouble(),
            (point[1] as num).toDouble(),
          ),
        )
        .toList(),
  );

  final _TextAnnotationTool tool;
  final bool straight;
  final double thickness;
  final double opacity;
  final Color color;
  final List<Offset> points;

  _TextStroke copyWith() => _TextStroke(
    tool: tool,
    straight: straight,
    thickness: thickness,
    opacity: opacity,
    color: color,
    points: [...points],
  );

  Map<String, dynamic> toJson() => {
    'tool': tool.name,
    'straight': straight,
    'thickness': thickness,
    'opacity': opacity,
    'color': color.toARGB32(),
    'points': points.map((point) => [point.dx, point.dy]).toList(),
  };
}

class _TextStrokePainter extends CustomPainter {
  const _TextStrokePainter(this.strokes);
  final List<_TextStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final points = stroke.points
          .map((point) => Offset(point.dx * size.width, point.dy * size.height))
          .toList();
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity)
        ..strokeWidth = stroke.thickness
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      if (stroke.straight || points.length < 3) {
        path.lineTo(points.last.dx, points.last.dy);
      } else {
        for (var index = 1; index < points.length - 1; index++) {
          final current = points[index];
          final next = points[index + 1];
          final midpoint = Offset(
            (current.dx + next.dx) / 2,
            (current.dy + next.dy) / 2,
          );
          path.quadraticBezierTo(
            current.dx,
            current.dy,
            midpoint.dx,
            midpoint.dy,
          );
        }
        path.lineTo(points.last.dx, points.last.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TextStrokePainter oldDelegate) => true;
}

class _TextDrawingToolbar extends StatelessWidget {
  const _TextDrawingToolbar({
    required this.tool,
    required this.eraserMode,
    required this.straight,
    required this.thickness,
    required this.opacity,
    required this.color,
    required this.canUndo,
    required this.canRedo,
    required this.onToolChanged,
    required this.onEraserModeChanged,
    required this.onStraightChanged,
    required this.onThicknessChanged,
    required this.onOpacityChanged,
    required this.onColorChanged,
    required this.onUndo,
    required this.onRedo,
  });

  final _TextAnnotationTool tool;
  final _TextEraserMode eraserMode;
  final bool straight;
  final double thickness;
  final double opacity;
  final Color color;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<_TextAnnotationTool> onToolChanged;
  final ValueChanged<_TextEraserMode> onEraserModeChanged;
  final ValueChanged<bool> onStraightChanged;
  final ValueChanged<double> onThicknessChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xE6202732),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TextDrawingChoice(
                  tooltip: 'Pen',
                  selected: tool == _TextAnnotationTool.pen,
                  icon: const Icon(Icons.draw_rounded),
                  onTap: () => onToolChanged(_TextAnnotationTool.pen),
                ),
                _TextDrawingChoice(
                  tooltip: 'Highlighter',
                  selected: tool == _TextAnnotationTool.highlighter,
                  icon: const Icon(Icons.border_color_rounded),
                  onTap: () => onToolChanged(_TextAnnotationTool.highlighter),
                ),
                _TextDrawingChoice(
                  tooltip: 'Eraser',
                  selected: tool == _TextAnnotationTool.eraser,
                  icon: const _TextEraserToolIcon(),
                  onTap: () => onToolChanged(_TextAnnotationTool.eraser),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xF2202732),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Undo',
                      onPressed: canUndo ? onUndo : null,
                      color: Colors.white,
                      disabledColor: Colors.white24,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: tool == _TextAnnotationTool.eraser
                            ? [
                                _TextLineChoice(
                                  tooltip: 'Erase whole line',
                                  selected: eraserMode == _TextEraserMode.line,
                                  icon: Icons.show_chart_rounded,
                                  onTap: () =>
                                      onEraserModeChanged(_TextEraserMode.line),
                                ),
                                const SizedBox(width: 10),
                                _TextLineChoice(
                                  tooltip: 'Erase area',
                                  selected: eraserMode == _TextEraserMode.area,
                                  icon: Icons.blur_circular_rounded,
                                  onTap: () =>
                                      onEraserModeChanged(_TextEraserMode.area),
                                ),
                              ]
                            : [
                                _TextLineChoice(
                                  tooltip: 'Curved line',
                                  selected: !straight,
                                  icon: Icons.gesture_rounded,
                                  onTap: () => onStraightChanged(false),
                                ),
                                const SizedBox(width: 10),
                                _TextLineChoice(
                                  tooltip: 'Straight line',
                                  selected: straight,
                                  icon: Icons.horizontal_rule_rounded,
                                  onTap: () => onStraightChanged(true),
                                ),
                              ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Redo',
                      onPressed: canRedo ? onRedo : null,
                      color: Colors.white,
                      disabledColor: Colors.white24,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
                _TextToolbarSlider(
                  label: 'Thickness',
                  value: thickness,
                  min: 1,
                  max: 20,
                  onChanged: onThicknessChanged,
                ),
                _TextToolbarSlider(
                  label: 'Opacity',
                  value: opacity,
                  min: .1,
                  max: 1,
                  onChanged: onOpacityChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final option in _colors)
                      GestureDetector(
                        onTap: () => onColorChanged(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 31,
                          height: 31,
                          decoration: BoxDecoration(
                            color: option,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.toARGB32() == option.toARGB32()
                                  ? memoryNumberCircleColor
                                  : Colors.white54,
                              width: color.toARGB32() == option.toARGB32()
                                  ? 3
                                  : 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TextDrawingPreview extends StatelessWidget {
  const _TextDrawingPreview({
    required this.tool,
    required this.thickness,
    required this.opacity,
    required this.color,
  });

  final _TextAnnotationTool tool;
  final double thickness;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = (thickness * 1.8).clamp(10.0, 42.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tool == _TextAnnotationTool.eraser
            ? Colors.white.withValues(alpha: opacity)
            : color.withValues(alpha: opacity),
        shape: tool == _TextAnnotationTool.highlighter
            ? BoxShape.rectangle
            : BoxShape.circle,
        borderRadius: tool == _TextAnnotationTool.highlighter
            ? BorderRadius.circular(3)
            : null,
      ),
    );
  }
}

class _TextDrawingChoice extends StatelessWidget {
  const _TextDrawingChoice({
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onTap,
    style: IconButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: selected ? memoryNumberCircleColor : Colors.transparent,
    ),
    icon: icon,
  );
}

class _TextLineChoice extends StatelessWidget {
  const _TextLineChoice({
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 62,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? memoryNumberCircleColor : Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    ),
  );
}

class _TextToolbarSlider extends StatelessWidget {
  const _TextToolbarSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 92,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: memoryNumberCircleColor,
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

class _TextEraserToolIcon extends StatelessWidget {
  const _TextEraserToolIcon();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 25,
    child: CustomPaint(painter: _TextEraserToolIconPainter()),
  );
}

class _TextEraserToolIconPainter extends CustomPainter {
  const _TextEraserToolIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 25, size.height / 25);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final body = Path()
      ..moveTo(4.5, 15.5)
      ..lineTo(13.4, 6.6)
      ..quadraticBezierTo(14.8, 5.2, 16.3, 6.6)
      ..lineTo(21.1, 11.4)
      ..quadraticBezierTo(22.5, 12.8, 21.1, 14.3)
      ..lineTo(14.2, 21.2)
      ..quadraticBezierTo(12.8, 22.5, 11.3, 21.1)
      ..lineTo(4.5, 14.3)
      ..close();
    canvas.drawPath(body, paint);
    canvas.drawLine(const Offset(8.2, 11.8), const Offset(16.8, 20.4), paint);
    canvas.drawLine(const Offset(2, 22.2), const Offset(13.2, 22.2), paint);
  }

  @override
  bool shouldRepaint(covariant _TextEraserToolIconPainter oldDelegate) => false;
}

enum _TextCoverDirection { right, left, bottom, top }

class _TextPartialCoverToolIcon extends StatelessWidget {
  const _TextPartialCoverToolIcon({this.direction});

  final _TextCoverDirection? direction;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 24,
    child: CustomPaint(
      painter: _TextPartialCoverToolIconPainter(direction: direction),
    ),
  );
}

class _TextPartialCoverToolIconPainter extends CustomPainter {
  const _TextPartialCoverToolIconPainter({this.direction});

  final _TextCoverDirection? direction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2.5, 2.5, size.width - 5, size.height - 5);
    if (direction != null) {
      final coveredRect = switch (direction!) {
        _TextCoverDirection.right => Rect.fromLTRB(
          rect.center.dx,
          rect.top,
          rect.right,
          rect.bottom,
        ),
        _TextCoverDirection.left => Rect.fromLTRB(
          rect.left,
          rect.top,
          rect.center.dx,
          rect.bottom,
        ),
        _TextCoverDirection.bottom => Rect.fromLTRB(
          rect.left,
          rect.center.dy,
          rect.right,
          rect.bottom,
        ),
        _TextCoverDirection.top => Rect.fromLTRB(
          rect.left,
          rect.top,
          rect.right,
          rect.center.dy,
        ),
      };
      canvas.drawRect(
        coveredRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    final divider = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8;
    if (direction == _TextCoverDirection.bottom ||
        direction == _TextCoverDirection.top) {
      canvas.drawLine(
        Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy),
        divider,
      );
    } else {
      canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        divider,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TextPartialCoverToolIconPainter oldDelegate) =>
      oldDelegate.direction != direction;
}

class _TextCoverDirectionPicker extends StatelessWidget {
  const _TextCoverDirectionPicker({
    required this.direction,
    required this.onChanged,
  });

  final _TextCoverDirection direction;
  final ValueChanged<_TextCoverDirection> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xF2202732),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in _TextCoverDirection.values)
          InkWell(
            onTap: () => onChanged(option),
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: option == direction
                    ? memoryNumberCircleColor
                    : Colors.transparent,
              ),
              child: _TextPartialCoverToolIcon(direction: option),
            ),
          ),
      ],
    ),
  );
}

class _TextCoverOpacityPicker extends StatelessWidget {
  const _TextCoverOpacityPicker({required this.solid, required this.onChanged});

  final bool solid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xF2202732),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TextCoverOpacityButton(
          tooltip: 'Transparent cover',
          selected: !solid,
          solid: false,
          onTap: () => onChanged(false),
        ),
        _TextCoverOpacityButton(
          tooltip: 'Solid cover',
          selected: solid,
          solid: true,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _TextCoverOpacityButton extends StatelessWidget {
  const _TextCoverOpacityButton({
    required this.tooltip,
    required this.selected,
    required this.solid,
    required this.onTap,
  });

  final String tooltip;
  final bool selected;
  final bool solid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? memoryNumberCircleColor : Colors.transparent,
        ),
        child: Container(
          width: 23,
          height: 23,
          decoration: BoxDecoration(
            color: const Color(0xFF60A5FA).withValues(alpha: solid ? 1 : .38),
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ),
  );
}

class _PageCover extends StatelessWidget {
  const _PageCover({
    required this.fraction,
    required this.dark,
    required this.direction,
    required this.solid,
    required this.onChanged,
  });
  final double fraction;
  final bool dark;
  final _TextCoverDirection direction;
  final bool solid;
  final ValueChanged<double> onChanged;

  bool get _usesVerticalDivider =>
      direction == _TextCoverDirection.right ||
      direction == _TextCoverDirection.left;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      void update(Offset position) {
        final value = _usesVerticalDivider
            ? position.dx / box.maxWidth
            : position.dy / box.maxHeight;
        onChanged(value.clamp(.04, .96));
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: !_usesVerticalDivider
            ? null
            : (details) => update(details.localPosition),
        onHorizontalDragUpdate: !_usesVerticalDivider
            ? null
            : (details) => update(details.localPosition),
        onVerticalDragStart: _usesVerticalDivider
            ? null
            : (details) => update(details.localPosition),
        onVerticalDragUpdate: _usesVerticalDivider
            ? null
            : (details) => update(details.localPosition),
        child: CustomPaint(
          painter: _TextPageCoverPainter(
            fraction: fraction,
            dark: dark,
            direction: direction,
            solid: solid,
          ),
          child: const SizedBox.expand(),
        ),
      );
    },
  );
}

class _TextPageCoverPainter extends CustomPainter {
  const _TextPageCoverPainter({
    required this.fraction,
    required this.dark,
    required this.direction,
    required this.solid,
  });

  final double fraction;
  final bool dark;
  final _TextCoverDirection direction;
  final bool solid;

  @override
  void paint(Canvas canvas, Size size) {
    final boundary = switch (direction) {
      _TextCoverDirection.right ||
      _TextCoverDirection.left => size.width * fraction,
      _TextCoverDirection.bottom ||
      _TextCoverDirection.top => size.height * fraction,
    };
    final coverRect = switch (direction) {
      _TextCoverDirection.right => Rect.fromLTRB(
        boundary,
        0,
        size.width,
        size.height,
      ),
      _TextCoverDirection.left => Rect.fromLTRB(0, 0, boundary, size.height),
      _TextCoverDirection.bottom => Rect.fromLTRB(
        0,
        boundary,
        size.width,
        size.height,
      ),
      _TextCoverDirection.top => Rect.fromLTRB(0, 0, size.width, boundary),
    };
    final coverPaint = Paint();
    if (solid) {
      coverPaint.color = dark
          ? const Color(0xFF163B73)
          : const Color(0xFF93C5FD);
    } else {
      coverPaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xC75BB9F8), Color(0xDD1D4ED8)],
      ).createShader(coverRect);
    }
    canvas.drawRect(coverRect, coverPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF102F70)
      ..strokeWidth = 4;
    final Offset handleCenter;
    if (direction == _TextCoverDirection.right ||
        direction == _TextCoverDirection.left) {
      canvas.drawLine(
        Offset(boundary, 0),
        Offset(boundary, size.height),
        borderPaint,
      );
      handleCenter = Offset(boundary, size.height / 2);
    } else {
      canvas.drawLine(
        Offset(0, boundary),
        Offset(size.width, boundary),
        borderPaint,
      );
      handleCenter = Offset(size.width / 2, boundary);
    }
    canvas.drawCircle(
      handleCenter,
      13,
      Paint()..color = const Color(0xFF102F70),
    );
    canvas.drawCircle(
      handleCenter,
      6,
      Paint()..color = const Color(0xFF93C5FD),
    );
  }

  @override
  bool shouldRepaint(covariant _TextPageCoverPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.dark != dark ||
      oldDelegate.direction != direction ||
      oldDelegate.solid != solid;
}

class _PageNote {
  _PageNote(this.position, this.text);

  factory _PageNote.fromJson(Map<String, dynamic> json) => _PageNote(
    Offset((json['x'] as num).toDouble(), (json['y'] as num).toDouble()),
    json['text'] as String,
  );

  final Offset position;
  String text;

  Map<String, dynamic> toJson() => {
    'x': position.dx,
    'y': position.dy,
    'text': text,
  };
}

class _NotesLayer extends StatelessWidget {
  const _NotesLayer({
    required this.notes,
    required this.adding,
    required this.draft,
    required this.onMove,
    required this.onCreate,
    required this.onOpen,
  });
  final List<_PageNote> notes;
  final bool adding;
  final Offset draft;
  final ValueChanged<Offset> onMove;
  final VoidCallback onCreate;
  final ValueChanged<_PageNote> onOpen;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Stack(
      children: [
        if (adding)
          Positioned(
            left: draft.dx * box.maxWidth - 18,
            top: draft.dy * box.maxHeight - 18,
            child: GestureDetector(
              onPanUpdate: (details) => onMove(
                Offset(
                  (draft.dx + details.delta.dx / box.maxWidth).clamp(0.0, 1.0),
                  (draft.dy + details.delta.dy / box.maxHeight).clamp(0.0, 1.0),
                ),
              ),
              onTap: onCreate,
              child: const _NoteIcon(Icons.note_add_rounded),
            ),
          ),
        for (final note in notes)
          Positioned(
            left: note.position.dx * box.maxWidth - 18,
            top: note.position.dy * box.maxHeight - 18,
            child: GestureDetector(
              onTap: () => onOpen(note),
              child: const _NoteIcon(Icons.sticky_note_2_rounded),
            ),
          ),
      ],
    ),
  );
}

class _NoteIcon extends StatelessWidget {
  const _NoteIcon(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: memoryNumberCircleColor,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}
