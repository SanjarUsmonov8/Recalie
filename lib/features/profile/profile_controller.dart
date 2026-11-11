import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:recalie/data/local/local_repository.dart';

class RecalieProfileController extends ChangeNotifier {
  RecalieProfileController(this._repository);

  static const _nameKey = 'profile_name';
  static const _photoKey = 'profile_photo_base64';

  final LocalRepository _repository;

  String _name = '';
  Uint8List? _photoBytes;

  String get name => _name;
  Uint8List? get photoBytes => _photoBytes;

  Future<void> load() async {
    final savedName = await _repository.readPreference(_nameKey);
    final savedPhoto = await _repository.readPreference(_photoKey);
    _name = savedName?.trim() ?? '';
    if (savedPhoto != null && savedPhoto.isNotEmpty) {
      try {
        _photoBytes = base64Decode(savedPhoto);
      } on FormatException {
        _photoBytes = null;
      }
    }
    notifyListeners();
  }

  Future<void> update({required String name, Uint8List? photoBytes}) async {
    _name = name.trim();
    _photoBytes = photoBytes;
    notifyListeners();
    await Future.wait([
      _repository.savePreference(_nameKey, _name),
      _repository.savePreference(
        _photoKey,
        photoBytes == null ? '' : base64Encode(photoBytes),
      ),
    ]);
  }
}

class RecalieProfileScope extends InheritedNotifier<RecalieProfileController> {
  const RecalieProfileScope({
    super.key,
    required RecalieProfileController controller,
    required super.child,
  }) : super(notifier: controller);

  static RecalieProfileController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RecalieProfileScope>();
    assert(scope != null, 'RecalieProfileScope is missing above this context.');
    return scope!.notifier!;
  }
}
