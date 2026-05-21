import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/data/models/ticket_model.dart';

class IngressinhosLocalDatasource {
  static final Map<int, LocationModel> locationCache = {};
  static final Map<int, TicketModel> ticketCache = {};
}