const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

// ─── Email transporter (configured via Firebase env vars) ────────────────────
// Deploy with:
//   firebase functions:config:set email.user="yourapp@gmail.com" email.pass="your_app_password"
// Then access via functions.config().email.user / .pass
function createTransporter() {
  const config = functions.config();
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: config.email.user,
      pass: config.email.pass,
    },
  });
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ─── sendOtp callable function ────────────────────────────────────────────────
// Called from Flutter after sign-up. Creates / replaces Firestore OTP doc
// and sends the code to the user's email.
exports.sendOtp = functions.https.onCall(async (data, context) => {
  // Must be called by an authenticated user
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "تکایە سەرەتا چوێتە ژوورەوە"
    );
  }

  const uid = context.auth.uid;
  const email = data.email;

  if (!email || typeof email !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "ئیمەیڵ دروست نییە"
    );
  }

  // Rate-limit: max 1 resend per 60 seconds
  const otpRef = db.collection("otpVerifications").doc(uid);
  const existing = await otpRef.get();
  if (existing.exists) {
    const lastSent = existing.data().sentAt?.toDate();
    if (lastSent && Date.now() - lastSent.getTime() < 60 * 1000) {
      const secondsLeft = Math.ceil(
        60 - (Date.now() - lastSent.getTime()) / 1000
      );
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `تکایە ${secondsLeft} چرکەی تر چاوەڕوان بە پێش ناردنی کۆدی نوێ`
      );
    }
  }

  const otp = generateOtp();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

  // Store OTP in Firestore
  await otpRef.set({
    otp,
    email,
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    verified: false,
    attempts: 0,
  });

  // Send email
  const transporter = createTransporter();
  const mailOptions = {
    from: `"هۆژان - Hozhan" <${functions.config().email.user}>`,
    to: email,
    subject: "کۆدی دڵنیاکردنەوەی هۆژان",
    html: `
      <div dir="rtl" style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; background: #f8f9fa; border-radius: 16px; overflow: hidden;">
        <div style="background: linear-gradient(135deg, #508AA8 0%, #3a6e8a 100%); padding: 40px 30px; text-align: center;">
          <h1 style="color: white; margin: 0; font-size: 28px; letter-spacing: 1px;">هۆژان</h1>
          <p style="color: rgba(255,255,255,0.85); margin: 8px 0 0; font-size: 14px;">زمانی ئینگلیزی فێرببە</p>
        </div>
        <div style="padding: 40px 30px; text-align: center; background: white;">
          <h2 style="color: #1a1a2e; font-size: 22px; margin-bottom: 8px;">کۆدی دڵنیاکردنەوە</h2>
          <p style="color: #666; font-size: 15px; margin-bottom: 32px;">کۆدی خوارەوە بۆ دڵنیاکردنەوەی ئیمەیڵەکەت داخڵ بکە</p>
          <div style="background: #f0f4f8; border-radius: 16px; padding: 28px 20px; margin: 0 auto; max-width: 300px;">
            <span style="font-size: 42px; font-weight: 900; letter-spacing: 12px; color: #508AA8; font-family: 'Courier New', monospace;">${otp}</span>
          </div>
          <p style="color: #999; font-size: 13px; margin-top: 24px;">
            ئەم کۆدە تەنها 
            <strong style="color: #508AA8;">١٠ خولەک</strong>
            کاریگەرە
          </p>
          <p style="color: #bbb; font-size: 12px; margin-top: 8px;">
            ئەگەر تۆ داوای ئەمە نەکردووە، تکایە ئەم ئیمەیڵە پشت گوێ بخە.
          </p>
        </div>
        <div style="background: #f8f9fa; padding: 20px; text-align: center;">
          <p style="color: #aaa; font-size: 11px; margin: 0;">© 2025 هۆژان - Hozhan</p>
        </div>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: "کۆدەکە نێردرا" };
  } catch (err) {
    functions.logger.error("Email send failed", err);
    throw new functions.https.HttpsError("internal", "ناردنی ئیمەیڵ سەرکەوتوو نەبوو");
  }
});

// ─── verifyOtp callable function ─────────────────────────────────────────────
// Validates the OTP entered by the user.
exports.verifyOtp = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "تکایە سەرەتا چوێتە ژوورەوە"
    );
  }

  const uid = context.auth.uid;
  const enteredOtp = data.otp;

  if (!enteredOtp || typeof enteredOtp !== "string" || enteredOtp.length !== 6) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "کۆد دروست نییە"
    );
  }

  const otpRef = db.collection("otpVerifications").doc(uid);
  const otpDoc = await otpRef.get();

  if (!otpDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "کۆد نەدۆزرایەوە، تکایە کۆدێکی نوێ بابنێرە"
    );
  }

  const otpData = otpDoc.data();

  // Check max attempts (5 max)
  if (otpData.attempts >= 5) {
    await otpRef.delete();
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "هەوڵی زۆرت داوە، تکایە کۆدێکی نوێ بەدوا بیستانە"
    );
  }

  // Check expiry
  const expiresAt = otpData.expiresAt.toDate();
  if (Date.now() > expiresAt.getTime()) {
    await otpRef.delete();
    throw new functions.https.HttpsError(
      "deadline-exceeded",
      "کۆدەکە بوونی تەواوکرد، تکایە کۆدێکی نوێ بەدوا بیستانە"
    );
  }

  // Check if already verified
  if (otpData.verified) {
    return { success: true, message: "ئیمەیڵەکەت پێشتر دڵنیاکرایەوەیە" };
  }

  // Wrong OTP — increment attempts
  if (otpData.otp !== enteredOtp) {
    await otpRef.update({
      attempts: admin.firestore.FieldValue.increment(1),
    });
    const attemptsLeft = 4 - otpData.attempts;
    throw new functions.https.HttpsError(
      "invalid-argument",
      `کۆدەکە هەڵەیە. ${attemptsLeft} هەوڵی تر ماوە`
    );
  }

  // ✅ OTP correct — mark verified in Firestore
  const batch = db.batch();

  // Mark OTP as verified
  batch.update(otpRef, { verified: true });

  // Mark user's email as verified in their Firestore profile
  const userRef = db.collection("users").doc(uid);
  batch.update(userRef, { "profile.emailVerified": true });

  await batch.commit();

  // Also update Firebase Auth emailVerified via Admin SDK
  try {
    await admin.auth().updateUser(uid, { emailVerified: true });
  } catch (e) {
    functions.logger.warn("Could not update Auth emailVerified", e);
    // Non-fatal — Firestore is source of truth
  }

  return { success: true, message: "ئیمەیڵەکەت بە سەرکەوتوویی دڵنیاکرایەوە!" };
});
