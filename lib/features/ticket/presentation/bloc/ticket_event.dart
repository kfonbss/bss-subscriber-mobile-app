import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';

sealed class TicketEvent {
  const TicketEvent();
}

class LoadSubjects extends TicketEvent {
  const LoadSubjects();
}

class LoadPriorities extends TicketEvent {
  const LoadPriorities();
}

class OnSubjectSelect extends TicketEvent {
  final SubjectEntity subject;
  const OnSubjectSelect({required this.subject});
}

class OnFileSelect extends TicketEvent {
  const OnFileSelect();
}

class OnSubmitTicket extends TicketEvent {
  final SubmitTicketReq params;
  OnSubmitTicket({required this.params});
}

class LoadTickets extends TicketEvent {
  final GetTicketsListParams params;
  const LoadTickets({required this.params});
}

class LoadMoreTickets extends TicketEvent {
  const LoadMoreTickets();
}

class RefreshTickets extends TicketEvent {
  final GetTicketsListParams params;
  const RefreshTickets({required this.params});
}

class LoadVisibilityPermissions extends TicketEvent {
  const LoadVisibilityPermissions();
}

class OnAddNote extends TicketEvent {
  final AddNoteReq params;
  const OnAddNote({required this.params});
}
