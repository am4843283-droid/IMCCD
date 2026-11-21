# IMCCD — ابتدائی Cloud ERP

یہ پروجیکٹ React + Vite + Supabase پر مبنی IMCCD کی پہلی بنیاد ہے۔ موجودہ ورژن میں لاگ اِن، ڈیش بورڈ، کسٹمرز کی فہرست، آرڈرز کی فہرست، نیا آرڈر درج کرنا اور آرڈر/کسٹمر کے لیے Realtime اپ ڈیٹ شامل ہیں۔

## 1) کمپیوٹر پر ضروری پروگرام

Node.js کا موجودہ LTS ورژن انسٹال کریں: https://nodejs.org/
انسٹالیشن کے بعد Windows Terminal یا CMD بند کرکے دوبارہ کھولیں اور چلائیں:

```bash
node -v
npm -v
```

دونوں کمانڈز کے جواب میں ورژن آنا چاہیے۔

## 2) Supabase Cloud ڈیٹابیس

1. https://supabase.com پر اکاؤنٹ بنائیں اور New project منتخب کریں۔
2. مضبوط Database Password محفوظ جگہ لکھیں۔
3. پروجیکٹ بننے کے بعد Project Settings → API (یا Connect) سے Project URL اور Publishable/anon key حاصل کریں۔
4. Supabase کے SQL Editor میں `database/schema.sql` کا پورا متن پیسٹ کرکے Run کریں۔
5. Authentication → Users میں پہلا صارف بنائیں۔
6. اس صارف کا UUID کاپی کریں۔
7. SQL Editor میں آخر کے admin مثال والے INSERT میں `THE_AUTH_USER_UUID` کو اصل UUID سے بدل کر چلائیں۔ اس سے آپ کا پہلا اکاؤنٹ Admin ہوگا۔

**اہم:** `service_role` یا Secret key کبھی بھی اس React ویب ایپ، GitHub یا کسی عام صارف کے سامنے نہ رکھیں۔ صرف Publishable/anon key فرنٹ اینڈ میں استعمال ہوتی ہے؛ ڈیٹا کی حفاظت RLS پالیسیوں سے ہوتی ہے۔

## 3) پروجیکٹ چلانا

ZIP فائل Extract کریں۔ اس فولڈر کے اندر Terminal کھولیں اور چلائیں:

```bash
npm install
```

`.env.example` کی کاپی بنا کر اسی فولڈر میں `.env` نام دیں۔ اس میں اپنے Supabase Project URL اور Publishable/anon key لکھیں۔ پھر:

```bash
npm run dev
```

Terminal میں دکھایا گیا مقامی پتہ Chrome میں کھولیں، عموماً `http://localhost:5173`۔

## 4) آن لائن Deploy

اگلے مرحلے میں GitHub پر پروجیکٹ رکھ کر Vercel سے Deploy کریں گے۔ Vercel Project Settings → Environment Variables میں دونوں `VITE_SUPABASE_...` متغیرات شامل کرنے ہوں گے۔ ابھی اس مرحلے پر جانے کی ضرورت نہیں؛ پہلے مقامی لاگ اِن اور ڈیٹابیس کنکشن ٹیسٹ کریں۔

## 5) موجودہ حدود اور اگلے مراحل

- یہ ابتدائی بنیاد ہے، مکمل ERP نہیں۔
- آرڈر نمبر فی الحال unique رکھا گیا ہے۔
- آرڈر کی تاریخ HTML date input میں فی الحال ISO/Gregorian شکل میں ہے؛ اگلے مرحلے میں افغان شمسي هجري کیلنڈر بنائیں گے۔
- آرڈر کی پیداوار اور ڈسپیچ کے لیے الگ transaction tables، stock ledger، attendance، payroll، accounting، audit log اور backup اگلے مراحل میں شامل ہوں گے۔
- Excel فائل کو ابھی حذف نہ کریں۔ پہلے ڈیٹا کی جانچ، صفائی اور محفوظ migration بنائیں گے۔
- پہلے صارف کو Admin بنانا ضروری ہے؛ باقی نئے صارفین کو پہلے Viewer رکھا جائے گا، پھر Admin ان کے کردار تبدیل کرے گا۔

## 6) سیکیورٹی نوٹ

RLS آن ہے۔ عام authenticated صارف صرف ریکارڈ دیکھ سکتا ہے۔ صرف Admin یا Manager ریکارڈ شامل/تبدیل کر سکتے ہیں۔ کسی صارف کو Admin بنانے کے لیے صرف قابلِ اعتماد Admin ہی مجاز ہو۔
