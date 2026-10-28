import 'package:flutter/services.dart';

import '../models/country_code.dart';

enum EmailError { empty, invalidFormat }

/// A format pre-check, not a deliverability check — this can't tell you
/// whether an address actually exists or accepts mail, only that it's
/// shaped like one. The only real way to confirm an address works is to
/// send it something and see if it bounces/gets confirmed, which is out
/// of scope here. Deliberately kept simple rather than attempting a full
/// RFC 5322 pattern, which is notoriously fussy to get exactly right.
final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Returns an [EmailError] if [email] doesn't look like a plausible
/// address, or `null` if it's fine. Returned as an enum, not an English
/// message, so the UI layer localizes it — see `DueDateError`'s doc for
/// why.
EmailError? validateEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return EmailError.empty;
  if (!_emailPattern.hasMatch(trimmed)) return EmailError.invalidFormat;
  return null;
}

/// Strips everything but digits from [raw] — spaces, dashes,
/// parentheses, a leading '+', all of it. Mirrors the server's
/// PhoneNumbers.DigitsOnly exactly.
String phoneDigitsOnly(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');

/// A implausible digit count for a given country — carries the expected
/// and actual counts so the UI can phrase the message (and localize
/// [country]'s own name) without this function needing a `BuildContext`.
class PhoneLengthError {
  final CountryCode country;
  final int expected;
  final int actual;
  const PhoneLengthError({required this.country, required this.expected, required this.actual});
}

/// Returns a [PhoneLengthError] if [digits] (already digits-only) isn't a
/// plausible length for [country], or `null` if it's fine — see
/// CountryCodeInfo.expectedNationalNumberLength's doc: this is a light
/// sanity check, not real phone validation.
PhoneLengthError? validatePhoneDigits(String digits, CountryCode country) {
  final expected = country.expectedNationalNumberLength;
  if (digits.length != expected) {
    return PhoneLengthError(country: country, expected: expected, actual: digits.length);
  }
  return null;
}

/// A [TextInputFormatter] that only lets digits through — for the phone
/// field, since the country is picked separately rather than typed as
/// part of the number.
final digitsOnlyInputFormatter = FilteringTextInputFormatter.digitsOnly;
