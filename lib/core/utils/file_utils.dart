class FileUtils {
  static String generateTaskImageFilename({
    required String taskUuid,
    required int sequence,
  }) {
    final shortUuid = taskUuid.length >= 8
        ? taskUuid.substring(0, 8)
        : taskUuid;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${shortUuid}_${timestamp}_${sequence.toString().padLeft(3, '0')}.jpg';
  }
}
