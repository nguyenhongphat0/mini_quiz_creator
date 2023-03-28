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

String attendedAt(dynamic submission) {
  final createdAt = DateTime.parse(submission['created_at']);
  final now = DateTime.now();
  final difference = now.difference(createdAt);
  if (difference.inSeconds < 60) {
    return '⏳ Just started';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} days ago';
  } else {
    return createdAt.toString().split(' ')[0];
  }
}
