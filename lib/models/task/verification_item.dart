class VerificationItem {
  final int step;
  final String question;
  final bool? answer;

  const VerificationItem({
    required this.step,
    required this.question,
    this.answer,
  });

  VerificationItem copyWith({bool? answer}) {
    return VerificationItem(step: step, question: question, answer: answer);
  }
}
