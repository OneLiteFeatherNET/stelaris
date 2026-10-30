import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/picker/asset_key.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The state of one upload into [projectId]: the chosen file, its name and
/// key and what went wrong. [AssetUploadForm] shows it, the dialog around it decides
/// when to [upload].
class AssetUploadController extends ChangeNotifier {
  AssetUploadController({
    required this.projectId,
    required this.pickFile,
    this.namespace,
    this.kinds = const {...AssetKind.values},
    this.fixedKey,
  }) {
    if (fixedKey case final key?) {
      keyController.text = key;
      _lastKey = key;
    }
    keyController.addListener(_onKeyChanged);
    nameController.addListener(_onNameChanged);
  }

  final String projectId;

  /// The project key, which the suggested keys start with.
  final String? namespace;

  /// The kinds this upload takes, a file of another kind can't be uploaded.
  final Set<AssetKind> kinds;

  /// The key the file must be stored under, e.g. the one a model refers to.
  /// A chosen file keeps it instead of suggesting one from its name.
  final String? fixedKey;

  /// Opens the file dialog, injectable for tests.
  final Future<PickedAssetFile?> Function() pickFile;

  final TextEditingController keyController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  PickedAssetFile? _file;
  bool _reading = false;
  bool _readFailed = false;
  bool _uploading = false;
  String? _keyError;
  String? _nameError;
  String? _fileError;
  String? _uploadError;

  /// Counts the files taken, so a file read after a newer one is dropped.
  int _takeId = 0;
  String _lastKey = '';
  String _lastName = '';

  /// The name suggested for the file taken last, replaced by the next file's
  /// suggestion unless the user typed another name.
  String _suggestedName = '';

  /// The file waiting for upload, null before one is chosen.
  PickedAssetFile? get file => _file;

  /// What [file] is stored as, null when it can't be uploaded here.
  AssetKind? get fileKind {
    final kind = _file == null ? null : assetKindOfFileName(_file!.name);
    return kinds.contains(kind) ? kind : null;
  }

  bool get reading => _reading;

  /// Whether the file chosen last could not be read.
  bool get readFailed => _readFailed;

  bool get uploading => _uploading;

  /// The reason of the backend against the key.
  String? get keyError => _keyError;

  /// The reason of the backend against the name.
  String? get nameError => _nameError;

  /// The reason of the backend against the file.
  String? get fileError => _fileError;

  /// A reason of the backend that names no field.
  String? get uploadError => _uploadError;

  /// What is wrong with the key before the backend sees it.
  AssetKeyProblem? get keyProblem => checkAssetKey(keyController.text.trim());

  /// Whether the name is missing, which the upload requires.
  bool get nameMissing => nameController.text.trim().isEmpty;

  bool get canUpload =>
      _file != null &&
      fileKind != null &&
      keyProblem == null &&
      !nameMissing &&
      !_reading &&
      !_uploading;

  /// Opens the file dialog and takes the chosen file.
  Future<void> choose() => _take(pickFile);

  /// Takes a dropped file once it is read.
  Future<void> drop(Future<PickedAssetFile> file) => _take(() => file);

  Future<void> _take(Future<PickedAssetFile?> Function() read) async {
    if (_uploading) return;
    final takeId = ++_takeId;
    _reading = true;
    notifyListeners();
    PickedAssetFile? picked;
    var failed = false;
    try {
      picked = await read();
    } on Object {
      failed = true;
    }
    if (takeId != _takeId) return;
    _reading = false;
    _readFailed = failed;
    if (picked != null) {
      _file = picked;
      _clearProblems();
      _suggestName(picked.name);
      if (fixedKey != null) {
        notifyListeners();
        return;
      }
      final key = suggestAssetKey(picked.name, namespace: namespace);
      _lastKey = key;
      keyController.value = TextEditingValue(
        text: key,
        selection: TextSelection.collapsed(offset: key.length),
      );
    }
    notifyListeners();
  }

  /// Puts the name suggested for [fileName] in the name field, unless the
  /// user typed another name than the one suggested before.
  void _suggestName(String fileName) {
    final name = nameController.text;
    if (name.trim().isNotEmpty && name != _suggestedName) return;
    _suggestedName = suggestAssetName(fileName);
    _lastName = _suggestedName;
    nameController.value = TextEditingValue(
      text: _suggestedName,
      selection: TextSelection.collapsed(offset: _suggestedName.length),
    );
  }

  /// Drops the chosen file, e.g. after it was uploaded.
  void clear() {
    if (_uploading) return;
    _takeId++;
    _file = null;
    _reading = false;
    _readFailed = false;
    _clearProblems();
    notifyListeners();
  }

  /// Uploads [file] under the key. Resolves to the stored asset, or to null
  /// when the backend rejects it, with its reasons put under the field they
  /// name.
  Future<AssetModel?> upload() async {
    final picked = _file;
    if (picked == null || !canUpload) return null;
    _uploading = true;
    _clearProblems();
    notifyListeners();
    try {
      return await ApiService().assetApi.upload(
        projectId,
        key: keyController.text.trim(),
        displayName: nameController.text.trim(),
        fileName: picked.name,
        bytes: picked.bytes,
      );
    } on DioException catch (error) {
      _showProblem(ProblemDetail.fromDioException(error));
      return null;
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }

  void _clearProblems() {
    _keyError = null;
    _nameError = null;
    _fileError = null;
    _uploadError = null;
  }

  void _showProblem(ProblemDetail problem) {
    final errors = problem.errors;
    final keyMessages = [
      for (final error in errors)
        if (error.field == 'key') error.message,
    ];
    final nameMessages = [
      for (final error in errors)
        if (error.field == 'displayName') error.message,
    ];
    final fileMessages = [
      for (final error in errors)
        if (error.field == 'file') error.message,
    ];
    final otherMessages = [
      for (final error in errors)
        if (!const {'key', 'displayName', 'file'}.contains(error.field))
          error.message,
    ];

    // A conflict is about the key even when the backend names no field.
    _keyError = keyMessages.isNotEmpty
        ? keyMessages.join('\n')
        : (problem.status == 409 ? problem.displayMessage : null);
    _nameError = nameMessages.isEmpty ? null : nameMessages.join('\n');
    _fileError = fileMessages.isEmpty ? null : fileMessages.join('\n');
    if (_keyError == null && _nameError == null && _fileError == null) {
      _uploadError = problem.displayMessage;
    } else {
      _uploadError = otherMessages.isEmpty ? null : otherMessages.join('\n');
    }
  }

  /// A changed key answers the backend's reason against the old one, and
  /// changes whether the key can be uploaded.
  void _onKeyChanged() {
    final key = keyController.text;
    if (key == _lastKey) return;
    _lastKey = key;
    _keyError = null;
    notifyListeners();
  }

  /// A changed name answers the backend's reason against the old one, and
  /// changes whether the upload can start.
  void _onNameChanged() {
    final name = nameController.text;
    if (name == _lastName) return;
    _lastName = name;
    _nameError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    keyController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
