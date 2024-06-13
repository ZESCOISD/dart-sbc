import 'package:dart_sip_parser/sip.dart';

class SipTransport {
  sockaddr_in socket;
  Function(String) send;

  SipTransport(this.socket, this.send);
}
