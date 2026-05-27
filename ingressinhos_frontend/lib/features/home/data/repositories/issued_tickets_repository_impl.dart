import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/issued_tickets_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/issued_tickets_repository.dart';

class IssuedTicketsRepositoryImpl implements IssuedTicketsRepository {
  final IssuedTicketsRemoteDatasource remoteDatasource;

  IssuedTicketsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<IssuedTicketModel>> getIssuedTickets({
    int skip = 0,
    int top = 4,
    String? orderBy,
  }) async {
    try {
      return await remoteDatasource.getIssuedTickets(
        skip: skip,
        top: top,
        orderBy: orderBy,
      );
    } on Exception catch (e) {
      throw Exception('Erro ao buscar ingressos: ${e.toString()}');
    }
  }
}
