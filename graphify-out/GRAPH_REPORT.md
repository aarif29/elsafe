# Graph Report - D:/Kuliah/BINUS/APLIKASI/elsafe  (2026-05-05)

## Corpus Check
- 127 files · ~51,744 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 636 nodes · 715 edges · 49 communities (41 shown, 8 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_UI Components|UI Components]]
- [[_COMMUNITY_Auth Services|Auth Services]]
- [[_COMMUNITY_Edit Temuan|Edit Temuan]]
- [[_COMMUNITY_Create Temuan|Create Temuan]]
- [[_COMMUNITY_Navigation UI|Navigation UI]]
- [[_COMMUNITY_Maps Integration|Maps Integration]]
- [[_COMMUNITY_Daftar Temuan|Daftar Temuan]]
- [[_COMMUNITY_App Shell|App Shell]]
- [[_COMMUNITY_Windows Runner|Windows Runner]]
- [[_COMMUNITY_Profile ULP|Profile ULP]]
- [[_COMMUNITY_Media Tests|Media Tests]]
- [[_COMMUNITY_App Entry|App Entry]]
- [[_COMMUNITY_UI Utilities|UI Utilities]]
- [[_COMMUNITY_Data Types|Data Types]]
- [[_COMMUNITY_Theme Config|Theme Config]]
- [[_COMMUNITY_Models|Models]]
- [[_COMMUNITY_Dashboard|Dashboard]]
- [[_COMMUNITY_Admin Approval|Admin Approval]]
- [[_COMMUNITY_Registration|Registration]]
- [[_COMMUNITY_Linux Runner|Linux Runner]]
- [[_COMMUNITY_Brand Assets|Brand Assets]]
- [[_COMMUNITY_iOS Platform|iOS Platform]]
- [[_COMMUNITY_Temuan Types|Temuan Types]]
- [[_COMMUNITY_Welcome Card|Welcome Card]]
- [[_COMMUNITY_macOS Runner|macOS Runner]]
- [[_COMMUNITY_Windows Main|Windows Main]]
- [[_COMMUNITY_Project Config|Project Config]]
- [[_COMMUNITY_Brand Identity|Brand Identity]]
- [[_COMMUNITY_iOS Tests|iOS Tests]]
- [[_COMMUNITY_Android Plugins|Android Plugins]]
- [[_COMMUNITY_iOS Plugins|iOS Plugins]]
- [[_COMMUNITY_Android Activity|Android Activity]]
- [[_COMMUNITY_Sosialisasi Model|Sosialisasi Model]]
- [[_COMMUNITY_Temuan Model|Temuan Model]]
- [[_COMMUNITY_Temuan Lifecycle|Temuan Lifecycle]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 31 edges
2. `../../config/app_theme.dart` - 14 edges
3. `package:supabase_flutter/supabase_flutter.dart` - 10 edges
4. `../../config/temuan_service.dart` - 8 edges
5. `../../config/temuan_model.dart` - 8 edges
6. `package:flutter/foundation.dart` - 7 edges
7. `../../config/ulp_service.dart` - 7 edges
8. `../../config/temuan_types.dart` - 7 edges
9. `AppDelegate` - 6 edges
10. `Create()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Android App Icon Set` --semantically_similar_to--> `elsafe App Identity`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → pubspec.yaml
- `Android App Icon Set` --conceptually_related_to--> `Flutter Project Configuration`  [INFERRED]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → pubspec.yaml
- `Flutter Dashboard UI` --conceptually_related_to--> `elsafe App Identity`  [INFERRED]
  flutter_01.png → pubspec.yaml
- `iOS App Icons Set` --semantically_similar_to--> `Multi-Platform Icon Assets`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png → android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
- `Flutter App Screenshot` --semantically_similar_to--> `App Branding Assets`  [INFERRED] [semantically similar]
  flutter_01.png → assets/logo_google.png

## Hyperedges (group relationships)
- **Mobile App Icon Assets** — android_app_icons, ios_app_icons_set, ios_app_icon_20, ios_app_icon_40, ios_app_icon_60, ios_app_icon_76, ios_app_icons_1024 [EXTRACTED 1.00]
- **elsafe Brand Visual Identity** — elsafe_brand, shield_logo, ios_app_icons, macos_app_icons, ios_launch_images, web_favicon_and_icons [EXTRACTED 1.00]

## Communities (49 total, 8 thin omitted)

### Community 0 - "UI Components"
Cohesion: 0.05
Nodes (36): ../../config/app_theme.dart, ../../config/temuan_model.dart, build, Column, InkWell, Scaffold, SettingsScreen, SizedBox (+28 more)

### Community 1 - "Auth Services"
Cohesion: 0.05
Nodes (34): app_logger.dart, ../config/app_logger.dart, ../config/lupa_password.dart, DefaultFirebaseOptions, NotificationService, refreshUnreadCount, reset, _subscribeRealtime (+26 more)

### Community 2 - "Edit Temuan"
Cohesion: 0.05
Nodes (38): LocationService, build, _buildDatePicker, _buildPenyulangSection, _buildStep1Temuan, _buildStep2Reminder, _buildStep3Closing, _buildStep4Sosialisasi (+30 more)

### Community 3 - "Create Temuan"
Cohesion: 0.05
Nodes (36): build, _buildDatePicker, _buildMiniMapPreview, _buildPenyulangSection, _buildStep1Temuan, _buildStep2Reminder, _buildStep3Closing, _buildStep4Sosialisasi (+28 more)

### Community 4 - "Navigation UI"
Cohesion: 0.06
Nodes (34): ../../config/notification_service.dart, build, _buildEmpty, Center, dispose, _formatDate, _iconBgColor, _iconColor (+26 more)

### Community 5 - "Maps Integration"
Cohesion: 0.06
Nodes (32): ../config/location_service.dart, build, _buildMap, Container, _createMarkers, DropdownMenuItem, Exception, _fitAllMarkers (+24 more)

### Community 6 - "Daftar Temuan"
Cohesion: 0.06
Nodes (31): AnimatedBuilder, build, _buildBody, _buildFilterDropdown, _buildSearchAndFilter, Card, Center, Column (+23 more)

### Community 7 - "App Shell"
Cohesion: 0.06
Nodes (30): backToDashboard, BottomNavigationBar, BottomNavigationBarItem, build, _buildBottomNav, _buildFab, _buildNotifIcon, closePanduan (+22 more)

### Community 8 - "Windows Runner"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 9 - "Profile ULP"
Cohesion: 0.07
Nodes (26): ../config/snackbar.dart, ../config/ulp_list.dart, ../../config/ulp_service.dart, build, _buildTextField, _buildUlpRow, Column, Container (+18 more)

### Community 10 - "Media Tests"
Cohesion: 0.07
Nodes (24): build, _buildNewFileItem, Column, FotoPickerWidget, _FotoPickerWidgetState, Function, initState, Padding (+16 more)

### Community 11 - "App Entry"
Cohesion: 0.08
Nodes (24): config/new_password.dart, config/supabase_config.dart, build, dispose, initState, main, MaterialApp, MyApp (+16 more)

### Community 12 - "UI Utilities"
Cohesion: 0.08
Nodes (21): clearAll, hide, _showAnimatedSnackBar, showCustom, showError, showInfo, showLoading, showSimple (+13 more)

### Community 13 - "Data Types"
Cohesion: 0.09
Nodes (20): ../../config/temuan_types.dart, build, _buildDropdown, Column, Function, initState, _levelColor, MatriksRisikoWidget (+12 more)

### Community 14 - "Theme Config"
Cohesion: 0.1
Nodes (19): dark, light, ThemeService, build, CircularProgressIndicator, dispose, ElsafeApp, ElsafeSplashScreen (+11 more)

### Community 15 - "Models"
Cohesion: 0.1
Nodes (19): ../../config/sosialisasi_model.dart, build, Center, Container, Dialog, _formatDate, Function, Icon (+11 more)

### Community 16 - "Dashboard"
Cohesion: 0.12
Nodes (15): ../../config/temuan_service.dart, build, DashboardInfoSection, DashboardScreen, DashboardScreenState, IconButton, initState, loadData (+7 more)

### Community 17 - "Admin Approval"
Cohesion: 0.13
Nodes (14): AdminApprovalScreen, _AdminApprovalScreenState, build, _buildEmpty, Center, Container, Divider, Icon (+6 more)

### Community 18 - "Registration"
Cohesion: 0.15
Nodes (12): AuthException, build, _buildInputField, _buildRegisterButton, Container, dispose, Function, RegisterPage (+4 more)

### Community 19 - "Linux Runner"
Cohesion: 0.15
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 20 - "Brand Assets"
Cohesion: 0.17
Nodes (12): Android App Icons, App Branding Assets, Google Auth Integration, Flutter App Screenshot, Google Logo Brand, iOS App Icon 20px, iOS App Icon 40px, iOS App Icon 60px (+4 more)

### Community 22 - "Temuan Types"
Cohesion: 0.29
Nodes (6): hitungSkor, label, MatriksRisiko, Penyulang, skorDariNilai, TipeTemuan

### Community 23 - "Welcome Card"
Cohesion: 0.29
Nodes (6): build, Container, DashboardWelcomeCard, SizedBox, Text, TextStyle

### Community 24 - "macOS Runner"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 25 - "Windows Main"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 26 - "Project Config"
Cohesion: 0.4
Nodes (6): Android App Icon Set, Flutter Dependencies, Flutter Dev Dependencies, elsafe App Identity, Flutter Dashboard UI, Flutter Project Configuration

### Community 27 - "Brand Identity"
Cohesion: 0.53
Nodes (6): elsafe Brand Identity, iOS App Icons, iOS Launch Screens, macOS App Icons, Shield Logo Design, Web Favicon and Icons

## Knowledge Gaps
- **465 isolated node(s):** `MainActivity`, `-registerWithRegistry`, `MyApp`, `_MyAppState`, `main` (+460 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `UI Components` to `Auth Services`, `Edit Temuan`, `Create Temuan`, `Navigation UI`, `Maps Integration`, `Daftar Temuan`, `App Shell`, `Profile ULP`, `Media Tests`, `App Entry`, `UI Utilities`, `Data Types`, `Theme Config`, `Models`, `Dashboard`, `Admin Approval`, `Registration`, `Welcome Card`?**
  _High betweenness centrality (0.385) - this node is a cross-community bridge._
- **Why does `package:supabase_flutter/supabase_flutter.dart` connect `Auth Services` to `App Shell`, `Profile ULP`, `App Entry`, `Dashboard`, `Registration`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `../../config/app_theme.dart` connect `UI Components` to `Navigation UI`, `Daftar Temuan`, `Profile ULP`, `App Entry`, `Models`, `Dashboard`, `Admin Approval`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **What connects `MainActivity`, `-registerWithRegistry`, `MyApp` to the rest of the system?**
  _465 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `UI Components` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Auth Services` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Edit Temuan` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._