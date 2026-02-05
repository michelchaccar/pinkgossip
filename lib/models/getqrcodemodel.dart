// To parse this JSON data, do
//
//     final getQrCodemodel = getQrCodemodelFromJson(jsonString);

import 'dart:convert';

GetQrCodemodel getQrCodemodelFromJson(String str) =>
    GetQrCodemodel.fromJson(json.decode(str));

String getQrCodemodelToJson(GetQrCodemodel data) => json.encode(data.toJson());

class GetQrCodemodel {
  bool? success;
  String? qrCode;

  GetQrCodemodel({
    this.success,
    this.qrCode,
  });

  factory GetQrCodemodel.fromJson(Map<String, dynamic> json) => GetQrCodemodel(
        success: json["success"],
        qrCode: json["qr_code"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "qr_code": qrCode,
      };
}
