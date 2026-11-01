# Koral

One brief in, finished work out. A Flutter app with a Supabase backend.

## What works

- Real accounts: sign up and sign in with email and password through Supabase Auth.
- Projects saved in your database and private to each person.
- Write a brief, choose what to make (social post, document, slide outline or video script) and a language, then tap **Generate**. The server calls your AI provider and saves the result.
- A daily limit of 40 AI requests per person, enforced on the server. Failed AI calls are refunded. The owner account has no limit.
- An Owner tab with live totals, visible only to the owner and refused by the database to anyone else.

## Not built yet

Google sign-in, images, voices and video, exporting real .pptx and .docx files, the Studio scene canvas, offline cache, payments.

## Setup

You need Flutter (3.27 or newer), Node.js 20 or newer (for the Supabase CLI via `npx`), and a free Supabase project.

### 1. Connect the app to Supabase

In the Supabase dashboard open **Project Settings → API**. Copy `env.example.json` to `env.json` and fill in the project URL and the anon (or publishable) key. `env.json` is gitignored.

### 2. Create the database

```
npx supabase init
npx supabase login
npx supabase link --project-ref YOUR-PROJECT-REF
npx supabase db push
```

`supabase init` only adds `supabase/config.toml`; it keeps the migration and function already in the folder. If you prefer the dashboard, paste `supabase/migrations/20261031000000_koral_init.sql` into the SQL editor and run it.

### 3. Switch on AI generation

Pick any OpenAI-compatible provider that is reachable from the internet. Base URLs:

- Groq: `https://api.groq.com/openai/v1`
- Cerebras: `https://api.cerebras.ai/v1`
- Google AI Studio: `https://generativelanguage.googleapis.com/v1beta/openai`

```
npx supabase secrets set AI_BASE_URL=https://api.groq.com/openai/v1 AI_API_KEY=your-key AI_MODEL=model-name-from-provider
npx supabase functions deploy generate --no-verify-jwt
```

Ollama or FreeLLMAPI running on your laptop won't work here: Supabase's servers can't reach your laptop.

If the function logs say `Missing Supabase environment variables`, set `SB_PUBLISHABLE_KEY` and `SB_SECRET_KEY` as secrets with your project's publishable and secret keys.

### 4. Add the platform folders (once)

```
flutter create --project-name koral --org com.korevatools --platforms=android,web,windows .
```

This only adds the missing `android/`, `web/` and `windows/` folders; it doesn't overwrite existing files. Add iOS later on a Mac.

For Android release builds, add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`. Debug builds already have it.

### 5. Run

```
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=env.json
```

Without `env.json` the app shows setup instructions instead of fake data.

### 6. Make yourself the owner

Sign up in the app first, then run this in the Supabase SQL editor:

```sql
update public.profiles set role = 'owner' where email = 'YOUR-EMAIL';
```

Sign out and back in to see the Owner tab. There is deliberately no way to do this from inside the app.

## Email confirmation

Supabase asks new users to confirm their email. The link confirms the account even if the page it opens afterwards fails to load; then sign in in the app. To make that page nicer, set **Authentication → URL Configuration → Site URL** to your website. For quick testing you can turn off **Confirm email** under **Authentication → Providers → Email**.

## Before every push

```
flutter analyze
flutter test
```

Both must pass. Never push code that hasn't been compiled.

## Security

- The anon/publishable key is designed to be inside the app. Row-level security in the migration is what protects each person's data.
- The service_role/secret key and the AI key live only in Supabase secrets. Never put them in the app or this repo.
- `env.json`, `.env` files, Android keystores and `key.properties` are gitignored.
- Results and usage counts can only be written by the server, so nobody can fake results or reset their own limit.
