class ChannelSettings {
  final bool autoResponse;
  const ChannelSettings({required this.autoResponse});

  factory ChannelSettings.fromJson(Map<String, dynamic> json) {
    return ChannelSettings(
      autoResponse: json['autoResponse'] as bool? ?? true,
    );
  }
}
