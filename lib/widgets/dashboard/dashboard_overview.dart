import '../../config/temuan_model.dart';
import '../../config/ulp_list.dart';

/// Angka yang ditampilkan dashboard untuk satu cakupan ULP.
class DashboardOverview {
  final int totalCount;
  final int openCount;
  final int openKmu;
  final int openRow;
  final int openOtherType;
  final Map<String, int> openByArea;
  final List<TemuanModel> priorityOpen;

  const DashboardOverview._({
    required this.totalCount,
    required this.openCount,
    required this.openKmu,
    required this.openRow,
    required this.openOtherType,
    required this.openByArea,
    required this.priorityOpen,
  });

  factory DashboardOverview.fromFindings(
    List<TemuanModel> findings, {
    String? selectedUlp,
    required bool groupByUlp,
  }) {
    final scoped =
        selectedUlp == null
            ? findings
            : findings
                .where((t) => t.ulp != null && ulpSama(t.ulp!, selectedUlp))
                .toList();
    final open =
        scoped
            .where((t) => t.statusTemuan?.trim().toLowerCase() == 'open')
            .toList();
    final byArea = <String, int>{};
    final areaLabels = <String, String>{};
    var kmu = 0;
    var row = 0;

    for (final temuan in open) {
      switch (temuan.tipeTemuan?.trim().toUpperCase()) {
        case 'KMU':
          kmu++;
        case 'ROW':
          row++;
      }
      final rawArea = groupByUlp ? temuan.ulp : temuan.namaPenyulang;
      final area =
          rawArea == null || rawArea.trim().isEmpty
              ? (groupByUlp ? 'ULP belum diisi' : 'Penyulang belum diisi')
              : (groupByUlp ? namaUlpKanonis(rawArea) : rawArea.trim());
      final label =
          groupByUlp
              ? areaLabels.putIfAbsent(area.toLowerCase(), () => area)
              : area;
      byArea.update(label, (count) => count + 1, ifAbsent: () => 1);
    }

    open.sort((a, b) {
      final risk = _riskOrder(
        a.levelRisiko,
      ).compareTo(_riskOrder(b.levelRisiko));
      if (risk != 0) return risk;
      return a.tanggalTemuan.compareTo(b.tanggalTemuan);
    });

    return DashboardOverview._(
      totalCount: scoped.length,
      openCount: open.length,
      openKmu: kmu,
      openRow: row,
      openOtherType: open.length - kmu - row,
      openByArea: Map.unmodifiable(byArea),
      priorityOpen: List.unmodifiable(open),
    );
  }

  static int _riskOrder(String? level) => switch (level?.trim().toLowerCase()) {
    'extreme' => 0,
    'high' => 1,
    'medium' => 2,
    _ => 3,
  };
}
