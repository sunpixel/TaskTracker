import 'package:flutter/services.dart';

import '../models/country_code.dart';

/// A format pre-check, not a deliverability check — this can't tell you
/// whether an address actually exists or accepts mail, only that it's
/// shaped like one. The only real way to confirm an address works is to
/// send it something and see if it bounces/gets confirmed, which is out
/// of scope here. Deliberately kept simple rather than attempting a full
/// RFC 5322 pattern, which is notoriously fussy to get exactly right.
final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Returns an error message if [email] doesn't look like a plausible
/// address, or `null` if it's fine.
String? validateEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return 'Email is required.';
  if (!_emailPattern.hasMatch(trimmed)) return "That doesn't look like a valid email address.";
  return null;
}

/// Strips everything but digits from [raw] — spaces, dashes,
/// parentheses, a leading '+', all of it. Mirrors the server's
/// PhoneNumbers.DigitsOnly exactly.
String phoneDigitsOnly(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');

/// Returns an error message if [digits] (already digits-only) isn't a
/// plausible length for [country], or `null` if it's fine — see
/// CountryCodeInfo.expectedNationalNumberLength's doc: this is a light
/// sanity check, not real phone validation.
String? validatePhoneDigits(String digits, CountryCode country) {
  final expected = country.expectedNationalNumberLength;
  if (digits.length != expected) {
    return 'A ${country.label} phone number should have $expected digits (got ${digits.length}).';
  }
  return null;
}

/// A [TextInputFormatter] that only lets digits through — for the phone
/// field, since the country is picked separately rather than typed as
/// part of the number.
final digitsOnlyInputFormatter = FilteringTextInputFormatter.digitsOnly;
