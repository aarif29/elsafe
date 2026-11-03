import 'package:elsafe/utils/notification_copy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const reminderBody =
      'Sudah 19 hari sejak pengingat diatur. Lokasi: Gardu A. ULP: Malang. '
      'Segera lakukan tindak lanjut sebelum mencapai 20 hari.';

  test('reminder count advances on the next local calendar day', () {
    expect(
      notificationBodyForDisplay(
        body: reminderBody,
        type: 'reminder_h1',
        createdAt: DateTime(2026, 11, 2, 8).toIso8601String(),
        now: DateTime(2026, 11, 3, 7),
      ),
      'Sudah 20 hari sejak pengingat diatur. Lokasi: Gardu A. ULP: Malang. '
      'Segera lakukan tindak lanjut.',
    );
  });

  test('reminder count advances across multiple days', () {
    expect(
      notificationBodyForDisplay(
        body: reminderBody,
        type: 'reminder_h1',
        createdAt: DateTime(2026, 11, 2, 8).toIso8601String(),
        now: DateTime(2026, 11, 5, 9),
      ),
      startsWith('Sudah 22 hari sejak pengingat diatur.'),
    );
  });

  test('other notifications and missing dates keep their original body', () {
    expect(
      notificationBodyForDisplay(
        body: reminderBody,
        type: 'general',
        createdAt: DateTime(2026, 11, 2).toIso8601String(),
        now: DateTime(2026, 11, 3),
      ),
      reminderBody,
    );
    expect(
      notificationBodyForDisplay(
        body: reminderBody,
        type: 'reminder_h1',
        createdAt: null,
        now: DateTime(2026, 11, 3),
      ),
      reminderBody,
    );
  });
}
