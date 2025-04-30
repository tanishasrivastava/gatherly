import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupCode;
  final String myId;
  final List<dynamic> members;
  final String myName;

  GroupChatScreen({
    required this.groupCode,
    required this.myId,
    required this.members,
    required this.myName,
  });

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<dynamic> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isLoading = false;
  bool isTyping = false;
  String myName = 'User';

  @override
  void initState() {
    super.initState();
    fetchMessages();
    loadMyName();
  }

  Future<void> loadMyName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> fetchMessages() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'http://10.0.2.2:8081/api/chat/group?groupCode=${widget.groupCode}'));

    if (response.statusCode == 200) {
      setState(() {
        messages = jsonDecode(response.body);
        isLoading = false;
      });

      await http.post(
        Uri.parse('http://10.0.2.2:8081/api/chat/mark-seen?groupCode=${widget.groupCode}&userId=${widget.myId}'),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load messages');
    }
  }

  Future<void> sendMessage({String? text, String? imageUrl}) async {
    if ((text == null || text.isEmpty) && imageUrl == null) return;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8081/api/chat/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupCode': widget.groupCode,
        'senderId': widget.myId,
        'senderName': myName,
        'receiverId': null,
        'message': text ?? '',
        'imageUrl': imageUrl,
        'isGroupChat': true,
        'members': widget.members,
      }),
    );

    if (response.statusCode == 200) {
      fetchMessages();
      messageController.clear();
    } else {
      print('Failed to send message');
    }
  }

  Future<void> pickImageAndSend() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8081/api/upload/image'),
      );
      request.files.add(
          await http.MultipartFile.fromPath('image', pickedFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        String imageUrl = res.body.replaceAll('"', '');
        await sendMessage(imageUrl: imageUrl);
      } else {
        print('Failed to upload image');
      }
    }
  }

  Future<void> deleteAllMessages() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Delete All Chats?'),
            content: Text('Are you sure you want to delete all chats in this group?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete All'),
              ),
            ],
          ),
    );

    if (confirm) {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8081/api/chat/delete-all?groupCode=${widget.groupCode}'),
      );

      if (response.statusCode == 200) {
        print('All messages deleted');
        fetchMessages();
      } else {
        print('Failed to delete all messages');
      }
    }
  }

  Future<void> deleteSingleMessage(String messageId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Delete Message?'),
            content: Text('Are you sure you want to delete this message?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm) {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8081/api/chat/delete/$messageId'),
      );

      if (response.statusCode == 200) {
        print('Message deleted');
        fetchMessages();
      } else {
        print('Failed to delete message');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Future feature
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete All') {
                deleteAllMessages();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Delete All',
                child: Text('Delete All Chats'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "You are typing...",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMine = msg['senderId'] == widget.myId;

                return ListTile(
                  title: Align(
                    alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMine
                            ? Colors.deepPurple.shade100
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg['imageUrl'] != null && msg['imageUrl'] != '')
                            Image.network(
                              msg['imageUrl'],
                              height: 150,
                            ),
                          if (msg['message'] != null && msg['message'] != '')
                            Text(
                              msg['message'],
                              style: TextStyle(fontSize: 16),
                            ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                "- ${msg['senderName']}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              Spacer(),
                              if (msg['seen'])
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green,
                                )
                              else
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  onLongPress: () {
                    deleteSingleMessage(msg['id']);
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: pickImageAndSend,
              ),
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  onChanged: (text) {
                    setState(() {
                      isTyping = text.isNotEmpty;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => sendMessage(text: messageController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
