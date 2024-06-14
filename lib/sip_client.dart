import 'package:dart_pbx/sip_parser/sip.dart';
import 'package:dart_pbx/transports/transport.dart';

class SipClient {
  SipClient(this.number, this.transport);

  // bool operator ==(SipClient other) {
  //   if (_number == other.getNumber()) {
  //     return true;
  //   }

  //   return false;
  // }

  String getNumber() {
    return number;
  }

  SipTransport getAddress() {
    return transport;
  }

  String number;
  SipTransport transport;
}
