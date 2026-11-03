import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/active_package_details/data/repository/railwire_package_details_repository_imp.dart';
import 'package:kfon_subscriber/features/data_usage/data/repository/railwire_data_usage_repository_imp.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';
import 'package:kfon_subscriber/features/home/data/repository/railwire_home_repository_imp.dart';
import 'package:kfon_subscriber/features/invoice_list/data/repository/railwire_invoice_repository_imp.dart';
import 'package:kfon_subscriber/features/profile/data/repository/railwire_profile_repository_imp.dart';
import 'package:kfon_subscriber/features/ticket/data/model/add_note_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/rate_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/data/repository/railwire_ticket_repository_imp.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';
import 'package:kfon_subscriber/features/tranasactions/data/repository/railwire_transaction_repository_imp.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_filter.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// Answers each URL from [responses] and records what was sent.
class _FakeClient extends DioClient {
  final Map<String, Map<String, dynamic>> responses = {};
  final Map<String, List<Map<String, dynamic>>> sent = {};

  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) async {
    (sent[url] ??= []).add(data as Map<String, dynamic>);
    return responses[url] ?? (throw StateError('Unexpected call: $url'));
  }
}

Map<String, dynamic> _ok(Map<String, dynamic> data) => {
  'STATUS': true,
  'data': {'status': true, 'Message': '', ...data},
};

const _denied = {'STATUS': false, 'msg': 'Invalid parameters!'};

T _right<T>(Either<Failure, T> result) =>
    result.fold((l) => fail('Expected Right, got $l'), (r) => r);

const _profile = {
  'subscriberid': '220432',
  'firstname': 'Asha',
  'middlename': null,
  'lastname': 'Nair',
  'mobileno': '8745896569',
  'balance': '12.50',
  'email': 'a@b.c',
  'address': 'Kerala',
  'status_user': 'Active',
  'packagename': '40Mbps',
  'username': 'kl.asha',
  'onlineflag': 'Online',
  'pcontactnumber': '7259102882',
  'pemail': 'p@b.c',
  'paddress': 'Tissur',
  'partnercompanyname': 'Royal_Enfield',
};

