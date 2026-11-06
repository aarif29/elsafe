import 'package:elsafe/config/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collectPages fetches records beyond the first server page', () async {
    final records = List.generate(1001, (index) => index);
    final ranges = <(int, int)>[];

    final result = await collectPages<int>(
      pageSize: 500,
      fetchPage: (from, to) async {
        ranges.add((from, to));
        return records.skip(from).take(to - from + 1).toList();
      },
    );

    expect(result, records);
    expect(ranges, [(0, 499), (500, 999), (1000, 1499)]);
  });

  test(
    'collectPages propagates later failures instead of returning a partial count',
    () async {
      expect(
        () => collectPages<int>(
          pageSize: 2,
          fetchPage: (from, to) async {
            if (from == 0) return [1, 2];
            throw StateError('page failed');
          },
        ),
        throwsStateError,
      );
    },
  );
}
