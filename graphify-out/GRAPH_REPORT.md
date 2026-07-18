# Graph Report - elsafe  (2026-07-18)

## Corpus Check
- 85 files · ~97,705 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 810 nodes · 915 edges · 60 communities (51 shown, 9 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4c94f15a`
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
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 32 edges
2. `../../config/app_theme.dart` - 16 edges
3. `../../config/temuan_model.dart` - 12 edges
4. `package:supabase_flutter/supabase_flutter.dart` - 11 edges
5. `../../config/ulp_service.dart` - 10 edges
6. `../../config/temuan_service.dart` - 9 edges
7. `../../config/temuan_types.dart` - 9 edges
8. `package:flutter/foundation.dart` - 7 edges
9. `package:flutter/services.dart` - 7 edges
10. `package:flutter_test/flutter_test.dart` - 7 edges

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

## Communities (60 total, 9 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (56): ../config/location_service.dart, _badge, build, _buildClosing, _buildCoordButtons, _buildDeskripsi, _buildFoto, _buildHeader (+48 more)

### Community 1 - "Community 1"
Cohesion: 0.04
Nodes (49): _applyFilters, BoxDecoration, build, _buildActionButtons, _buildAdvancedFilters, _buildDateButton, _buildDateField, _buildDropdownField (+41 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (44): _appendBreakdown, _appendKpiCards, _applyStyle, _bodyAltStyle, _bodyStyle, CellStyle, _cellText, _coordinates (+36 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (40): ../config/snackbar.dart, ../config/ulp_list.dart, ../../config/ulp_service.dart, build, _buildTextField, _buildUlpRow, Column, Container (+32 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (37): clearAll, hide, _showAnimatedSnackBar, showCustom, showError, showInfo, showLoading, showSimple (+29 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (38): ../../config/app_theme.dart, config/new_password.dart, config/supabase_config.dart, build, dispose, initState, main, MaterialApp (+30 more)

### Community 6 - "Community 6"
Cohesion: 0.05
Nodes (36): build, _buildDatePicker, _buildMiniMapPreview, _buildPenyulangSection, _buildStep1Temuan, _buildStep2Reminder, _buildStep3Closing, _buildStep4Sosialisasi (+28 more)

### Community 7 - "Community 7"
Cohesion: 0.05
Nodes (36): build, _buildDatePicker, _buildPenyulangSection, _buildStep1Temuan, _buildStep2Reminder, _buildStep3Closing, _buildStep4Sosialisasi, _buildStepIndicator (+28 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (35): backToDashboard, BottomNavigationBar, BottomNavigationBarItem, build, _buildBottomNav, _buildFab, _buildNotifIcon, closeExport (+27 more)

### Community 9 - "Community 9"
Cohesion: 0.06
Nodes (31): ../../config/sosialisasi_model.dart, ../../config/temuan_model.dart, _dateOnly, DateTime, _matchesIntFilter, _matchesStringFilter, build, Center (+23 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (30): AnimatedBuilder, build, _buildBody, _buildFilterDropdown, _buildSearchAndFilter, Card, Center, Column (+22 more)

### Community 11 - "Community 11"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 12 - "Community 12"
Cohesion: 0.07
Nodes (24): ../../config/temuan_types.dart, build, Container, SizedBox, TemuanListItem, build, _buildDropdown, Column (+16 more)

### Community 13 - "Community 13"
Cohesion: 0.09
Nodes (21): build, _buildEmpty, Center, dispose, _formatDate, _iconBgColor, _iconColor, _iconData (+13 more)

### Community 14 - "Community 14"
Cohesion: 0.1
Nodes (19): dark, light, ThemeService, build, CircularProgressIndicator, dispose, ElsafeApp, ElsafeSplashScreen (+11 more)

### Community 15 - "Community 15"
Cohesion: 0.11
Nodes (18): build, _buildNewFileItem, Column, FotoPickerWidget, _FotoPickerWidgetState, Function, initState, Padding (+10 more)

### Community 16 - "Community 16"
Cohesion: 0.12
Nodes (16): ../../config/temuan_service.dart, build, _buildExportQuickAction, DashboardInfoSection, DashboardScreen, DashboardScreenState, IconButton, initState (+8 more)

### Community 17 - "Community 17"
Cohesion: 0.12
Nodes (15): ../config/notification_service.dart, _aboutItem, build, CircleAvatar, _contactItem, DashboardDrawer, Drawer, _DrawerItem (+7 more)

### Community 18 - "Community 18"
Cohesion: 0.14
Nodes (13): ../config/app_logger.dart, ../config/lupa_password.dart, build, LoginPage, _LoginPageState, Scaffold, SingleChildScrollView, SizedBox (+5 more)

### Community 19 - "Community 19"
Cohesion: 0.14
Nodes (13): _bodyCell, ExportTemuanPdfGenerator, _formatDate, _formatDateTime, _joinNonEmpty, _pemilikObjekLabel, _periodLabel, _risikoLabel (+5 more)

### Community 20 - "Community 20"
Cohesion: 0.15
Nodes (12): AuthException, build, _buildInputField, _buildRegisterButton, Container, dispose, Function, RegisterPage (+4 more)

### Community 21 - "Community 21"
Cohesion: 0.15
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 22 - "Community 22"
Cohesion: 0.17
Nodes (12): Android App Icons, App Branding Assets, Google Auth Integration, Flutter App Screenshot, Google Logo Brand, iOS App Icon 20px, iOS App Icon 40px, iOS App Icon 60px (+4 more)

### Community 23 - "Community 23"
Cohesion: 0.2
Nodes (8): app_logger.dart, NotificationService, refreshUnreadCount, reset, _subscribeRealtime, SupabaseConfig, UlpService, package:supabase_flutter/supabase_flutter.dart

### Community 24 - "Community 24"
Cohesion: 0.18
Nodes (10): deleteFoto, deleteFotos, Exception, _getContentType, _isAdminProfile, TemuanService, package:file_picker/file_picker.dart, sosialisasi_model.dart (+2 more)

### Community 25 - "Community 25"
Cohesion: 0.22
Nodes (8): main, main, _temuan, TemuanModel, main, dart:io, package:elsafe/utils/export_temuan_filter.dart, package:flutter_test/flutter_test.dart

### Community 26 - "Community 26"
Cohesion: 0.25
Nodes (7): _argb, _containsXlsxEntry, main, _sampleTemuan, TemuanModel, package:elsafe/utils/excel_generator.dart, package:excel/excel.dart

### Community 28 - "Community 28"
Cohesion: 0.29
Nodes (6): hitungSkor, label, MatriksRisiko, Penyulang, skorDariNilai, TipeTemuan

### Community 29 - "Community 29"
Cohesion: 0.33
Nodes (4): DefaultFirebaseOptions, package:firebase_core/firebase_core.dart, package:flutter/foundation.dart, package:logger/logger.dart

### Community 30 - "Community 30"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 31 - "Community 31"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 32 - "Community 32"
Cohesion: 0.4
Nodes (6): Android App Icon Set, Flutter Dependencies, Flutter Dev Dependencies, elsafe App Identity, Flutter Dashboard UI, Flutter Project Configuration

### Community 33 - "Community 33"
Cohesion: 0.53
Nodes (6): elsafe Brand Identity, iOS App Icons, iOS Launch Screens, macOS App Icons, Shield Logo Design, Web Favicon and Icons

### Community 35 - "Community 35"
Cohesion: 0.4
Nodes (4): main, _temuan, TemuanModel, package:elsafe/config/temuan_model.dart

### Community 36 - "Community 36"
Cohesion: 0.4
Nodes (4): ByteData, main, dart:typed_data, package:elsafe/utils/pdf_generator.dart

### Community 37 - "Community 37"
Cohesion: 0.5
Nodes (3): MapUtils, package:flutter_map/flutter_map.dart, package:latlong2/latlong.dart

### Community 38 - "Community 38"
Cohesion: 0.5
Nodes (3): main, package:elsafe/config/app_theme.dart, package:elsafe/widgets/panduan_penggunaan.dart

## Knowledge Gaps
- **624 isolated node(s):** `MainActivity`, `-registerWithRegistry`, `MyApp`, `_MyAppState`, `main` (+619 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 4` to `Community 0`, `Community 1`, `Community 3`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 38`, `Community 12`, `Community 13`, `Community 14`, `Community 15`, `Community 16`, `Community 17`, `Community 18`, `Community 20`?**
  _High betweenness centrality (0.337) - this node is a cross-community bridge._
- **Why does `../../config/temuan_model.dart` connect `Community 9` to `Community 0`, `Community 1`, `Community 2`, `Community 6`, `Community 7`, `Community 10`, `Community 12`, `Community 16`, `Community 19`?**
  _High betweenness centrality (0.140) - this node is a cross-community bridge._
- **Why does `../../config/app_theme.dart` connect `Community 5` to `Community 1`, `Community 3`, `Community 4`, `Community 8`, `Community 9`, `Community 10`, `Community 12`, `Community 13`, `Community 16`, `Community 17`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **What connects `MainActivity`, `-registerWithRegistry`, `MyApp` to the rest of the system?**
  _624 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._