Map<String, dynamic> _ticket(String id, String date, String status) => {
  'ticketid': id,
  'submit_date': date,
  'due_date': date,
  'status': status,
  'created_by': 'kl.asha',
  'assignedto': 'support',
  'subject': 'Slow browsing speed ',
  'priority': 'Normal',
  'subscriber': 'kl.asha',
  'partnername': null,
  'feedbackm': '4',
  'feedbackcomment': 'good',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeClient client;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.loadFromString(envString: 'BASE_URL=https://railwire.test/');
    await sl.reset();
    client = _FakeClient();
    sl.registerSingleton<DioClient>(client);
    await PreferenceUtils.setTenant('KL', 'Kerala');
    await PreferenceUtils.setRailwireUser(
      jsonEncode({'username': 'kl.asha', 'subscriberid': '220432'}),
    );
  });

  group('RailwireApi', () {
    const url = 'x';

    test('falls back to the selected state when login sent none', () async {
      client.responses[url] = _ok({});
      await RailwireApi.post(url, (session) => session.byUsername);
      expect(client.sent[url]!.single, {'stcode': 'KL', 'username': 'kl.asha'});
    });

    test('sends the stcode from userlogin as is', () async {
      await PreferenceUtils.setRailwireUser(
        jsonEncode({
          'username': 'ka.user',
          'subscriberid': '1',
          'stcode': 'ka.railwire.co.in',
        }),
      );
      client.responses[url] = _ok({});
      await RailwireApi.post(url, (session) => session.bySubscriberId);
      expect(client.sent[url]!.single, {
        'stcode': 'ka.railwire.co.in',
        'subscriberid': '1',
      });
    });

    test('prefers the state sent at login', () async {
      await PreferenceUtils.setRailwireUser(
        jsonEncode({'username': 'a', 'subscriberid': '1', 'state': 'AP'}),
      );
      client.responses[url] = _ok({});
      await RailwireApi.post(url, (session) => session.bySubscriberId);
      expect(client.sent[url]!.single, {'stcode': 'AP', 'subscriberid': '1'});
    });

    test('STATUS false fails with msg', () async {
      client.responses[url] = _denied;
      final result = await RailwireApi.post(url, (s) => s.byUsername);
      expect(result.fold((l) => l.message, (_) => ''), 'Invalid parameters!');
    });

    test('a false data.status fails with its Message', () async {
      client.responses[url] = {
        'STATUS': true,
        'data': {'status': false, 'Message': 'Nope'},
      };
      final result = await RailwireApi.post(url, (s) => s.byUsername);
      expect(result.fold((l) => l.message, (_) => ''), 'Nope');
    });

    test('fails without a logged-in user and sends nothing', () async {
      await PreferenceUtils.clearAll(true);
      final result = await RailwireApi.post(url, (s) => s.byUsername);
      expect(result.fold((l) => l, (_) => null), isA<AuthFailure>());
      expect(client.sent, isEmpty);
    });

    test('a network error becomes a failure', () async {
      final result = await RailwireApi.post('no-response', (s) => s.byUsername);
      expect(result.isLeft(), isTrue);
    });
  });

  test('home combines the profile and current package', () async {
    final expiry = DateTime.now().add(const Duration(days: 10, hours: 1));
    client.responses['Newsubapp_api/userprofile'] = _ok(_profile);
    client.responses['Newsubapp_api/currentpackage'] = _ok({
      'packageid': '104870',
      'packagename': '40Mbps',
      'expiry': expiry.toIso8601String(),
    });

    final home = _right(await RailwireHomeRepositoryImp().getHomePageData());

    expect(home.firstName, 'Asha');
    expect(home.username, 'kl.asha');
    expect(home.balance, 12.5);
    expect(home.subscriberId, '220432');
    expect(home.packageDetails!.packageId, '104870');
    expect(home.packageDetails!.daysLeft, 10);
    expect(home.packageDetails!.packageInfoEntity.id, '104870');
  });

  test('home fails when the package call fails', () async {
    client.responses['Newsubapp_api/userprofile'] = _ok(_profile);
    client.responses['Newsubapp_api/currentpackage'] = _denied;

    final result = await RailwireHomeRepositoryImp().getHomePageData();

    expect(result.fold((l) => l.message, (_) => ''), 'Invalid parameters!');
  });

  test('an expired package has no days left', () async {
    client.responses['Newsubapp_api/currentpackage'] = _ok({
      'packageid': '1',
      'packagename': 'p',
      'expiry': '2024-06-20 23:59:59',
    });

    final details = _right(
      await RailwirePackageDetailsRepositoryImp().getPackageDetails('ignored'),
    );

    expect(details.daysLeft, 0);
    expect(client.sent['Newsubapp_api/currentpackage']!.single, {
      'stcode': 'KL',
      'subscriberid': '220432',
    });
  });

  test('account information maps userprofile', () async {
    client.responses['Newsubapp_api/userprofile'] = _ok(_profile);

    final info = _right(
      await RailwireProfileRepositoryImp().getAccountInformation(),
    );

    expect(info.personalInfo.subscriberId, 220432);
    expect(info.personalInfo.name, 'Asha Nair');
    expect(info.accountInfo.subscriptionStatus, 'Active');
    expect(info.accountInfo.onlineStatus, 'Online');
    expect(info.lnpInfo.lnpName, 'Royal_Enfield');
  });

  group('invoices', () {
    test('are paged locally and keyed by slno', () async {
      client.responses['Newsubapp_api/invoicelist'] = _ok({
        'invoice_data': [
          for (var i = 0; i < 3; i++)
            {
              'slno': '$i',
              'invoiceno': 'INV$i',
              'grossamount': '23.60',
              'invoicedate': '2024-06-11',
            },
        ],
      });
      final repository = RailwireInvoiceRepositoryImp();

      final first = _right(await repository.getInvoices(page: 0, size: 2));
      final second = _right(await repository.getInvoices(page: 1, size: 2));

      expect(first.invoices.map((e) => e.fileId), ['0', '1']);
      expect(first.invoices.first.amount, 23.6);
      expect(first.isLast, isFalse);
      expect(first.totalPages, 2);
      expect(second.invoices.single.invoiceNo, 'INV2');
      expect(second.isLast, isTrue);
    });

    test('the PDF link is read from its top-level payload', () async {
      client.responses['Newsubapp_api/invoicepdf'] = {
        'STATUS': true,
        'invoicelink': {'status': true, 'invoicelink': 'https://x/1163'},
      };

      final file = _right(
        await RailwireInvoiceRepositoryImp().getFileDownloadUrl('1163'),
      );

      expect(file.url, 'https://x/1163');
      expect(file.fileExtension, 'pdf');
      expect(client.sent['Newsubapp_api/invoicepdf']!.single['slno'], '1163');
    });
  });

  test('transactions are filtered and paged locally', () async {
    client.responses['Newsubapp_api/recharge_history'] = _ok({
      'recharge_details': [
        {
          'order_time': '2024-06-21 11:17:57',
          'amount': '175.82',
          'txnid': 'JU34',
          'status': 'Pending',
          'ordernumber': '110',
          'respmsg': 'ok',
        },
        {'order_time': '2024-05-01 10:00:00', 'status': 'Success'},
      ],
    });

    final page = _right(
      await RailwireTransactionRepositoryImp().getTransactions(
        page: 0,
        size: 10,
        filter: TransactionFilter(
          status: 'PENDING',
          fromDate: DateTime(2024, 6, 21),
          toDate: DateTime(2024, 6, 21),
        ),
      ),
    );

    expect(page.transactions.single.bssNo, '110');
    expect(page.transactions.single.amount, 175.82);
    expect(page.isLast, isTrue);
  });

  test('data usage splits active sessions and converts octets', () async {
    final now = DateTime.now();
    String at(Duration ago) => now.subtract(ago).toIso8601String();
    client.responses['Newsubapp_api/showsession'] = _ok({
      'radData': [
        {
          'callingstationid': ' 14-a7 ',
          'acctstarttime': at(const Duration(hours: 2)),
          'acctstoptime': at(const Duration(hours: 1)),
          'acctinputoctets': '${1024 * 1024 * 1024}',
          'acctoutputoctets': '${2 * 1024 * 1024 * 1024}',
        },
        {
          'acctstarttime': at(const Duration(minutes: 30)),
          'acctstoptime': null,
          'acctinputoctets': '0',
          'acctoutputoctets': '0',
        },
        {
          'acctstarttime': at(const Duration(days: 3)),
          'acctstoptime': at(const Duration(days: 2)),
          'acctinputoctets': '${1024 * 1024 * 1024}',
          'acctoutputoctets': '0',
        },
      ],
    });

    final usage = _right(
      await RailwireDataUsageRepositoryImp().getSubscriberDataUsage(
        const GetSubscriberDataUsageParams(subscriberUuid: 'x', period: 'DAY'),
      ),
    );

    expect(usage.activeSession, isNotNull);
    expect(usage.sessionHistory, hasLength(2));
    expect(usage.sessionHistory.first.networkDetails.mac, '14-a7');
    expect(usage.sessionHistory.first.sessionDuration, '01:00:00');
    expect(usage.dataUsage!.uploadGb, 1);
    expect(usage.dataUsage!.downloadGb, 2);
    expect(usage.dataUsage!.totalGb, 3);
  });

  group('tickets', () {
    final repository = RailwireTicketRepositoryImp();

    void stubLists() {
      client.responses['Newsubapp_api/sub_opentickets'] = _ok({
        'tickets_data': [_ticket('25', '2024-06-26 11:10:12', 'open')],
      });
      client.responses['Newsubapp_api/sub_closedtickets'] = _ok({
        'tickets_data': [_ticket('23', '2024-06-20 11:00:26', 'closed')],
      });
      client.responses['Newsubapp_api/ticket_comments_history'] = _ok({
        'comments_list': [
          {
            'noteid': '9',
            'note': null,
            'created_by': 'kl.asha',
            'create_date': '2024-06-26 11:04:07',
            'status': 'open',
            'attachment': 'https://x/tick.pdf',
          },
          {'noteid': '11', 'note': 'hi', 'attachment': 'https://x/a.JPG'},
        ],
      });
    }

    test('open and closed lists are merged, newest first', () async {
      stubLists();

      final page = _right(
        await repository.getTickets(const GetTicketsListParams()),
      );

      expect(page.tickets.map((e) => e.uuid), ['25', '23']);
      final ticket = page.tickets.first;
      expect(ticket.ticketId, 25);
      expect(ticket.subject!.name, 'Slow browsing speed');
      expect(ticket.rating, 4);
      expect(ticket.movements.first.documentUrl, ['https://x/tick.pdf']);
      expect(ticket.movements.last.imageUrl, ['https://x/a.JPG']);
      expect(page.pageInfo.isLast, isTrue);
    });

    test('a status filter only calls its own list', () async {
      stubLists();

      final page = _right(
        await repository.getTickets(
          const GetTicketsListParams(status: 'CLOSED'),
        ),
      );

      expect(page.tickets.single.uuid, '23');
      expect(client.sent['Newsubapp_api/sub_opentickets'], isNull);
    });

    test('comments are only fetched for the returned page', () async {
      stubLists();

      await repository.getTickets(const GetTicketsListParams(size: 1));

      expect(
        client.sent['Newsubapp_api/ticket_comments_history'],
        hasLength(1),
      );
    });

    test('a failed comment list keeps the ticket', () async {
      stubLists();
      client.responses['Newsubapp_api/ticket_comments_history'] = _denied;

      final page = _right(
        await repository.getTickets(const GetTicketsListParams()),
      );

      expect(page.tickets, hasLength(2));
      expect(page.tickets.first.movements, isEmpty);
    });

    test('a failed list fails the request', () async {
      stubLists();
      client.responses['Newsubapp_api/sub_closedtickets'] = _denied;

      final result = await repository.getTickets(const GetTicketsListParams());

      expect(result.isLeft(), isTrue);
    });

    test('subjects come from imagelogo', () async {
      client.responses['Newsubapp_api/imagelogo'] = _ok({
        'ticket_subject_list': [
          {'slno': '84', 'msg': 'Package Expire '},
        ],
      });

      final subjects = _right(await repository.getSubjects(categoryId: 'x'));

      expect(subjects.single.id, '84');
      expect(subjects.single.name, 'Package Expire');
      expect(client.sent['Newsubapp_api/imagelogo']!.single, {'stcode': 'KL'});
    });

    test('the create page resolves its fixed category and type', () async {
      final categories = _right(await repository.getCategories());
      final types = _right(await repository.getCustomerTypes());

      expect(categories.single.isActive, isTrue);
      expect(types.single.code, 'SUBSCRIBERS');
    });

    SubmitTicketReq ticketRequest() => SubmitTicketReq(
      subjectId: '2',
      subjectCode: '2',
      ticketCategory: 'GENERAL',
      remarks: 'testing',
      customerType: 'SUBSCRIBERS',
      customerId: '',
      customerName: '',
      subjectResolve: '',
      mobileNumber: '',
    );

    test('a new ticket reads its id from the Message', () async {
      client.responses['Newsubapp_api/create_new_ticket'] = {
        'STATUS': true,
        'data': {
          'status': true,
          'Message': 'Ticket Created Successfully! Ticketid=25',
        },
      };

      final created = _right(await repository.submitTicket(ticketRequest()));

      expect(created.ticketUuid, '25');
      expect(client.sent['Newsubapp_api/create_new_ticket']!.single, {
        'stcode': 'KL',
        'username': 'kl.asha',
        'subject': '2',
        'description': 'testing',
        'attachment': '',
        'attachment_name': '',
      });
    });

    test('a comment with files fails instead of dropping them', () async {
      final result = await repository.addNote(
        AddNoteReq(
          ticketUuid: '24',
          remarks: 'x',
          status: 'open',
          visibility: '',
          files: [PlatformFile(name: 'a.pdf', size: 1)],
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(client.sent, isEmpty);
    });

    test('a comment goes to create_new_comment', () async {
      client.responses['Newsubapp_api/create_new_comment'] = _ok({});

      final note = _right(
        await repository.addNote(
          const AddNoteReq(
            ticketUuid: '24',
            remarks: 'testing1',
            status: 'open',
            visibility: '',
          ),
        ),
      );

      expect(note.ticketId, '24');
      expect(
        client.sent['Newsubapp_api/create_new_comment']!.single['description'],
        'testing1',
      );
    });

    test('a rating goes to feedback as text', () async {
      client.responses['Newsubapp_api/feedback'] = _ok({});

      await repository.rateTicket(
        const RateTicketReq(ticketUuid: '22', rating: 4, comment: 'ok'),
      );

      expect(client.sent['Newsubapp_api/feedback']!.single, {
        'stcode': 'KL',
        'username': 'kl.asha',
        'rating': '4',
        'feedback_msg': 'ok',
        'ticketid': '22',
      });
    });
  });

  test('a DioException from the client becomes a failure', () async {
    final failing = _ThrowingClient();
    await sl.unregister<DioClient>();
    sl.registerSingleton<DioClient>(failing);

    final result = await RailwireProfileRepositoryImp().getProfile();

    expect(result.isLeft(), isTrue);
  });
}

class _ThrowingClient extends DioClient {
  @override
  Future<Map<String, dynamic>> postRailwire(
    String url, {
    dynamic data,
    bool sensitive = false,
  }) async => throw DioException(requestOptions: RequestOptions(path: url));
}
