class SubjectEntity {
  final String id;
  final String code;
  final String name;
  final String escalationTime;
  final bool isActive;

  const SubjectEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.escalationTime,
    required this.isActive,
  });
}
