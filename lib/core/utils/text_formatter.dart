class TextFormatter {
  static String parseMarkdown(String text) {
    // Handle bold text
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => '<b>${match.group(1)}</b>',
    );

    // Handle italic text
    text = text.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
      (match) => '<i>${match.group(1)}</i>',
    );

    return text;
  }
} 