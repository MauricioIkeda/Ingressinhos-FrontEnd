class CheckoutResponseModel {
  final int? paymentTransactionId;
  final CheckoutOrderModel? order;
  final CheckoutQrCodeModel? qrCode;

  const CheckoutResponseModel({
    this.paymentTransactionId,
    this.order,
    this.qrCode,
  });

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    final orderJson = json['order'];
    final qrCodeJson = json['qrCode'];

    return CheckoutResponseModel(
      paymentTransactionId: parseInt(json['paymentTransactionId']),
      order: orderJson is Map<String, dynamic>
          ? CheckoutOrderModel.fromJson(orderJson)
          : null,
      qrCode: qrCodeJson is Map<String, dynamic>
          ? CheckoutQrCodeModel.fromJson(qrCodeJson)
          : null,
    );
  }
}

class CheckoutOrderModel {
  final int? orderId;
  final double amount;
  final String? method;
  final int? status;

  const CheckoutOrderModel({
    this.orderId,
    required this.amount,
    this.method,
    this.status,
  });

  factory CheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return CheckoutOrderModel(
      orderId: parseInt(json['orderId']),
      amount: parseDouble(json['amount']),
      method: json['method']?.toString(),
      status: parseInt(json['status']),
    );
  }
}

class CheckoutQrCodeModel {
  final String? payload;
  final String? imageDataUri;
  final String? webhookSimulationUrl;

  const CheckoutQrCodeModel({
    this.payload,
    this.imageDataUri,
    this.webhookSimulationUrl,
  });

  factory CheckoutQrCodeModel.fromJson(Map<String, dynamic> json) {
    return CheckoutQrCodeModel(
      payload: json['payload']?.toString(),
      imageDataUri: json['imageDataUri']?.toString(),
      webhookSimulationUrl: json['webhookSimulationUrl']?.toString(),
    );
  }
}
