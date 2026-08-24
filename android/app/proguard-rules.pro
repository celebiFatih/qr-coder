# QR Coder release keep rules.
#
# Flutter release builds run R8 shrinking/optimization. With AGP 9 full-mode
# rules, WorkManager's Room-generated database implementation can otherwise
# be renamed/stripped in a way that breaks Room's reflective creation at app
# startup (before Flutter/Dart code runs).
#
# Keep the generated WorkManager database implementation and Room database
# subclasses intact, including constructors and members required at runtime.
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
