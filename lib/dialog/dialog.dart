import 'package:dart_pbx/globals.dart';
import 'package:dart_sip_parser/sip.dart';

import '../transactions/transaction_base.dart';

class Dialog {
  String callId;

  Dialog(this.callId);
  Map<String, Transaction> transactions = {};

  SipMessage? caller;
  SipMessage? callee;
}
