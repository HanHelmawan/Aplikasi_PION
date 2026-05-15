import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('withValues(alpha: )')) {
      content = content.replaceAll('withValues(alpha: )', 'withOpacity(0.1)'); // Provide a safe default opacity
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
    }
  }
}
