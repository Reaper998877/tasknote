import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Service/authentication.dart';
import 'package:tasknote/Service/shared_pref.dart';
import 'package:tasknote/View/General_Views/splash.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool loggedIn = false;
  int totalNotes = 0;
  int totalGroups = 0;
  String email = "";

  @override
  void initState() {
    super.initState();
    checkUser();
    getTotalCount();
  }

  Future<void> checkUser() async {
    bool isConnected = await CommonFunctions.checkInternet();
    if (isConnected) {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          loggedIn = true;
          email = user!.email.toString();
        });
        await SharedPrefService.saveLoginInfo(loggedIn, user!.email.toString());
      }
    } else {
      Map<String, dynamic> info = await SharedPrefService.getLoginInfo();

      setState(() {
        loggedIn = info["status"];
        email = info["email"];
      });
    }
  }

  void getTotalCount() async {
    totalGroups = await groupController.getTotalGroupCount();
    totalNotes = await noteController.getTotalNoteCount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTheme(
        data: theme,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 4),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: isDark ? AppColors.lThirdColor : AppColors.dFirstColor,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  height: CommonFunctions.getHeight(context, 0.1),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      loggedIn ? "Email: $email" : 'Guest',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  CMenuItem(
                    context: context,
                    icon: Icons.notes,
                    title: "Total Notes",
                    tWidget: Text(
                      totalNotes.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                  CDivider(theme: theme),
                  CMenuItem(
                    context: context,
                    icon: Icons.folder,
                    title: "Total Folders",
                    tWidget: Text(
                      totalGroups.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                  CDivider(theme: theme),
                  if (loggedIn)
                    CMenuItem(
                      context: context,
                      icon: Icons.backup_rounded,
                      title: "Backup",
                      onTap: () async {
                        // 1. Connectivity Check and user check
                        bool isConnected =
                            await CommonFunctions.checkInternet();
                        if (!isConnected) {
                          scaffoldMessenger(context, "No internet connection");
                          return;
                        }

                        await checkUser();

                        if (user == null) {
                          scaffoldMessenger(context, "User not found");
                          return;
                        }

                        // 2. Show the Loading Dialog
                        // We don't 'await' this because we want the code below it to run immediately
                        showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return BackupOrLogOut(isBackUp: true);
                          },
                        );

                        // 3. Perform the Upload
                        // Groups upload
                        bool groupsUploaded = await groupController
                            .uploadGroupsToFirebase(userId: user!.uid);

                        // Notes upload
                        bool notesUploaded = await noteController
                            .uploadNotesToFirebase(userId: user!.uid);

                        // 4. Close the Loading Dialog
                        if (context.mounted) Navigator.pop(context);

                        // 5. Show Success Message
                        if (groupsUploaded && notesUploaded) {
                          scaffoldMessenger(context, "Backup Completed");
                        } else {
                          scaffoldMessenger(context, "Failed to backup");
                        }
                      },
                    ),
                  if (loggedIn) CDivider(theme: theme),
                  CMenuItem(
                    context: context,
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    title: "Dark Mode",
                    tWidget: Switch.adaptive(
                      splashRadius: 5.0,
                      inactiveTrackColor: AppColors.lThirdColor,
                      inactiveThumbColor: Colors.white,
                      value: isDark,
                      onChanged: (value) {
                        CommonFunctions.toggleTheme();
                      },
                    ),
                  ),
                  CDivider(theme: theme),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                child: loggedIn
                    ? TextButton.icon(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return BackupOrLogOut(
                                isBackUp: false,
                                yesAction: () async {
                                  bool isConnected =
                                      await CommonFunctions.checkInternet();
                                  // Check if the widget is still active
                                  if (!context.mounted) return;

                                  if (!isConnected) {
                                    scaffoldMessenger(
                                      context,
                                      "No internet connection",
                                    );
                                    Navigator.pop(context);
                                    return;
                                  }

                                  Authentication auth = Authentication(
                                    context: context,
                                  );
                                  await auth.logOutuser();

                                  // CRITICAL CHECK: The logout likely triggered a navigation or state change
                                  if (!context.mounted) return;

                                  setState(() {
                                    loggedIn = false;
                                  });

                                  scaffoldMessenger(context, "Logged Out");
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        label: Text("Log Out"),
                        icon: Icon(Icons.logout_rounded),
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          // When you navigate to the "new" screen, you can await the result.
                          // The code execution pauses and resumes exactly when that screen is popped.
                          final result = await Navigator.pushNamed(
                            context,
                            '/auth',
                          );

                          // 1. Connectivity Check and user check
                          bool isConnected =
                              await CommonFunctions.checkInternet();

                          if (!context.mounted) return;

                          if (!isConnected) {
                            scaffoldMessenger(
                              context,
                              "No internet connection",
                            );
                            return;
                          }

                          await checkUser();
                          if (!context.mounted) return;

                          if (user == null) {
                            // scaffoldMessenger(context, "User not found");
                            return;
                          }

                          // If user Sign up then return, because he has no data to download.
                          if (result == "signup") return;

                          // 2. Show the Download Dialog
                          showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return DownloadDialog();
                            },
                          );

                          // 3. Perform the Download
                          // Groups download and store
                          bool groupsFetched = await groupController
                              .fetchAndSyncGroups(userId: user!.uid);

                          // Notes download and store
                          bool notesFetched = await noteController
                              .fetchAndSyncNotes(userId: user!.uid);

                          // 4. Close the Download Dialog
                          if (context.mounted) Navigator.pop(context);

                          // 5. Show Success Message
                          if (notesFetched && groupsFetched) {
                            scaffoldMessenger(context, "Download Completed");
                            getTotalCount();
                          } else {
                            scaffoldMessenger(context, "Failed to download");
                          }
                        },
                        label: Text("Log In"),
                        icon: Icon(Icons.login),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
