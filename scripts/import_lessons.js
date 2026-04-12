const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// 1. SETUP: Download your service-account.json from Firebase Project Settings
// and save it in the same 'scripts' folder as this file.
const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'service_account.json');

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error('❌ Error: service_account.json not found in the scripts folder!');
  process.exit(1);
}

const serviceAccount = require(SERVICE_ACCOUNT_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// 2. Locate your lesson files in assets/data
const lessonsDir = path.join(__dirname, '..', 'assets', 'data');

async function uploadLessons() {
  try {
    const files = fs.readdirSync(lessonsDir).filter(file => file.startsWith('lesson_') && file.endsWith('.json'));

    if (files.length === 0) {
      console.log('⚠️ No lesson files found in assets/data/');
      return;
    }

    console.log(`🚀 Found ${files.length} lessons. Starting upload...`);

    for (const file of files) {
      const filePath = path.join(lessonsDir, file);
      const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

      if (!data.id) {
        console.error(`❌ Error: 'id' missing in ${file}. Skipping.`);
        continue;
      }

      // Upload to your 'Lessons' collection (using the id from JSON as Document ID)
      await db.collection('Lessons').doc(data.id).set(data);
      console.log(`✅ Uploaded: ${data.id}`);
    }

    console.log('\n🎉 All lessons uploaded successfully!');
  } catch (error) {
    console.error('❌ Error during upload:', error);
  }
}

uploadLessons();
