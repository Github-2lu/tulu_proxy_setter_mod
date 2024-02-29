import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Proxy {
  final String id;
  String name;
  String host;
  String port;
  String noProxy;

  Proxy(
      {required this.name,
      required this.host,
      required this.port,
      required this.noProxy})
      : id = uuid.v4();
  Proxy.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData["id"],
        name = jsonData["name"],
        host = jsonData["host"],
        port = jsonData["port"],
        noProxy = jsonData["noProxy"];

  Map<String, dynamic> toJson() =>
      {"id": id, "name":name,"host": host, "port": port, "noProxy": noProxy};
}
