String getDaysAgo(String timestamp) {
  final now = DateTime.now();
  final difference = now.difference(DateTime.parse(timestamp)).inDays;

  if (difference == 0) {
    return 'today';
  } else if (difference == 1) {
    return 'yesterday';
  } else {
    return '$difference days ago';
  }
}

String getMinutesDiff(dynamic submission) {
  final createdAt = DateTime.parse(submission['created_at']);
  if (submission['submitted_at'] == null) {
    return "In progress ${DateTime.now().difference(createdAt).inMinutes}'";
  }
  final submittedAt = DateTime.parse(submission['submitted_at']);
  return "${submittedAt.difference(createdAt).inMinutes} minutes";
}
