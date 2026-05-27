import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';

abstract class IssuedTicketsRemoteDatasource {
  Future<List<IssuedTicketModel>> getIssuedTickets({
    int skip = 0,
    int top = 4,
    String? orderBy,
  });
}
