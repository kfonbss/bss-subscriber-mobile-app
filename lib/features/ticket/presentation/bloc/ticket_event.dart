import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';

sealed class TicketEvent {
  const TicketEvent();
}

class LoadSubjects extends TicketEvent {
  final String categoryId;
  const LoadSubjects({required this.categoryId});
}

class LoadCategories extends TicketEvent {
  const LoadCategories();
}

/// Fetches customer types from API and auto-resolves the UUID matching [code].
/// Pass the role-based code, e.g. 'LNP' for LNP users.
class LoadCustomerTypeId extends TicketEvent {
  final String code;
  const LoadCustomerTypeId({required this.code});
}

class OnCategorySelect extends TicketEvent {
  final TicketCategoryEntity category;
  const OnCategorySelect({required this.category});
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
