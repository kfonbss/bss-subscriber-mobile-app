class TicketCategoryEntity {
  final String id;
  final String code;
  final String name;
  final String nameInLocal;
  final bool isActive;

  const TicketCategoryEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.nameInLocal,
    required this.isActive,
  });
}
