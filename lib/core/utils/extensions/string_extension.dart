// lib/core/utils/extensions/string_extension.dart

import 'package:menahariya/core/utils/helpers/string_helper.dart';

import '../helpers/string_helper.dart';

extension StringExtension on String {
  // Capitalize first letter
  String get capitalize => StringHelper.capitalize(this);

  // Capitalize all words
  String get capitalizeWords => StringHelper.capitalizeWords(this);

  // Check if null or empty
  bool get isNullOrEmpty => StringHelper.isNullOrEmpty(this);

  // Check if null or whitespace
  bool get isNullOrWhitespace => StringHelper.isNullOrWhitespace(this);

  // Remove all whitespace
  String get removeWhitespace => StringHelper.removeWhitespace(this);

  // Normalize spaces
  String get normalizeSpaces => StringHelper.normalizeSpaces(this);

  // Get initials
  String get initials => StringHelper.getInitials(this);

  // Mask string
  String mask({int visibleCount = 4, String maskChar = '*'}) =>
      StringHelper.maskString(this, visibleCount: visibleCount, maskChar: maskChar);

  // Mask email
  String get maskEmail => StringHelper.maskEmail(this);

  // Generate slug
  String get slug => StringHelper.generateSlug(this);

  // Check if alpha
  bool get isAlpha => StringHelper.isAlpha(this);

  // Check if numeric
  bool get isNumeric => StringHelper.isNumeric(this);

  // Check if alphanumeric
  bool get isAlphanumeric => StringHelper.isAlphanumeric(this);

  // Extract numbers
  String get extractNumbers => StringHelper.extractNumbers(this);

  // Extract letters
  String get extractLetters => StringHelper.extractLetters(this);

  // Convert to camelCase
  String get camelCase => StringHelper.toCamelCase(this);

  // Convert to PascalCase
  String get pascalCase => StringHelper.toPascalCase(this);

  // Convert to snake_case
  String get snakeCase => StringHelper.toSnakeCase(this);

  // Convert to kebab-case
  String get kebabCase => StringHelper.toKebabCase(this);

  // Word count
  int get wordCount => StringHelper.wordCount(this);

  // Sentence count
  int get sentenceCount => StringHelper.sentenceCount(this);

  // Reverse string
  String get reversed => StringHelper.reverse(this);

  // Check if palindrome
  bool get isPalindrome => StringHelper.isPalindrome(this);

  // Check if contains emoji
  bool get containsEmoji => StringHelper.containsEmoji(this);

  // Remove emojis
  String get removeEmojis => StringHelper.removeEmojis(this);

  // Truncate with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) =>
      StringHelper.truncate(this, maxLength, ellipsis: ellipsis);

  // Get common prefix with another string
  String commonPrefixWith(String other) => StringHelper.commonPrefix(this, other);

  // Levenshtein distance to another string
  int levenshteinDistanceTo(String other) => StringHelper.levenshteinDistance(this, other);

  // Similarity to another string
  double similarityWith(String other) => StringHelper.similarity(this, other);

  // Format as phone number
  String get asPhoneNumber => StringHelper.formatPhoneNumber(this);

  // Format as ticket reference
  String get asTicketReference => StringHelper.formatTicketReference(this);

  // Format as cargo tracking ID
  String get asCargoTrackingId => StringHelper.formatCargoTrackingId(this);

  // Parse to int safely
  int? toIntOrNull() => int.tryParse(this);

  // Parse to double safely
  double? toDoubleOrNull() => double.tryParse(this);

  // Check if contains any of the given strings
  bool containsAny(Iterable<String> substrings) {
    return substrings.any((substring) => contains(substring));
  }

  // Check if contains all of the given strings
  bool containsAll(Iterable<String> substrings) {
    return substrings.every((substring) => contains(substring));
  }

  // Count occurrences of substring
  int countOccurrences(String substring) {
    if (substring.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }
    return count;
  }

  // Replace multiple strings at once
  String replaceMany(Map<String, String> replacements) {
    String result = this;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  // Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  // Check if string is a valid phone (Ethiopian)
  bool get isValidEthiopianPhone {
    final phoneRegex = RegExp(r'^(09|2519|\+2519)\d{8}$');
    return phoneRegex.hasMatch(removeWhitespace);
  }

  // Check if string is a valid URL
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  // Check if string is a valid Ethiopian license plate
  bool get isValidLicensePlate {
    final plateRegex = RegExp(r'^[A-Z]{2}-\d{4}-[A-Z]{2}$');
    return plateRegex.hasMatch(toUpperCase());
  }

  // Extract hashtags from string
  List<String> get extractHashtags {
    final hashtagRegex = RegExp(r'#(\w+)');
    return hashtagRegex.allMatches(this).map((match) => match.group(0)!).toList();
  }

  // Extract mentions from string
  List<String> get extractMentions {
    final mentionRegex = RegExp(r'@(\w+)');
    return mentionRegex.allMatches(this).map((match) => match.group(0)!).toList();
  }

  // Convert to title case
  String get toTitleCase {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Check if string is a valid time (HH:MM format)
  bool get isValidTime {
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(this);
  }

  // Check if string is a valid date (YYYY-MM-DD)
  bool get isValidDate {
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return dateRegex.hasMatch(this);
  }

  // Get the first n characters
  String first(int n) => length > n ? substring(0, n) : this;

  // Get the last n characters
  String last(int n) => length > n ? substring(length - n) : this;

  // Remove prefix if exists
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }

  // Remove suffix if exists
  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }

  // Add prefix if not exists
  String withPrefix(String prefix) {
    if (startsWith(prefix)) return this;
    return prefix + this;
  }

  // Add suffix if not exists
  String withSuffix(String suffix) {
    if (endsWith(suffix)) return this;
    return this + suffix;
  }

  // Repeat string n times
  String repeat(int n) => List.generate(n, (_) => this).join();

  // Center string with padding
  String center(int width, {String padding = ' '}) {
    if (length >= width) return this;
    final leftPadding = (width - length) ~/ 2;
    final rightPadding = width - length - leftPadding;
    return padding.repeat(leftPadding) + this + padding.repeat(rightPadding);
  }
}