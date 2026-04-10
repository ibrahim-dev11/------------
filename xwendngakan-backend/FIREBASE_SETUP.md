# Firebase Notifications Setup Guide

دروست‌کردنی ئاگادارکردنەوی Firebase بۆ سیستەمی xwendngakan

## مراحل التثبيت / مراحل التثبيت

### 1. Download Firebase Service Account Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: **xwendgakanedu**
3. Navigate to: **Service Accounts** (Search in the search bar)
4. Find the service account or create one if it doesn't exist
5. Click on the service account email
6. Go to the **Keys** tab
7. Create a new key:
   - Click **Add Key** → **Create new key**
   - Select **JSON** format
   - Click **Create**
8. A JSON file will be downloaded

### 2. Place the Credentials File

1. Save the downloaded JSON file as `firebase-credentials.json`
2. Place it in: `storage/app/firebase-credentials.json`

```bash
# From the backend root directory
mv ~/Downloads/YOUR_SERVICE_ACCOUNT_KEY.json storage/app/firebase-credentials.json
```

### 3. Verify Setup

Test that Firebase is properly configured:

```bash
# Optional: Test by running artisan command (if you create one)
php artisan firebase:test
```

Check logs if there are errors:
```bash
tail -f storage/logs/laravel.log
```

### 4. Available API Endpoints

All endpoints require Bearer token authentication (Sanctum):

#### Send to Single User
```http
POST /api/admin/notifications/send-to-user
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN

{
  "user_id": 1,
  "title": "ئاگادار",
  "body": "نامە",
  "data": {
    "custom_key": "value"
  }
}
```

#### Send to Multiple Users
```http
POST /api/admin/notifications/send-to-users
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN

{
  "user_ids": [1, 2, 3],
  "title": "ئاگادار",
  "body": "نامە",
  "data": {}
}
```

#### Broadcast to All Users
```http
POST /api/admin/notifications/broadcast
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN

{
  "title": "بڵاوکردنەوە",
  "body": "بۆ هەموو بەکارهێنەرەکان",
  "data": {}
}
```

#### Subscribe Users to Topic
```http
POST /api/admin/notifications/subscribe-topic
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN

{
  "topic": "announcements",
  "user_ids": [1, 2, 3]
}
```

#### Send to Topic
```http
POST /api/admin/notifications/send-to-topic
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN

{
  "topic": "announcements",
  "title": "ئاگادار",
  "body": "پێیام"
}
```

### 5. How It Works - Flutter App Side

The Flutter app already has everything set up:

1. **NotificationService** initializes Firebase on app start
2. Gets and syncs FCM token with backend
3. Listens to incoming notifications
4. Shows local notifications in foreground
5. Handles background notifications automatically

### 6. Troubleshooting

#### "Firebase credentials file not found" error
- Ensure the JSON file is at `storage/app/firebase-credentials.json`
- Update `.env` if using a different path:
  ```
  FIREBASE_CREDENTIALS_JSON=/path/to/your/file.json
  ```

#### "FCM Token not found" or "Notifications disabled"
- User's app hasn't yet synced FCM token (app needs to be launched)
- User has disabled notifications (see `notifications_enabled` field)
- Make sure user is authenticated

#### Notifications not arriving
- Check that user's `fcm_token` is saved in database
- Check that `notifications_enabled = true` in the users table
- Check Laravel logs: `storage/logs/laravel.log`
- Ensure credentials JSON has proper permissions

### 7. Environment Configuration

Current `.env` settings:
- `FIREBASE_PROJECT_ID=xwendgakanedu`
- Credentials location: `storage/app/firebase-credentials.json`

To use a different path, update `.env`:
```env
FIREBASE_CREDENTIALS_JSON=/absolute/path/to/credentials.json
```

### 8. Testing with Postman/Insomnia

1. Get an auth token by logging in
2. Use the token in Authorization header: `Bearer YOUR_TOKEN`
3. Send POST requests to the endpoints above
4. Check that the user receives notifications on their device

### 9. Using in Code

From any controller or job in your Laravel app:

```php
use App\Services\FirebaseNotificationService;

class MyNotificationClass {
    public function __construct(FirebaseNotificationService $firebase) {
        $this->firebase = $firebase;
    }

    public function send() {
        $success = $this->firebase->sendToToken(
            token: $user->fcm_token,
            title: 'ئاگادار',
            body: 'نامە',
            data: ['link' => '/path']
        );
    }
}
```

### 10. Service Account Key Security

⚠️ **Important Security Notes:**

1. **Never commit** the `firebase-credentials.json` to git
2. **Keep it secret** - it has admin access to your Firebase project
3. Add to `.gitignore`:
   ```
   storage/app/firebase-credentials.json
   ```
4. Use environment variables or secret management in production
5. Regularly rotate the service account key

---

## Next Steps

1. Download your Firebase service account key
2. Place it in `storage/app/firebase-credentials.json`
3. Test by posting to `/api/admin/notifications/broadcast`
4. Verify notifications arrive on Flutter app

For questions, check:
- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/messaging)
- [Laravel-Firebase Documentation](https://github.com/kreait/laravel-firebase)
