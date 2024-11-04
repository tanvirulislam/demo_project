// class FileOutput extends LogOutput {
//   final File file;

//   FileOutput({required this.file});

//   @override
//   void output(OutputEvent event) {
//     try {
//       final string = '${event.lines.join('\n')}\n';
//       file.writeAsStringSync(string, mode: FileMode.append);
//       // Also print to console for development
//       print(string);
//     } catch (e) {
//       print('Failed to write to log file: $e');
//     }
//   }
// }
