# Graph Report - elsafe  (2026-05-08)

## Corpus Check
- 83 files · ~77,000 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 724 nodes · 823 edges · 52 communities (44 shown, 8 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5c7225d0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 32 edges
2. `../../config/app_theme.dart` - 16 edges
3. `package:supabase_flutter/supabase_flutter.dart` - 11 edges
4. `../../config/temuan_model.dart` - 11 edges
5. `../../config/ulp_service.dart` - 10 edges
6. `../../config/temuan_service.dart` - 9 edges
7. `../../config/temuan_types.dart` - 8 edges
8. `package:flutter/foundation.dart` - 7 edges
9. `package:flutter/services.dart` - 7 edges
10. `AppDelegate` - 6 edges

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

## Communities (52 total, 8 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (43): ../../config/temuan_types.dart, build, Container, SizedBox, TemuanListItem, build, Container, DashboardWelcomeCard (+35 more)

### Community 1 - "Community 1"
Cohesion: 0.04
Nodes (46): _applyFilters, BoxDecoration, build, _buildActionButtons, _buildAdvancedFilters, _buildDateButton, _buildDateField, _buildDropdownField (+38 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (40): ../../config/sosialisasi_model.dart, ../../config/temuan_model.dart, ../../config/temuan_service.dart, build, _buildExportQuickAction, DashboardInfoSection, DashboardScreen, DashboardScreenState (+32 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (38): LocationService, build, _buildDatePicker, _buildPenyulangSection, _buildStep1Temuan, _buildStep2Reminder, _buildStep3Closing, _buildStep4Sosialisasi (+30 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (36): ../../config/notification_service.dart, build, _buildEmpty, Center, dispose, _formatDate, _iconBgColor, _iconColor (+28 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (36): build, _buildDatePicker, _buildMiniMapPreview, _buildPenyulangSection, _buildStep1Temuan, _buildStep2Reminder, _buildStep3Closing, _buildStep4Sosialisasi (+28 more)

### Community 6 - "Community 6"
Cohesion: 0.06
Nodes (32): dark, light, ThemeService, build, CircularProgressIndicator, dispose, ElsafeApp, ElsafeSplashScreen (+24 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (32): ../config/location_service.dart, build, _buildMap, Container, _createMarkers, DropdownMenuItem, Exception, _fitAllMarkers (+24 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (32): backToDashboard, BottomNavigationBar, BottomNavigationBarItem, build, _buildBottomNav, _buildFab, _buildNotifIcon, closePanduan (+24 more)

### Community 9 - "Community 9"
Cohesion: 0.06
Nodes (30): AnimatedBuilder, build, _buildBody, _buildFilterDropdown, _buildSearchAndFilter, Card, Center, Column (+22 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (27): ../../config/app_theme.dart, build, Column, InkWell, Scaffold, SettingsScreen, SizedBox, _ThemeOption (+19 more)

### Community 11 - "Community 11"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 12 - "Community 12"
Cohesion: 0.07
Nodes (26): ../config/snackbar.dart, ../config/ulp_list.dart, ../../config/ulp_service.dart, build, _buildTextField, _buildUlpRow, Column, Container (+18 more)

### Community 13 - "Community 13"
Cohesion: 0.08
Nodes (24): config/new_password.dart, config/supabase_config.dart, build, dispose, initState, main, MaterialApp, MyApp (+16 more)

### Community 14 - "Community 14"
Cohesion: 0.09
Nodes (19): main, main, _temuan, TemuanModel, main, ByteData, main, main (+11 more)

### Community 15 - "Community 15"
Cohesion: 0.11
Nodes (18): build, _buildNewFileItem, Column, FotoPickerWidget, _FotoPickerWidgetState, Function, initState, Padding (+10 more)

### Community 16 - "Community 16"
Cohesion: 0.13
Nodes (14): AdminApprovalScreen, _AdminApprovalScreenState, build, _buildEmpty, Center, Container, Divider, Icon (+6 more)

### Community 17 - "Community 17"
Cohesion: 0.14
Nodes (13): ../config/app_logger.dart, ../config/lupa_password.dart, build, LoginPage, _LoginPageState, Scaffold, SingleChildScrollView, SizedBox (+5 more)

### Community 18 - "Community 18"
Cohesion: 0.15
Nodes (12): AuthException, build, _buildInputField, _buildRegisterButton, Container, dispose, Function, RegisterPage (+4 more)

### Community 19 - "Community 19"
Cohesion: 0.15
Nodes (12): clearAll, hide, _showAnimatedSnackBar, showCustom, showError, showInfo, showLoading, showSimple (+4 more)

### Community 20 - "Community 20"
Cohesion: 0.15
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 21 - "Community 21"
Cohesion: 0.17
Nodes (12): Android App Icons, App Branding Assets, Google Auth Integration, Flutter App Screenshot, Google Logo Brand, iOS App Icon 20px, iOS App Icon 40px, iOS App Icon 60px (+4 more)

### Community 22 - "Community 22"
Cohesion: 0.2
Nodes (8): app_logger.dart, NotificationService, refreshUnreadCount, reset, _subscribeRealtime, SupabaseConfig, UlpService, package:supabase_flutter/supabase_flutter.dart

### Community 23 - "Community 23"
Cohesion: 0.18
Nodes (10): deleteFoto, deleteFotos, Exception, _getContentType, _isAdminProfile, TemuanService, package:file_picker/file_picker.dart, sosialisasi_model.dart (+2 more)

### Community 25 - "Community 25"
Cohesion: 0.29
Nodes (6): hitungSkor, label, MatriksRisiko, Penyulang, skorDariNilai, TipeTemuan

### Community 26 - "Community 26"
Cohesion: 0.33
Nodes (4): DefaultFirebaseOptions, package:firebase_core/firebase_core.dart, package:flutter/foundation.dart, package:logger/logger.dart

### Community 27 - "Community 27"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 28 - "Community 28"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 29 - "Community 29"
Cohesion: 0.4
Nodes (6): Android App Icon Set, Flutter Dependencies, Flutter Dev Dependencies, elsafe App Identity, Flutter Dashboard UI, Flutter Project Configuration

### Community 30 - "Community 30"
Cohesion: 0.53
Nodes (6): elsafe Brand Identity, iOS App Icons, iOS Launch Screens, macOS App Icons, Shield Logo Design, Web Favicon and Icons

## Knowledge Gaps
- **542 isolated node(s):** `MainActivity`, `-registerWithRegistry`, `MyApp`, `_MyAppState`, `main` (+537 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 0` to `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 12`, `Community 13`, `Community 14`, `Community 15`, `Community 16`, `Community 17`, `Community 18`, `Community 19`?**
  _High betweenness centrality (0.357) - this node is a cross-community bridge._
- **Why does `../../config/temuan_model.dart` connect `Community 2` to `Community 0`, `Community 1`, `Community 3`, `Community 5`, `Community 6`, `Community 7`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Why does `../../config/app_theme.dart` connect `Community 10` to `Community 0`, `Community 1`, `Community 2`, `Community 4`, `Community 8`, `Community 9`, `Community 12`, `Community 13`, `Community 16`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **What connects `MainActivity`, `-registerWithRegistry`, `MyApp` to the rest of the system?**
  _542 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._