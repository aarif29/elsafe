/// Mengambil semua halaman; kegagalan satu halaman membatalkan seluruh hasil.
Future<List<T>> collectPages<T>({
  required Future<List<T>> Function(int from, int to) fetchPage,
  int pageSize = 500,
}) async {
  assert(pageSize > 0);
  final all = <T>[];
  for (var from = 0; ; from += pageSize) {
    final page = await fetchPage(from, from + pageSize - 1);
    all.addAll(page);
    if (page.length < pageSize) return all;
  }
}
