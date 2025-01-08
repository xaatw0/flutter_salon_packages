class IpOrHostnameAndPortValidator {
  // 正規表現: IPアドレスまたはホスト名 + ポート
  static final RegExp _ipOrHostnameAndPortRegex = RegExp(
    r'^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]):([1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]{1})$',
  );

  /// Validates the given IP address, hostname, and port combination.
  /// Throws an exception if the value is invalid.
  void validate(String value) {
    if (value.trim().isEmpty) {
      throw FormatException('Empty input is not allowed');
    }

    if (!_ipOrHostnameAndPortRegex.hasMatch(value)) {
      throw FormatException('Invalid IP/hostname and port combination: $value');
    }

    // Extract the port and validate its range (1-65535)
    final match = _ipOrHostnameAndPortRegex.firstMatch(value);
    if (match != null) {
      final port = int.tryParse(match.group(5) ?? '');
      if (port == null || port < 1 || port > 65535) {
        throw FormatException('Port out of range: $value');
      }
    }
  }
}
