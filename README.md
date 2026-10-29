# Koral app

Koral is a premium Flutter + Supabase creative studio platform for turning ideas into polished work.

## Features
- Secure auth and role-aware access
- Project library and brief composer
- Storyboard and scene planning
- Export center for decks, documents, and bundles
- Notifications and team workspace views
- Offline-first local cache
- Admin dashboard and analytics

## Getting started

1. Install Flutter 3.24 or newer.
2. Run:
   ```bash
   flutter pub get
   ```
3. Copy `.env.example` to `.env` and set your Supabase values.
4. Start the app:
   ```bash
   flutter run
   ```

## Environment

Set the following before running locally:

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"
```

The app starts in a mock/demo mode if Supabase is not configured yet.
