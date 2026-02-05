import 'package:pinkGossip/localization/language/languages.dart';
import 'package:pinkGossip/utils/color_utils.dart';
import 'package:pinkGossip/utils/custom.dart';
import 'package:pinkGossip/utils/pallete.dart';
import 'package:flutter/material.dart';
import 'package:pinkGossip/models/salonsearchlistmodel.dart';

class MentionTextField extends StatefulWidget {
  final List<UserList> userList;
  final Function(String) onChanged;
  final Function(List<String>) onTaggedUserIdsChanged;
  String? storedata, type;
  MentionTextField({
    Key? key,
    required this.userList,
    required this.onChanged,
    this.storedata,
    required this.onTaggedUserIdsChanged,
    required this.type,
  }) : super(key: key);

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  final TextEditingController captionController = TextEditingController();
  List<UserList> filteredUserList = [];
  bool isTagUserShow = false;

  void insertTag(UserList user) {
    String currentText = captionController.text;
    int lastAtIndex = currentText.lastIndexOf("@");

    if (lastAtIndex != -1) {
      // Replace the text from @ to cursor position with the username
      String beforeAt = currentText.substring(0, lastAtIndex);
      String afterAt = currentText.substring(
        captionController.selection.base.offset,
      );

      // Create the new text with the tagged user
      String newText = '$beforeAt@${user.userName} $afterAt';

      // Update the TextField text and set cursor position
      captionController.text = newText;
      captionController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: beforeAt.length + user.userName!.length + 2,
        ), // +2 for '@ ' (the space after the username)
      );
    } else {
      // If there's no '@', just add the username
      String newText = currentText + '@${user.userName} ';
      captionController.text = newText;
      captionController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }

    // Call onChanged callback to update tagged user IDs
    widget.onTaggedUserIdsChanged(getTaggedUserIds());

    // Hide user suggestions
    setState(() {
      isTagUserShow = false;
    });
    widget.onChanged(captionController.text);
  }

  void _onTextChanged(String value) {
    final taggedUserIds = getTaggedUserIds();
    print("taggedUserIds =${taggedUserIds}");

    widget.onTaggedUserIdsChanged(taggedUserIds);

    int lastAtIndex = value.lastIndexOf('@');
    int cursorPosition = captionController.selection.base.offset;

    if (lastAtIndex != -1 && cursorPosition > lastAtIndex) {
      String searchText =
          value.substring(lastAtIndex + 1, cursorPosition).toLowerCase();

      setState(() {
        if (searchText.isEmpty) {
          filteredUserList = widget.userList;
          isTagUserShow = true;
        } else {
          filteredUserList =
              widget.userList.where((user) {
                if (user.userName == null) return false;

                return user.userName!.toLowerCase().contains(searchText) ||
                    (user.firstName != null &&
                        user.firstName!.toLowerCase().contains(searchText)) ||
                    (user.lastName != null &&
                        user.lastName!.toLowerCase().contains(searchText));
              }).toList();

          isTagUserShow = filteredUserList.isNotEmpty;
        }
      });
    } else {
      setState(() {
        isTagUserShow = false;
      });
    }

    widget.onChanged(value);
  }

  List<String> getTaggedUserIds() {
    final mentionedUsernames = <String>[];
    final parts = captionController.text.split(" ");
    for (var part in parts) {
      if (part.startsWith("@")) {
        mentionedUsernames.add(part.substring(1));
      }
    }

    final taggedUserIds =
        widget.userList
            .where((user) => mentionedUsernames.contains(user.userName))
            .map((user) => user.id.toString())
            .toList();
    return taggedUserIds;
  }

  @override
  void initState() {
    super.initState();
    captionController.text = widget.storedata!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                widget.type == "PostReview"
                    ? const EdgeInsetsDirectional.all(0)
                    : const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: captionController,
              maxLines: null,
              maxLength: 500,

              style: Pallete.Quicksand15darkgreye500.copyWith(
                color: AppColors.kBlackColor,
              ),
              onChanged: _onTextChanged,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                counterText: "",
                enabledBorder:
                    widget.type == "PostReview" ||
                            widget.type == "PostReviewTyp2"
                        ? InputBorder.none
                        : const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                disabledBorder:
                    widget.type == "PostReview" ||
                            widget.type == "PostReviewTyp2"
                        ? InputBorder.none
                        : const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.btnColor),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                border:
                    widget.type == "PostReview" ||
                            widget.type == "PostReviewTyp2"
                        ? InputBorder.none
                        : const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.btnColor),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                focusedBorder:
                    widget.type == "PostReview" ||
                            widget.type == "PostReviewTyp2"
                        ? InputBorder.none
                        : const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.kPinkColor),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                hintText:
                    widget.type == "PostReview"
                        ? Languages.of(context)!.WritereviewaboutthesalonText
                        : widget.type == "PostReviewTyp2"
                        ? Languages.of(context)!.captionText
                        : Languages.of(context)!.captionText,
                hintStyle: Pallete.Quicksand15darkgreye500.copyWith(
                  color: AppColors.kBlackColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isTagUserShow)
            ListView.builder(
              itemCount: filteredUserList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final user = filteredUserList[index];
                return ListTile(
                  onTap: () => insertTag(user),
                  leading:
                      user.profileImage != null && user.profileImage!.isNotEmpty
                          ? Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "${API.baseUrl}/api/${user.profileImage!}",
                                ),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          )
                          : Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Icon(Icons.person)),
                          ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName ?? '',
                        style: Pallete.Quicksand14Whiitewe600.copyWith(
                          color: AppColors.kBlackColor,
                        ),
                      ),
                      Text(
                        "${user.firstName ?? ''}${user.lastName ?? ''}",
                        style: Pallete.Quicksand14Whiitewe500.copyWith(
                          color: AppColors.kBlackColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
