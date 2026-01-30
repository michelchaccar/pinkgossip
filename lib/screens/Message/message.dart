// ignore_for_file: unused_field, deprecated_member_use, avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/screens/Message/messagedetail.dart';
import 'package:pinkGossip/screens/HomeScreens/notifications.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/imagesutils.dart';
import 'package:pinkGossip/utils/pallete.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String firebaseId = "";
  bool isLoading = true;

  List<Map> usersList = [];
  List<Map> filteredUsersList = [];
  List<Map> userunreadCountlist = [];

  final TextEditingController searchcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getchannellist();
  }

  // 🔥 SAME LOGIC – FAST EXECUTION
  Future<void> getchannellist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firebaseId = prefs.getString('FirebaseId') ?? "";

    setState(() => isLoading = true);

    usersList.clear();
    filteredUsersList.clear();
    userunreadCountlist.clear();

    DatabaseReference ref = FirebaseDatabase.instance.ref('message');
    final snapshot = await ref.once();
    if (snapshot.snapshot.value == null) {
      setState(() => isLoading = false);
      return;
    }

    Map<dynamic, dynamic> allChanels =
        snapshot.snapshot.value as Map<dynamic, dynamic>;

    List<Map> shortedchannels = [];

    allChanels.forEach((key, value) {
      List<String> parts = key.split('--');
      if (!parts.contains(firebaseId.replaceFirst('-', ''))) return;

      Map<dynamic, dynamic> messages = value;
      int maxTimestamp = 0;
      Map? lastMessage;

      int unreadCount =
          messages.values.where((m) {
            return firebaseId.contains(m['idTo']) && !(m['isSeen'] ?? false);
          }).length;

      for (var msg in messages.values) {
        int ts = msg['timestamp'];
        if (ts > maxTimestamp) {
          maxTimestamp = ts;
          lastMessage = msg;
        }
      }

      if (lastMessage != null) {
        shortedchannels.add({
          'key': key,
          'lastmessagetime': lastMessage['timestamp'],
          'content': lastMessage['content'],
          'type': lastMessage['type'],
          'unreadCount': unreadCount,
        });
      }
    });

    shortedchannels.sort(
      (a, b) =>
          (b['lastmessagetime'] as int).compareTo(a['lastmessagetime'] as int),
    );

    for (var element in shortedchannels) {
      List<String> parts = element['key'].split('--');
      int pos = parts.indexOf(firebaseId.replaceFirst('-', ''));
      String otherId = pos == 1 ? parts[2] : parts[1];

      DatabaseReference userRef = FirebaseDatabase.instance.ref(
        'users/-$otherId',
      );
      final userSnap = await userRef.once();
      if (userSnap.snapshot.value == null) continue;

      Map userData = Map.from(userSnap.snapshot.value as Map);
      userData['lastmessagetime'] = element['lastmessagetime'];
      userData['content'] = element['content'];
      userData['type'] = element['type'];

      usersList.add(userData);
      userunreadCountlist.add({
        'userid': userData['id'],
        'unreadCount': element['unreadCount'],
      });
    }

    setState(() {
      filteredUsersList = usersList;
      isLoading = false;
    });
  }

  void filterUsersList(String query) {
    if (query.isEmpty) {
      setState(() => filteredUsersList = usersList);
      return;
    }

    setState(() {
      filteredUsersList =
          usersList
              .where(
                (u) =>
                    u['nickname'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size kSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.kAppBArBGColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 50, child: Image.asset(ImageUtils.appbarlogo)),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
              child: SizedBox(
                width: 25,
                height: 25,
                child: Image.asset(ImageUtils.notificationimg),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchcontroller,
              onChanged: filterUsersList,
              decoration: InputDecoration(
                hintText: Languages.of(context)!.searchText,
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsersList.isEmpty
                    ? Center(child: Text(Languages.of(context)!.NochathereText))
                    : ListView.builder(
                      itemCount: filteredUsersList.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsersList[index];
                        final unread =
                            userunreadCountlist[index]['unreadCount'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                user['photoUrl'] != ""
                                    ? NetworkImage(
                                      "${API.baseUrl}/api/${user['photoUrl']}",
                                    )
                                    : null,
                            child:
                                user['photoUrl'] == ""
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                          title: Text(user['nickname']),
                          subtitle: Text(
                            user['type'] == 0
                                ? user['content']
                                : Languages.of(context)!.sharedapostText,
                            maxLines: 1,
                          ),
                          trailing:
                              unread > 0
                                  ? CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      unread.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )
                                  : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MessageDetail(
                                      oppId: user['id'],
                                      firebaseUId: firebaseId,
                                      name: user['nickname'],
                                      userImg: user['photoUrl'],
                                      type: "frommessage",
                                    ),
                              ),
                            ).then((_) => getchannellist());
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
