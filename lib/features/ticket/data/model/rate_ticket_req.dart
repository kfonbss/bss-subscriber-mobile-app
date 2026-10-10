/// Rating a ticket. NOTE: field names are placeholders until the API is ready.
class RateTicketReq {
  final String ticketUuid;

  /// 1 (very poor) – 5 (excellent).
  final int rating;
  final String comment;

  const RateTicketReq({
    required this.ticketUuid,
    required this.rating,
    this.comment = '',
  });

  Map<String, dynamic> toJson() => {'rating': rating, 'comment': comment};
}
