// lib/core/utils/helpers/string_helper.dart

class StringHelper {
  // Private constructor
  StringHelper._();

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalize each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  // Remove all whitespace
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  // Remove extra spaces
  static String normalizeSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Check if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  // Check if string is null or whitespace
  static bool isNullOrWhitespace(String? text) {
    return text == null || text.trim().isEmpty;
  }

  // Get initials from name
  static String getInitials(String name, {int maxLetters = 2}) {
    if (name.isEmpty) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    final initials = words.take(maxLetters).map((word) => word[0].toUpperCase()).join();
    return initials;
  }

  // Mask string (e.g., for phone numbers)
  static String maskString(String text, {int visibleCount = 4, String maskChar = '*'}) {
    if (text.length <= visibleCount) return text;

    final maskedPart = maskChar * (text.length - visibleCount);
    final visiblePart = text.substring(text.length - visibleCount);
    return maskedPart + visiblePart;
  }

  // Mask email
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 3) {
      return '***@$domain';
    }

    final visiblePart = localPart.substring(0, 3);
    return '$visiblePart***@$domain';
  }

  // Generate slug from text
  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  // Check if string contains only letters
  static bool isAlpha(String text) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(text);
  }

  // Check if string contains only numbers
  static bool isNumeric(String text) {
    return RegExp(r'^\d+$').hasMatch(text);
  }

  // Check if string is alphanumeric
  static bool isAlphanumeric(String text) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
  }

  // Extract numbers from string
  static String extractNumbers(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Extract letters from string
  static String extractLetters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  // Convert to camelCase
  static String toCamelCase(String text) {
    final words = text.split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return '';

    final firstWord = words[0].toLowerCase();
    final restWords = words.skip(1).map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase()).join();

    return firstWord + restWords;
  }

  // Convert to PascalCase
  static String toPascalCase(String text) {
    final words = text.split(RegExp(r'[\s_-]+'));
    return words.map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase()).join();
  }

  // Convert to snake_case
  static String toSnakeCase(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'[^\w]'), '');
  }

  // Convert to kebab-case
  static String toKebabCase(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'[^\w-]'), '');
  }

  // Count words in text
  static int wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  // Count sentences
  static int sentenceCount(String text) {
    if (text.isEmpty) return 0;
    final sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty);
    return sentences.length;
  }

  // Reverse string
  static String reverse(String text) {
    return String.fromCharCodes(text.runes.toList().reversed);
  }

  // Check if string is palindrome
  static bool isPalindrome(String text) {
    final cleaned = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == reverse(cleaned);
  }

  // Get common prefix of two strings
  static String commonPrefix(String a, String b) {
    final minLength = a.length < b.length ? a.length : b.length;
    for (int i = 0; i < minLength; i++) {
      if (a[i] != b[i]) {
        return a.substring(0, i);
      }
    }
    return a.substring(0, minLength);
  }

  // Get Levenshtein distance between two strings
  static int levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(a.length + 1,
            (i) => List.generate(b.length + 1, (j) => 0));

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,        // deletion
          matrix[i][j - 1] + 1,        // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((curr, next) => curr < next ? curr : next);
      }
    }

    return matrix[a.length][b.length];
  }

  // Calculate similarity percentage
  static double similarity(String a, String b) {
    final maxLength = a.length > b.length ? a.length : b.length;
    if (maxLength == 0) return 1.0;

    final distance = levenshteinDistance(a, b);
    return 1.0 - (distance / maxLength);
  }

  // Generate random string
  static String randomString(int length, {bool includeNumbers = true}) {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';

    var chars = letters;
    if (includeNumbers) chars += numbers;

    return List.generate(length, (index) {
      final randomIndex = DateTime.now().microsecond % chars.length;
      return chars[randomIndex];
    }).join();
  }

  // Generate random OTP
  static String generateOTP({int length = 6}) {
    final numbers = '0123456789';
    return List.generate(length, (index) {
      final randomIndex = DateTime.now().microsecond % numbers.length;
      return numbers[randomIndex];
    }).join();
  }

  // Format as ticket reference
  static String formatTicketReference(String ref) {
    if (ref.isEmpty) return ref;

    final cleaned = ref.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length <= 4) return cleaned;

    // Format: MH-1234-5678
    final part1 = cleaned.substring(0, 2);
    final part2 = cleaned.substring(2, 6);
    final part3 = cleaned.substring(6);
    return 'MH-$part2-$part3';
  }

  // Format as cargo tracking ID
  static String formatCargoTrackingId(String id) {
    if (id.isEmpty) return id;

    final cleaned = id.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length <= 4) return cleaned;

    // Format: CG-1234-5678
    final part1 = cleaned.substring(0, 2);
    final part2 = cleaned.substring(2, 6);
    final part3 = cleaned.substring(6);
    return 'CG-$part2-$part3';
  }

  // Check if string contains emoji
  static bool containsEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }

  // Format as phone number (Ethiopian format)
  static String formatPhoneNumber(String phone) {
    // Remove non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Handle Ethiopian phone numbers
    if (digits.length == 10 && digits.startsWith('09')) {
      // Format: 0912 345 678
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    } else if (digits.length == 12 && digits.startsWith('251')) {
      // Format: +251 91 234 5678
      return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    } else if (digits.length == 9) {
      // Format: 912 345 678 (without leading zero)
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    // Return original if no format matches
    return phone;
  }
  // Remove emojis from string
  static String removeEmojis(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return text.replaceAll(emojiRegex, '');
  }
}