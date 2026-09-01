# AGENTS.md

Source of truth for any agent working in this repo (Flutter + GetX, Restic POS
mobile app). For detailed coding conventions see
`.github/instructions/instrucciones-restic.instructions.md`; for the feature parity
tracker see `.opencode/planes/control-implementacion-funcionalidades.md`.

## Commands

flutter pub get
flutter run                      # device/emulator
flutter build apk --release      # release APK
flutter test                     # unit/widget tests
dart analyze                     # static analysis

## User manual rule

The end-user manual is maintained in a **separate repo** at `D:\documentacion-usuario-restic`
(MkDocs Material). It documents what users can do from this app.

Whenever a change adds or modifies a **user-facing screen, flow, or behavior** (new
screen, changed UX, new action, changed roles/permissions, new ticket type, etc.),
update the manual too. The task is incomplete until the manual reflects the change.

1. Find the affected section in `D:\documentacion-usuario-restic\docs\` (the `nav:` in
   `mkdocs.yml` lists every section).
2. Edit the matching `.md` in place, following the conventions in that repo's
   `CONTRIBUTING.md` (objetivo → rol → paso a paso → resultado → notas;
   admonitions `!!! tip`/`!!! warning`; image markers `![title](img/file.png)`).
3. For a brand-new feature, create `docs/<feature>.md` and add one line under
   `nav:` in `mkdocs.yml`.
4. Commit the manual change in the `documentacion-usuario-restic` repo (versioned
   independently from this one).

Also keep `.opencode/planes/control-implementacion-funcionalidades.md` updated per
its own "Notas operativas". Pure refactors, performance, or test-only changes do
NOT require a manual update.