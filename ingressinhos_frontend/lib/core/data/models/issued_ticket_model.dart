class IssuedTicketModel {
  final int? issuedTicketId;
  final String accessCode;
  final String status;
  final DateTime? issuedAtUtc;
  final DateTime? paidAtUtc;
  final DateTime? checkedInAtUtc;
  final DateTime? cancelledAtUtc;
  final int? eventId;
  final String eventName;
  final DateTime? eventStartTimeUtc;
  final DateTime? eventEndTimeUtc;
  final String? eventImageUrl;
  final int? locationId;
  final String? locationName;
  final String? ticketName;
  final String? category;
  final String? seatCode;
  final DateTime? projectedAtUtc;

  IssuedTicketModel({
    required this.issuedTicketId,
    required this.accessCode,
    required this.status,
    required this.eventName,
    this.issuedAtUtc,
    this.paidAtUtc,
    this.checkedInAtUtc,
    this.cancelledAtUtc,
    this.eventId,
    this.eventStartTimeUtc,
    this.eventEndTimeUtc,
    this.eventImageUrl,
    this.locationId,
    this.locationName,
    this.ticketName,
    this.category,
    this.seatCode,
    this.projectedAtUtc,
  });

  factory IssuedTicketModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return IssuedTicketModel(
      issuedTicketId: parseInt(json['issuedTicketId'] ?? json['id']),
      accessCode: json['accessCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Issued',
      issuedAtUtc: parseDate(json['issuedAtUtc']),
      paidAtUtc: parseDate(json['paidAtUtc']),
      checkedInAtUtc: parseDate(json['checkedInAtUtc']),
      cancelledAtUtc: parseDate(json['cancelledAtUtc']),
      eventId: parseInt(json['eventId']),
      eventName: (json['eventName']?.toString() ?? '').trim().isNotEmpty
          ? json['eventName'].toString()
          : 'Evento sem nome',
      eventStartTimeUtc: parseDate(json['eventStartTimeUtc']),
      eventEndTimeUtc: parseDate(json['eventEndTimeUtc']),
      eventImageUrl: json['eventImageUrl']?.toString(),
      locationId: parseInt(json['locationId']),
      locationName: json['locationName']?.toString(),
      ticketName: json['ticketName']?.toString(),
      category: json['category']?.toString(),
      seatCode: json['seatCode']?.toString(),
      projectedAtUtc: parseDate(json['projectedAtUtc']),
    );
  }
}
