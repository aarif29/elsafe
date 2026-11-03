/// Updates the elapsed-day text in a stored reminder notification for display.
/// The saved notification remains unchanged.
String notificationBodyForDisplay({
  required String body,
  required String type,
  required String? createdAt,
  required DateTime now,
}) {
  if (type != 'reminder_h1') return body;

  final created = DateTime.tryParse(createdAt ?? '')?.toLocal();
  final match = RegExp(
    r'^Sudah (\d+) hari sejak pengingat diatur\.',
  ).firstMatch(body);
  if (created == null || match == null) return body;

  final initialDays = int.tryParse(match.group(1)!);
  if (initialDays == null) return body;

  final today = now.toLocal();
  final elapsedCalendarDays =
      DateTime.utc(today.year, today.month, today.day)
          .difference(DateTime.utc(created.year, created.month, created.day))
          .inDays;
  final days =
      initialDays + (elapsedCalendarDays < 0 ? 0 : elapsedCalendarDays);

  final updated = body.replaceRange(
    match.start,
    match.end,
    'Sudah $days hari sejak pengingat diatur.',
  );
  if (days < 20) return updated;

  return updated.replaceFirst(
    'Segera lakukan tindak lanjut sebelum mencapai 20 hari.',
    'Segera lakukan tindak lanjut.',
  );
}
