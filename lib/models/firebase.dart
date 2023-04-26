class PushNotificationRegistration {
  final String name;
  final String token;
  final WebPushSubscription web;

  PushNotificationRegistration({
    required this.name,
    required this.token,
    required this.web,
  });

  factory PushNotificationRegistration.fromJson(Map<String, dynamic> json) {
    return PushNotificationRegistration(
      name: json['name'],
      token: json['token'],
      web: WebPushSubscription.fromJson(json['web']),
    );
  }
}

class WebPushSubscription {
  final String endpoint;
  final String p256dh;
  final String auth;
  final String applicationPubKey;

  WebPushSubscription({
    required this.endpoint,
    required this.p256dh,
    required this.auth,
    required this.applicationPubKey,
  });

  factory WebPushSubscription.fromJson(Map<String, dynamic> json) {
    return WebPushSubscription(
      endpoint: json['endpoint'],
      p256dh: json['p256dh'],
      auth: json['auth'],
      applicationPubKey: json['applicationPubKey'],
    );
  }
}
