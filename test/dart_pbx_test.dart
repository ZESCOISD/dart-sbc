import 'package:dart_pbx/dart_pbx.dart';
import 'package:dart_pbx/globals.dart';
import 'package:test/test.dart';

void main() {
  var register = [
    'REGISTER sip:10.100.54.52:5060;transport=UDP SIP/2.0',
    'Via: SIP/2.0/UDP 10.100.54.52:60901;branch=z9hG4bK-524287-1---0f3eb40b11f97a9c;rport',
    'Max-Forwards: 70',
    'Contact: <sip:6002@10.100.54.52:60901;rinstance=1964f334d2b5ba69;transport=UDP>',
    'To: <sip:6002@10.100.54.52:5060;transport=UDP>',
    'From: <sip:6002@10.100.54.52:5060;transport=UDP>;tag=5e00e125',
    'Call-ID: wSSsR1c-lUjKuRhxr0iEKA..',
    'CSeq: 1 REGISTER',
    'Expires: 70',
    'Allow: INVITE, ACK, CANCEL, BYE, NOTIFY, REFER, MESSAGE, OPTIONS, INFO, SUBSCRIBE',
    'Supported: replaces, norefersub, extended-refer, timer, sec-agree, outbound, path, X-cisco-serviceuri',
    'User-Agent: Z 5.6.1 v2.10.19.9',
    'Allow-Events: presence, kpml, talk, as-feature-event',
    'Content-Length: 0',
  ].join("\r\n");

  SipMessage sipMsg = SipMessage();
  sipMsg.Parse(register);
  //print("Expires header value: ${sipMsg.Exp.Value}");

  ////print(register);
}
