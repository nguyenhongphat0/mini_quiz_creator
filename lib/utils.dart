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
