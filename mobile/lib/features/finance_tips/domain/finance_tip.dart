class FinanceTip {
  const FinanceTip({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime? createdAt;
}

const fallbackFinanceTip = FinanceTip(
  id: 'local-fallback',
  title: 'Track small expenses',
  content: 'Small daily expenses can become large monthly spending.',
);
