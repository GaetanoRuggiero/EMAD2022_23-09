import 'package:arts/model/reward.dart';

class ScanQR {
  Reward? reward;
  String? message;

  ScanQR(
  {
    this.reward,
    this.message
  });

  ScanQR.fromJson(Map<String, dynamic> json) {
    reward =
    json['reward'] != null ? Reward.fromJson(json['reward']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reward != null) {
      data['reward'] = reward!.toJson();
    }
    data['message'] = message;
    return data;
  }

  @override
  String toString() {
    return 'ScanQR{reward: $reward, message: $message}';
  }
}
