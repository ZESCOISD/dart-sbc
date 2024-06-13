//import 'package:dart_pbx/sip/transport.dart';
import 'package:dart_pbx/transports/transport.dart';
import 'package:dart_sip_parser/sip.dart';
import 'package:dart_sip_parser/sip_message_types.dart';

class RequestsHandler {
  Map<String, Function(SipMsg)> handlers = {};

  RequestsHandler() {
    handlers[SipMessageTypes.REGISTER.toLowerCase()] = OnRegister;
    handlers[SipMessageTypes.CANCEL.toLowerCase()] = OnCancel;
    handlers[SipMessageTypes.REQUEST_TERMINATED.toLowerCase()] =
        onReqTerminated;
    handlers[SipMessageTypes.INVITE.toLowerCase()] = OnInvite;
    handlers[SipMessageTypes.TRYING.toLowerCase()] = OnTrying;
    handlers[SipMessageTypes.RINGING.toLowerCase()] = OnRinging;
    handlers[SipMessageTypes.BUSY.toLowerCase()] = OnBusy;
    handlers[SipMessageTypes.UNAVAIALBLE.toLowerCase()] = OnUnavailable;
    handlers[SipMessageTypes.BYE.toLowerCase()] = OnBye;
    handlers[SipMessageTypes.OK.toLowerCase()] = OnOk;
    handlers[SipMessageTypes.ACK.toLowerCase()] = OnAck;
    handlers[SipMessageTypes.UNAUTHORIZED.toLowerCase()] = onUnauthorized;
  }

  OnRegister(SipMsg data) {}
  OnCancel(SipMsg data) {}

  onReqTerminated(SipMsg data) {}
  OnInvite(SipMsg data) {}
  OnTrying(SipMsg data) {}
  OnRinging(SipMsg data) {}
  OnBusy(SipMsg data) {}
  OnUnavailable(SipMsg data) {}
  OnBye(SipMsg data) {}
  OnOk(SipMsg data) {}
  OnAck(SipMsg data) {}
  onUnauthorized(SipMsg data) {}

  void handle(String request, SipTransport transport) {
    SipMsg sipMsg = SipMsg();
    sipMsg.Parse(request);
  }
}
