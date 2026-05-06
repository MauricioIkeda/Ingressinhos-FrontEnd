import 'package:dio/dio.dart';
import 'package:ingressinho_frontzinho/Domain/Repositories/i_ingressos_repository.dart';

class IngressosRepository implements IIngressosRepository {
  final Dio _dio = Dio();

  @override
  Future<List<dynamic>> pegarIngresso() async {
    try {
      final response = await _dio.get("");
      return response.data;
    } catch (erro) {
      print("erro na requisicao get de pegar evento");
      return [];
    }
  }
}
