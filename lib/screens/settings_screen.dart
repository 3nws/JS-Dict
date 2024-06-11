import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:jsdict/providers/theme_provider.dart";
import "package:jsdict/singletons.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:provider/provider.dart";

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = getPreferences().getString("syncUrl") ?? "";
    _emailController.text = getPreferences().getString("syncEmail") ?? "";
    _passwordController.text = getPreferences().getString("syncPassword") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (dynamicColorScheme, _) => Scaffold(
              appBar: AppBar(title: const Text("Settings")),
              body: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.water_drop, size: 32.0),
                    title: const Text("Theme"),
                    trailing: Consumer<ThemeProvider>(
                        builder: (context, provider, _) {
                      return DropdownButton(
                        value: provider.currentThemeString,
                        items: ThemeProvider.themes
                            .map((theme) => DropdownMenuItem(
                                value: theme, child: Text(theme)))
                            .toList(),
                        onChanged: (value) => provider.setTheme(value!),
                      );
                    }),
                  ),
                  if (dynamicColorScheme != null)
                    ListTile(
                      leading: const Icon(Icons.format_color_fill, size: 32.0),
                      title: const Text("Dynamic Colors"),
                      trailing: Consumer<ThemeProvider>(
                        builder: (context, provider, _) => Switch(
                          value: provider.dynamicColors,
                          onChanged: provider.setDynamicColors,
                        ),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.history, size: 32.0),
                    title: const Text("Setup History Sync"),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title:
                              const Text("Enter the address of your server:"),
                          content: Wrap(
                            children: [
                              TextField(
                                  controller: _urlController,
                                  decoration: const InputDecoration(
                                      label: Text(
                                          "Post req. path (ex. https://domain.com/api/record)"),
                                      icon: Icon(Icons.computer))),
                              TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                      label: Text("Email (If auth)"),
                                      icon: Icon(Icons.email))),
                              TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      label: Text("Password (If auth)"),
                                      icon: Icon(Icons.password))),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () {
                                getPreferences()
                                    .setString("syncUrl", _urlController.text);
                                getPreferences().setString(
                                    "syncEmail", _emailController.text);
                                getPreferences().setString(
                                    "syncPassword", _passwordController.text);
                                Navigator.of(context).pop();
                              },
                              child: const Text("SAVE"),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    onTap: () async {
                      final packageInfo = await PackageInfo.fromPlatform();

                      if (context.mounted) {
                        showAboutDialog(
                          context: context,
                          applicationVersion: packageInfo.version,
                          applicationLegalese: "Licensed under GPLv3.",
                        );
                      }
                    },
                    leading: const Icon(Icons.info, size: 32.0),
                    title: const Text("About"),
                  ),
                ],
              ),
            ));
  }
}
