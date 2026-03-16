# Why Verification Email May Not Arrive (e.g. Rafat.EW@sakhaa.sa)

## Common Causes for Corporate Emails (@sakhaa.sa)

### 1. **Spam / Junk Folder**
- Check your **Spam** and **Junk** folders
- Check **Promotions** (Gmail) or **Other** tabs
- Add `noreply@YOUR_PROJECT_ID.firebaseapp.com` to your contacts or safe senders

### 2. **Corporate Email Filters**
Many company email systems (Microsoft 365, Google Workspace, etc.) block or quarantine emails from unknown senders like Firebase.

**What to do:**
- Ask your IT admin to **whitelist** or allow:
  - `noreply@*.firebaseapp.com`
  - Or your specific: `noreply@YOUR_PROJECT_ID.firebaseapp.com`
- Check if your company has a **quarantine** or **held messages** folder
- IT may need to add Firebase to the allowed sender list

### 3. **Find Your Firebase Sender Address**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Authentication → Templates
4. The sender is usually: `noreply@YOUR_PROJECT_ID.firebaseapp.com`

### 4. **Use a Custom Domain (Firebase)**
Firebase lets you use your own domain for auth emails, which can improve deliverability:

1. Firebase Console → Authentication → Templates
2. Click "Customize domain"
3. Add and verify your domain (e.g. `auth.yourcompany.com`)
4. Emails will come from your domain instead of `firebaseapp.com`

### 5. **Temporary Workaround: Use Personal Email**
- Register with a **personal email** (Gmail, Outlook, etc.) for testing
- Verification emails usually arrive within 1–2 minutes
- After verifying, you can ask admin to add your corporate email later (if you add that feature)

### 6. **Check Firebase Email Logs**
- Firebase Console → Authentication → Users
- Confirm the user exists and that verification was sent
- There is no detailed delivery log, but you can confirm the action was triggered

### 7. **Resend the Email**
- On the verification screen, use **"Resend verification email"**
- Try at different times (e.g. outside peak hours)
- Some corporate filters are less strict outside business hours

---

## Summary for @sakhaa.sa

Most likely: **corporate email security** is blocking or filtering Firebase’s verification emails.

**Recommended steps:**
1. Check Spam/Junk
2. Contact IT to whitelist `noreply@*.firebaseapp.com`
3. Or use a personal email for testing
