/// hive_ce box names. Every repo under `symphonicz.github.io` shares the
/// browser storage, so each name starts with the app prefix. Never rename
/// one (ADR 0001).
abstract final class BoxNames {
  static const entries = 'snowflow_entries';
  static const settings = 'snowflow_settings';
}
