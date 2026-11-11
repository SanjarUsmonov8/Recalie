import 'dart:typed_data';

import 'package:flutter/material.dart';

Future<void> showNoteImageViewer({
  required BuildContext context,
  required List<Uint8List> images,
  int initialIndex = 0,
}) {
  if (images.isEmpty) return Future.value();
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: true,
      pageBuilder: (context, _, _) => _NoteImageViewer(
        images: images,
        initialIndex: initialIndex.clamp(0, images.length - 1),
      ),
    ),
  );
}

Future<void> showMovableNotePopup({
  required BuildContext context,
  required Offset anchor,
  required String content,
  List<Uint8List> images = const [],
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close note',
    barrierColor: Colors.black.withValues(alpha: 0.08),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, _) =>
        _MovableNotePopup(anchor: anchor, content: content, images: images),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
        child: child,
      ),
    ),
  );
}

class _MovableNotePopup extends StatefulWidget {
  const _MovableNotePopup({
    required this.anchor,
    required this.content,
    required this.images,
  });

  final Offset anchor;
  final String content;
  final List<Uint8List> images;

  @override
  State<_MovableNotePopup> createState() => _MovableNotePopupState();
}

class _MovableNotePopupState extends State<_MovableNotePopup> {
  late Offset _position = Offset(widget.anchor.dx - 18, widget.anchor.dy + 22);

  Future<void> _openPhoto(int initialIndex) async {
    await showNoteImageViewer(
      context: context,
      images: widget.images,
      initialIndex: initialIndex,
    );
  }

  Widget _imageStrip() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _openPhoto(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: widget.images.length == 1 ? 298 : 150,
              child: Image.memory(widget.images[index], fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final maximumWidth = (constraints.maxWidth - 24).clamp(150.0, 330.0);
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.content,
            style:
                Theme.of(context).textTheme.bodyLarge ??
                const TextStyle(fontSize: 16),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final width = widget.images.isEmpty
            ? (textPainter.width + 42).clamp(150.0, maximumWidth)
            : maximumWidth;
        const estimatedHeight = 390.0;
        final safeTop = MediaQuery.paddingOf(context).top + 8;
        final safeBottom = MediaQuery.paddingOf(context).bottom + 8;
        final position = Offset(
          _position.dx.clamp(12.0, constraints.maxWidth - width - 12),
          _position.dy.clamp(
            safeTop,
            (constraints.maxHeight - estimatedHeight - safeBottom).clamp(
              safeTop,
              constraints.maxHeight - safeBottom,
            ),
          ),
        );
        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              width: width,
              child: Material(
                elevation: 12,
                shadowColor: Colors.black45,
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 390),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) =>
                            setState(() => _position += details.delta),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.drag_indicator_rounded,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Note',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Close',
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.images.isNotEmpty) ...[
                                _imageStrip(),
                                if (widget.content.isNotEmpty)
                                  const SizedBox(height: 14),
                              ],
                              if (widget.content.isNotEmpty)
                                SelectableText(
                                  widget.content,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _NoteImageViewer extends StatefulWidget {
  const _NoteImageViewer({required this.images, required this.initialIndex});

  final List<Uint8List> images;
  final int initialIndex;

  @override
  State<_NoteImageViewer> createState() => _NoteImageViewerState();
}

class _NoteImageViewerState extends State<_NoteImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) => InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 6,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: Center(
                    child: Image.memory(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 8,
              child: IconButton.filled(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                right: 16,
                top: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      '${_index + 1}/${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
