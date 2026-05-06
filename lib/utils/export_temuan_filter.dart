import '../config/temuan_model.dart';

List<TemuanModel> filterExportTemuan(
  List<TemuanModel> temuan, {
  DateTime? startDate,
  DateTime? endDate,
  Set<String> selectedStatuses = const {},
  Set<String> selectedRisiko = const {},
  Set<int> selectedZonas = const {},
  Set<int> selectedSections = const {},
  Set<String> selectedUlps = const {},
  String? selectedPenyulang,
}) {
  final start = startDate == null ? null : _dateOnly(startDate);
  final endExclusive =
      endDate == null ? null : _dateOnly(endDate).add(const Duration(days: 1));

  return temuan.where((t) {
    if (start != null && t.tanggalTemuan.isBefore(start)) return false;
    if (endExclusive != null && !t.tanggalTemuan.isBefore(endExclusive)) {
      return false;
    }

    if (!_matchesStringFilter(t.statusTemuan, selectedStatuses)) return false;
    if (!_matchesStringFilter(t.levelRisiko, selectedRisiko)) return false;
    if (!_matchesIntFilter(t.zona, selectedZonas)) return false;
    if (!_matchesIntFilter(t.section, selectedSections)) return false;
    if (!_matchesStringFilter(t.ulp, selectedUlps)) return false;

    if (selectedPenyulang != null && t.namaPenyulang != selectedPenyulang) {
      return false;
    }

    return true;
  }).toList();
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool _matchesStringFilter(String? value, Set<String> selected) {
  if (selected.isEmpty) return true;
  return value != null && selected.contains(value);
}

bool _matchesIntFilter(int? value, Set<int> selected) {
  if (selected.isEmpty) return true;
  return value != null && selected.contains(value);
}
