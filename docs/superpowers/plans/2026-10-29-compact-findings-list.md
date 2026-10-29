# Compact Findings List Implementation Plan

> **For agentic workers:** Use native inline execution for this plan. Steps use checkbox syntax for tracking.

**Goal:** Make each finding easier to scan with a compact photo thumbnail, clearer text hierarchy, and restrained status and risk colors.

**Architecture:** Refine the existing `TemuanListItem` widget without changing data, list behavior, or navigation. Keep responsive layout and light/dark colors tied to the current theme.

**Tech Stack:** Flutter, Dart, Material.

**Spec:** Approved design brief in the conversation on 2026-10-29.

## Global Constraints

- Preserve finding data, search/filter behavior, and current navigation.
- Preserve role-based edit/delete visibility and read-only admin behavior.
- Preserve responsive web layout and light/dark theme support.
- Keep status and risk values readable with restrained color use.

## Review Focus

- Missing or failed photos must retain a compact, stable thumbnail footprint.
- Long locations and descriptions must remain readable without expanding every list item.
- Unknown status/risk values must remain distinguishable without implying completion or severity.
- Edit/delete controls must remain visible only where existing permissions allow them.

---

### Task 1: Refine finding list item

**Files:**
- Modify: `lib/widgets/daftar_temuan/temuan_list_item.dart`

**Interfaces:**
- Consumes: Existing `TemuanModel`, `BuildContext` theme extension, callbacks, and `canModify`.
- Produces: Same `TemuanListItem` constructor and behavior with updated visual hierarchy.

- [x] Reduce thumbnail dimensions and use a calmer loading/error/empty-photo treatment.
- [x] Give location and description the strongest text hierarchy; make owner/date secondary.
- [x] Use compact, restrained status and risk labels with theme-aware surfaces and readable contrast.
- [x] Keep edit/delete secondary and preserve all existing callbacks and role gating.
- [x] Run `graphify update .` after the code change; do not add or run tests unless requested.
