/// Reference used to curate the data (SC-005 traceability).
final class SourceRef {
  const SourceRef({required this.name, required this.url, this.notes});

  final String name;
  final String url;
  final String? notes;
}
