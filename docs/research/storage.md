# หาข้อมูล: package เก็บข้อมูลในเครื่องที่ใช้ได้ทั้ง เว็บ / iOS / Android

> ตั๋ว: symphonicz/snow_flow#24 · ค้นเมื่อ 2026-10-03
> เกณฑ์ที่ต้องผ่าน: **"ปิดแอปแล้วเปิดใหม่ ข้อมูลยังอยู่ และใช้งานได้แบบออฟไลน์"**
> ขอบเขตของ SnowFlow: ผู้ใช้คนเดียว ไม่มีเซิร์ฟเวอร์ ข้อมูลอยู่ในเครื่อง ราว 3,000 รายการ/ปี
> เครื่องที่ใช้พัฒนาตอนนี้: Flutter 3.35.3 / **Dart 3.9.2** (ดูจาก `flutter --version`) และ `pubspec.yaml` กำหนด `sdk: ^3.9.2`
>
> เอกสารนี้รวบรวมข้อเท็จจริงเท่านั้น ยังไม่เลือก package (เจ้าของโปรเจกต์ตัดสินใจในตั๋วแยก)
> ข้อความที่ระบุว่า **[ยังไม่ยืนยัน]** คือสิ่งที่หาแหล่งต้นทางมายืนยันไม่ได้

---

## คำศัพท์ที่ใช้บ่อย (อธิบายแบบภาษาคน)

- **IndexedDB** — "ตู้เก็บของ" ที่เบราว์เซอร์มีให้ทุกเว็บ เก็บข้อมูลได้เยอะ (หลายร้อย MB ขึ้นไป) อยู่ในเครื่องผู้ใช้ ไม่ได้ส่งไปไหน
- **localStorage** — ช่องเก็บข้อความเล็ก ๆ ในเบราว์เซอร์ จำกัดราว 5 MiB ต่อเว็บไซต์
- **OPFS (Origin Private File System)** — "โฟลเดอร์ลับ" ที่เบราว์เซอร์แบ่งให้แต่ละเว็บใช้เหมือนมีไฟล์จริง ๆ เร็วกว่า IndexedDB สำหรับงานฐานข้อมูล แต่บางกรณีต้องตั้งค่าเซิร์ฟเวอร์เพิ่ม
- **WASM (WebAssembly)** — วิธีเอาโปรแกรมที่เขียนด้วยภาษาอื่น (เช่น SQLite ที่เขียนด้วยภาษา C) มารันในเบราว์เซอร์ได้ ไฟล์จะชื่อลงท้าย `.wasm`
- **Web Worker / Shared Worker** — "ผู้ช่วยเบื้องหลัง" ของหน้าเว็บ ทำงานหนักแยกจากหน้าจอ เพื่อไม่ให้หน้าค้าง Shared Worker คือผู้ช่วยตัวเดียวที่หลายแท็บใช้ร่วมกันได้
- **COOP/COEP headers** — ค่าที่ "เซิร์ฟเวอร์ที่ฝากเว็บ" ต้องส่งมาพร้อมหน้าเว็บ เพื่อเปิดฟีเจอร์ความปลอดภัยขั้นสูงของเบราว์เซอร์ โฮสต์ฟรีอย่าง GitHub Pages ตั้งค่านี้เองไม่ได้
- **Code generation (build_runner)** — เครื่องมือที่ "เขียนโค้ดเสริมให้อัตโนมัติ" จากคำอธิบายที่เราเขียน ต้องสั่งรันคำสั่ง `dart run build_runner build` ทุกครั้งที่แก้โครงสร้างข้อมูล
- **Service Worker** — สคริปต์เบื้องหลังที่ทำให้ "ตัวแอปเว็บ" (ไม่ใช่ข้อมูล) เปิดได้ตอนไม่มีเน็ต โดยเก็บไฟล์ของแอปไว้ในเครื่อง
- **Eviction** — การที่เบราว์เซอร์ "ลบข้อมูลของเว็บทิ้งเอง" โดยผู้ใช้ไม่ได้สั่ง

---

## TL;DR ตารางเปรียบเทียบ

| Package | เว็บ / iOS / Android | ข้อมูลบนเว็บอยู่ที่ไหน | งานติดตั้งเพิ่มบนเว็บ | การดูแล (maintenance) | ความเสี่ยงต่อเกณฑ์ "ปิดเปิดแล้วข้อมูลยังอยู่ / ออฟไลน์" |
|---|---|---|---|---|---|
| **drift** (SQLite) | ✅ / ✅ / ✅ | OPFS (ถ้ามี COOP/COEP หรือ Firefox) ไม่งั้น IndexedDB; ถ้าไม่มีอะไรใช้ได้เลย → เก็บในหน่วยความจำ (หายเมื่อปิด) | ต้องวาง `sqlite3.wasm` + `drift_worker.js` ในโฟลเดอร์ `web/` (เวอร์ชันต้องตรงกัน) | คึกคักมาก: 2.35.1 ออก 2026-09-30 แต่ **2.33.0 ขึ้นไปต้องใช้ Dart ≥ 3.10** → เครื่องตอนนี้ (Dart 3.9.2) ใช้ได้สูงสุด 2.32.1 | (1) อาจตกไปโหมดเก็บในหน่วยความจำแบบเงียบ ๆ ถ้าไม่เช็ก (2) เคยมีบั๊ก 2.34.2–2.35.0 ที่ทำให้ข้อมูลใน transaction หายเมื่อรีโหลด (แก้แล้วใน 2.35.1) (3) ต้องใช้ code generation |
| **hive_ce** | ✅ / ✅ / ✅ | IndexedDB (1 box = 1 ฐานข้อมูล IndexedDB) | ไม่มี | คึกคัก: 2.20.1 ออก 2026-09-27, ต้องการ Dart ≥ 3.4 | ไม่มีบั๊กเปิดค้างเรื่องข้อมูลหายที่พบ; มีกรณีที่คนเข้าใจผิดว่าข้อมูลหาย (สาเหตุจริงคือชื่อ key เปลี่ยน — ดูด้านล่าง) ต้องใช้ code generation ถ้าจะเก็บ object ของเราเอง |
| **shared_preferences** (เก็บทุกรายการเป็น JSON ก้อนเดียว) | ✅ / ✅ / ✅ | localStorage | ไม่มี | ทีม Flutter ดูแล: 2.5.5 ออก 2026-03-25 (ต้อง Dart ≥ 3.9 / Flutter ≥ 3.35) | **ผู้ทำเองเขียนว่าห้ามใช้เก็บข้อมูลสำคัญ**; บนเว็บเพดาน ~5 MiB จะเต็มในราว 8–11 ปี (หรือเร็วกว่าถ้ามีบันทึกยาว); เขียนใหม่ทั้งก้อนทุกครั้งที่บันทึก |
| **sembast** + **sembast_web** | ✅ / ✅ / ✅ (ใช้ 2 package) | IndexedDB | ไม่มี | ยังออกเวอร์ชันใหม่ แต่ตัวใหม่ต้อง Dart ≥ 3.12 (sembast 3.8.11) / ≥ 3.10–3.12 (sembast_web) → บน Dart 3.9.2 ได้ sembast 3.8.10 (2024-12) + sembast_web 2.4.2 (2025-06) | ไม่ต้อง code gen; ต้องเขียนแปลงข้อมูลเป็น Map เอง; ต้องแยกโค้ดเปิดฐานข้อมูลเว็บ/มือถือ |
| isar | ⚠️ | — | — | เวอร์ชันเสถียรล่าสุด 3.1.0+1 (2023-04-25), 4.0.0-dev.14 (2023-08-21) ไม่มีออกใหม่ | หยุดพัฒนาไปนานแล้ว ไม่แนะนำให้พิจารณา |
| objectbox | ❌ เว็บ | — | — | 5.3.2 | ไม่รองรับเว็บ |
| sqflite | ⚠️ เว็บเป็นแบบทดลอง | — | ใช้ `sqflite_common_ffi_web` | 2.4.4 | เว็บเป็น "Experimental" |

**โฮสต์จริง: GitHub Pages** (project site เช่น `https://symphonicz.github.io/snow_flow/`) → ไม่มี COOP/COEP, drift บน Chrome/Safari จึงใช้ IndexedDB ไม่ใช่ OPFS; และพื้นที่เก็บข้อมูลแชร์กับทุก project site ใต้ `symphonicz.github.io` — ดูหัวข้อ "ผลกระทบจากการใช้ GitHub Pages"

**ข้อสำคัญที่กระทบทุก package เท่ากัน:** บนเว็บ เบราว์เซอร์มีสิทธิ์ลบข้อมูลเองได้ (ดูหัวข้อ "ความเสี่ยงที่เบราว์เซอร์ลบข้อมูลเอง") และการ "เปิดแอปเว็บตอนออฟไลน์" ต้องพึ่ง Service Worker ซึ่ง Flutter กำลังเลิกสร้างให้ (เป็นเรื่องแยกจากการเก็บข้อมูล)

---

## 1. drift (SQLite)

**คืออะไร:** ใช้ SQLite (ฐานข้อมูลแบบตารางที่ใช้กันทั่วโลก) ผ่านภาษา Dart บนมือถือเก็บเป็นไฟล์ในเครื่อง บนเว็บใช้ SQLite เวอร์ชัน WASM

### รองรับแพลตฟอร์ม / คะแนน
- รองรับ iOS, Android, Web, Windows, macOS, Linux และรองรับ WebAssembly; 160/160 pub points, ~2.48k likes, ผู้เผยแพร่ simonbinder.eu (ยืนยันตัวตนแล้ว) — https://pub.dev/packages/drift/score

### เวอร์ชันและความเข้ากันได้กับ Dart (สำคัญ)
ข้อมูลจาก pub.dev API — https://pub.dev/api/packages/drift
| เวอร์ชัน | วันที่ออก | Dart ขั้นต่ำ |
|---|---|---|
| 2.32.1 | 2026-03-22 | ≥ 3.5.0 |
| 2.33.0 | 2026-05-03 | **≥ 3.10.0** |
| 2.34.2 | 2026-07-14 | ≥ 3.10.0 |
| 2.35.0 | 2026-09-09 | ≥ 3.10.0 |
| 2.35.1 | 2026-09-30 | ≥ 3.10.0 |

- ออกเวอร์ชันใหม่ราวเดือนละครั้ง → ยังดูแลอยู่อย่างแข็งขัน
- เครื่องพัฒนาตอนนี้เป็น Dart 3.9.2 → `flutter pub get` จะเลือกได้สูงสุด **2.32.1** ถ้าจะใช้เวอร์ชันล่าสุดต้องอัปเกรด Flutter ให้มี Dart ≥ 3.10 ก่อน (สรุปจากตารางข้างบน)
- `drift_dev` (ตัวสร้างโค้ด) ตัวล่าสุด 2.35.1 ก็ต้องการ Dart ≥ 3.10 — https://pub.dev/api/packages/drift_dev ; เวอร์ชันเก่าที่เข้ากับ 3.9.2 ได้คู่กับ drift 2.32.1 คือเวอร์ชันไหนแน่ **[ยังไม่ยืนยัน]** (pub จะเลือกให้เองตอน `pub get`)
- 2.32.0 เปลี่ยนไปใช้ package `sqlite3` รุ่น 3.x ซึ่ง "อาจทำให้ของเดิมพัง" และต้องใช้ `sqlite3.wasm` จากรุ่น 3.x — https://pub.dev/packages/drift/changelog

### ต้องใช้ code generation
- ต้องเพิ่ม `drift`, `drift_flutter` และ (สำหรับพัฒนา) `drift_dev` + `build_runner` แล้วรัน `dart run build_runner build` ทุกครั้งที่แก้โครงสร้างตาราง — https://drift.simonbinder.eu/setup/
- แปลว่า: เราเขียนคำอธิบายตาราง แล้วเครื่องมือจะสร้างไฟล์โค้ดเสริมให้ ถ้าลืมรันคำสั่ง โค้ดจะ error

### งานติดตั้งเพิ่มบนเว็บ
อ้างอิงทั้งหมดจาก https://drift.simonbinder.eu/platforms/web/
- ต้องวางไฟล์ 2 ไฟล์ในโฟลเดอร์ `web/`: `sqlite3.wasm` (ตัว SQLite) และ `drift_worker.js` (ผู้ช่วยเบื้องหลัง) โหลดได้จากหน้า release ของ drift บน GitHub และ **ต้องเอามาจาก release เดียวกัน และตรงกับเวอร์ชัน drift ใน `pubspec.lock`**
- เซิร์ฟเวอร์ต้องส่งไฟล์ `.wasm` ด้วย `Content-Type: application/wasm`
- **ที่เก็บข้อมูลบนเว็บ** drift เลือกให้อัตโนมัติตามลำดับ:
  1. `opfsShared` — OPFS ผ่าน shared worker (Firefox เท่านั้น)
  2. `opfsLocks` — OPFS (ต้องมี COOP/COEP headers)
  3. `sharedIndexedDb` — IndexedDB ที่กันหลายแท็บแย่งกันเขียน
  4. `unsafeIndexedDb` — IndexedDB แบบไม่กันหลายแท็บ
  5. `inMemory` — **เก็บในหน่วยความจำ ไม่บันทึกลงเครื่อง** (ปิดแท็บแล้วหาย) ใช้เมื่อไม่มีวิธีอื่น
- เช็กได้ว่าระบบเลือกวิธีไหนผ่าน `WasmDatabaseResult.chosenImplementation` และดูว่าขาดฟีเจอร์อะไรผ่าน `missingFeatures`
- **COOP/COEP ไม่บังคับ** ถ้าไม่มี drift จะถอยไปใช้ IndexedDB ซึ่งช้ากว่าแต่ยังทำงานได้ ข้อเสียของการเปิด header นี้: ใช้ร่วมกับ popup ล็อกอินบางแบบ (เช่น Google Auth) ไม่ได้ และ Safari 16 มีบั๊กโหลด worker จากแคชเมื่อเปิด header นี้
- ตารางเบราว์เซอร์จากเอกสาร: Firefox เต็มรูปแบบทั้งมี/ไม่มี header; Chrome ไม่มี header = ใช้ได้แต่ช้ากว่า; **Chrome บน Android ไม่มี shared worker** จึง "ไม่มีทางกันการแย่งเขียนข้อมูลระหว่างแท็บ"; Safari ใช้ได้ดี (ช้ากว่าเล็กน้อย)

### ใช้กับ `flutter build web` + โฮสต์ไฟล์ธรรมดา (เช่น GitHub Pages) ได้ไหม
- ได้ในแง่หลักการ: GitHub Pages ตั้ง COOP/COEP ไม่ได้ → drift จะใช้ IndexedDB แทน OPFS (บน Firefox ยังใช้ OPFS ได้) — สรุปจาก https://drift.simonbinder.eu/platforms/web/
- GitHub Pages ส่งไฟล์ `.wasm` เป็น `application/wasm` ถูกต้อง (ทดสอบตรงเมื่อ 2026-10-03 — ดูหัวข้อ "ผลกระทบจากการใช้ GitHub Pages")

### บั๊กที่เกี่ยวกับเกณฑ์ "ข้อมูลยังอยู่" โดยตรง
- drift issue #3864 (เปิด 2026-09-15, ปิดแล้ว): บนเว็บโหมด IndexedDB **ข้อมูลที่เขียนใน `transaction()` ไม่ถูกบันทึกลง IndexedDB และหายเมื่อรีโหลด** สาเหตุเริ่มตั้งแต่ 2.34.2 และยังอยู่ใน 2.35.0 — https://github.com/simolus3/drift/issues/3864
- แก้แล้วใน 2.35.1 ("Fix writes made in transactions or through RETURNING statements not being persisted to IndexedDB") — https://pub.dev/packages/drift/changelog
- 2.32.1 (เวอร์ชันที่ Dart 3.9.2 ใช้ได้) เกิดก่อนบั๊กนี้ แต่ก่อน 2.34.2 drift บันทึกลง IndexedDB ด้วยจังหวะแบบไหน และมีโอกาสข้อมูลล่าสุดหายถ้าปิดแท็บทันทีหรือไม่ **[ยังไม่ยืนยัน]**
- บทเรียน: บนเว็บ ควรมีเทสต์จริง "บันทึก → รีโหลด → ข้อมูลยังอยู่" โดยเฉพาะในโหมด IndexedDB

---

## 2. hive_ce

**คืออะไร:** ฐานข้อมูลแบบ key-value (คล้ายลิ้นชักที่มีป้ายชื่อ) เป็นภาคต่อที่ชุมชนดูแลของ Hive v2 ซึ่งตัวเดิมเลิกพัฒนาแล้ว

### การดูแล / เวอร์ชัน
- 2.20.1 ออก 2026-09-27, 2.20.0 ออก 2026-09-12, 2.19.3 ออก 2026-02-03; ต้องการ Dart ≥ 3.4 → ใช้กับ Dart 3.9.2 ได้ — https://pub.dev/api/packages/hive_ce
- ผู้เผยแพร่ IO Design Team (ยืนยันตัวตนแล้ว), 160 pub points, ~570 likes; รองรับ Android, iOS, Linux, macOS, Web, Windows และรองรับ Flutter web WASM — https://pub.dev/packages/hive_ce
- ตัวสร้างโค้ด `hive_ce_generator` 1.11.3 ออก 2026-07-28 ต้องการ Dart ≥ 3.4 (ใช้ analyzer ^14) — https://pub.dev/api/packages/hive_ce_generator ; analyzer 14 จะเข้ากับ Dart 3.9.2 ได้หรือไม่ หรือ pub ต้องถอยไปใช้ generator รุ่นเก่ากว่า **[ยังไม่ยืนยัน]**

### ข้อมูลบนเว็บอยู่ที่ไหน
- IndexedDB — โค้ด backend เว็บของ hive_ce ใช้ `IDBDatabase` และเปิด `objectStore` ของ IndexedDB โดยตรง — https://github.com/IO-Design-Team/hive_ce/blob/main/hive/lib/src/backend/js/native/storage_backend_js.dart
- ในโค้ดเดียวกัน `flush()` บนเว็บคืนค่าทันทีโดยไม่ทำอะไร และ `supportsCompaction = false` (ปล่อยให้ IndexedDB จัดการการบันทึกเอง) — แหล่งเดียวกัน
- ไม่ต้องตั้งค่าเซิร์ฟเวอร์หรือวางไฟล์เพิ่มใน `web/`

### Code generation
- ถ้าจะเก็บ object ของเราเอง (เช่น "รายการรายจ่าย") ต้องมี "type adapter" ซึ่ง hive_ce สร้างให้อัตโนมัติด้วย annotation `@GenerateAdapters` — https://pub.dev/packages/hive_ce (ต้องใช้ `hive_ce_generator` + `build_runner` — https://pub.dev/packages/hive_ce_generator)
- ถ้าเก็บเป็น Map/ข้อความ JSON เองก็ไม่ต้องใช้ code gen (ข้อสรุปจากการออกแบบ key-value ทั่วไป **[ยังไม่ยืนยัน]** ในเอกสาร)

### ข้อควรรู้บนเว็บ
- hive_ce issue #73 "IndexedDB instance on Web is not persisted" (เปิด 2025-01-24, ปิดเป็น completed): อาการคือข้อมูลหายหลัง deploy เวอร์ชันใหม่ ผู้ดูแลทดสอบแล้วข้อมูลยังอยู่ทั้งใน Safari และ Chrome และเตือนว่า "Web data in general is not guaranteed to persist" — https://github.com/IO-Design-Team/hive_ce/issues/73
- สืบต่อไปที่ bloc issue #4335: สาเหตุจริงคือ **ชื่อ key ที่ใช้เก็บข้อมูลมาจากชื่อคลาส (`runtimeType`) ซึ่งตอน build เว็บแบบ release ชื่อคลาสถูกย่อ (minify) และเปลี่ยนไปเมื่อโค้ดเปลี่ยน** → แอปเวอร์ชันใหม่หาข้อมูลเก่าไม่เจอ (ข้อมูลยังอยู่ใน IndexedDB แต่ใช้ key คนละชื่อ) แก้โดยตั้งชื่อ key ตายตัว — https://github.com/felangel/bloc/issues/4335
- บทเรียนที่ใช้ได้กับทุก package: **ห้ามใช้ชื่อคลาส/`runtimeType` เป็นชื่อ key หรือชื่อตาราง บนเว็บ** ให้ใช้ข้อความคงที่

---

## 3. shared_preferences (เก็บทุกรายการเป็น JSON ก้อนเดียว)

### ผู้ทำตั้งใจให้ใช้กับอะไร
- เวอร์ชัน 2.5.5 ออก 2026-03-25 ต้องการ Dart ≥ 3.9.0 และ Flutter ≥ 3.35.0 — https://pub.dev/api/packages/shared_preferences
- เอกสารเขียนว่าใช้กับ "simple data" และ **"this plugin must not be used for storing critical data"** และการเขียนลงดิสก์เป็นแบบ async ไม่รับประกันว่าบันทึกทันที — https://pub.dev/packages/shared_preferences
- ที่เก็บจริงแต่ละแพลตฟอร์ม: Android = DataStore Preferences (ค่าเริ่มต้น) หรือ SharedPreferences, iOS = NSUserDefaults, Web = localStorage — https://pub.dev/packages/shared_preferences

### เพดานขนาด
- **เว็บ (localStorage):** "up to 5 MiB of local storage ... per origin" เกินแล้วจะเกิด `QuotaExceededError` — https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
- **Android (DataStore):** เอกสาร Android บอกว่า DataStore "ideal for small datasets" ถ้าข้อมูลใหญ่/ซับซ้อนให้ใช้ Room แทน ไม่ได้ระบุตัวเลขเพดาน — https://developer.android.com/topic/libraries/architecture/datastore
- **iOS (NSUserDefaults):** แนวทางทั่วไปคือไม่เหมาะกับข้อมูลใหญ่ แต่ตัวเลขเพดานบน iOS **[ยังไม่ยืนยัน]** (หน้าเอกสาร Apple https://developer.apple.com/documentation/foundation/userdefaults โหลดเนื้อหาไม่ได้ผ่านเครื่องมือที่ใช้)

### ประมาณขนาด JSON (คำนวณเอง)
สมมติ 150–200 ไบต์ต่อรายการ, 3,000 รายการ/ปี:

| ระยะเวลา | 150 B/รายการ | 200 B/รายการ |
|---|---|---|
| 1 ปี | ~0.45 MB | ~0.6 MB |
| 3 ปี | ~1.35 MB | ~1.8 MB |
| 5 ปี | ~2.25 MB | ~3.0 MB |
| 8 ปี | ~3.6 MB | ~4.8 MB |
| 10 ปี | ~4.5 MB | ~6.0 MB ❌ |

- เทียบเพดาน 5 MiB (≈5.24 ล้านไบต์) → **เต็มราวปีที่ 8–11**
- ตัวเลขนี้อาจมองโลกในแง่ดีเกินไป: shared_preferences_web อาจเก็บค่าแบบเข้ารหัส JSON ซ้ำอีกชั้น ทำให้เครื่องหมาย `"` กลายเป็น `\"` และขนาดเพิ่มขึ้น **[ยังไม่ยืนยัน]**; ส่วนวิธีที่เบราว์เซอร์นับ 5 MiB (นับเป็นตัวอักษรหรือไบต์) **[ยังไม่ยืนยัน]** ถ้ามีบันทึก/โน้ตยาวเป็นภาษาไทยก็จะโตเร็วขึ้น
- อีกข้อ: ทุกครั้งที่เพิ่ม 1 รายการ ต้องแปลงและเขียน **ทั้งก้อน** ใหม่ เมื่อข้อมูลโตขึ้นจะช้าลง และถ้าเขียนไม่สำเร็จกลางทาง ความเสี่ยงคือเสียทั้งก้อน (ผลจากการออกแบบ ไม่ใช่ข้อมูลจากเอกสาร)

---

## 4. ตัวเลือกอื่น

### sembast + sembast_web
- sembast: "NoSQL persistent embedded file system document-based database" รองรับการเข้ารหัส; sembast_web: ฐานข้อมูลบนเว็บ "on top of IndexedDB" — https://pub.dev/api/packages/sembast , https://pub.dev/api/packages/sembast_web
- ต้องใช้ 2 package: บนมือถือใช้ไฟล์ (sembast), บนเว็บใช้ IndexedDB (sembast_web) ไม่ต้องใช้ code generation (เก็บข้อมูลเป็น Map) — ส่วน "ไม่ต้องใช้ code gen" สรุปจากลักษณะ API **[ยังไม่ยืนยันจากเอกสาร]**
- เวอร์ชันและ Dart:
  - sembast 3.8.11 ออก 2026-09-20 ต้อง **Dart ≥ 3.12**; ตัวก่อนหน้า 3.8.10 ออก 2024-12-19 ต้อง Dart ≥ 3.4 → บน Dart 3.9.2 จะได้ **3.8.10** — https://pub.dev/api/packages/sembast
  - sembast_web 2.4.6 ออก 2026-09-10 ต้อง Dart ≥ 3.12; 2.4.3–2.4.4+1 ต้อง ≥ 3.10; **2.4.2 (2025-06-18) ต้อง ≥ 3.7** → บน Dart 3.9.2 จะได้ 2.4.2 — https://pub.dev/api/packages/sembast_web
  - sembast_web 2.4.2 ใช้ร่วมกับ sembast 3.8.10 ได้หรือไม่ **[ยังไม่ยืนยัน]**

### isar
- เวอร์ชันเสถียรล่าสุด 3.1.0+1 (2023-04-25) และ 4.0.0-dev.14 (2023-08-21) ไม่มีเวอร์ชันใหม่ตั้งแต่นั้น — https://pub.dev/api/packages/isar → ถือว่าหยุดพัฒนา; สถานะเว็บของ isar **[ยังไม่ยืนยัน]** และมี fork ของชุมชนหรือไม่ไม่ได้ตรวจ

### objectbox
- 5.3.2; ระบุแพลตฟอร์ม "Android, iOS, macOS, Linux, Windows" — **ไม่มีเว็บ** — https://pub.dev/packages/objectbox

### sqflite
- รองรับ iOS, Android, macOS; เว็บเป็น "Experimental Web support using sqflite_common_ffi_web"; เวอร์ชัน 2.4.4 — https://pub.dev/packages/sqflite

---

## 5. ความเสี่ยงที่เบราว์เซอร์ลบข้อมูลเอง (กระทบทุก package บนเว็บเท่ากัน)

ทุก package ข้างบนบนเว็บเก็บข้อมูลใน IndexedDB, OPFS หรือ localStorage ซึ่ง **อยู่ภายใต้กฎเดียวกัน** ของเบราว์เซอร์ ไม่มี package ไหนหนีกฎนี้ได้

### 5.1 Safari: ลบข้อมูลหลัง 7 วันที่ไม่ได้ใช้งาน (ITP)
- ตั้งแต่ปี 2020 Safari ลบ "ข้อมูลที่สคริปต์เขียน" ได้แก่ IndexedDB, LocalStorage, Media keys, SessionStorage, Service Worker registrations และ cache เมื่อครบ **7 วันของการใช้ Safari โดยไม่มีการกด/แตะในเว็บนั้น** — https://webkit.org/blog/10218/full-third-party-cookie-blocking-and-more/ (2020-03-24)
- MDN ยืนยัน: "If an origin has no user interaction, such as click or tap, in the last seven days of browser use, its data created from script will be deleted." — https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
- **ข้อยกเว้น: เว็บแอปที่ "เพิ่มไปยังหน้าจอโฮม"** — WebKit เขียนว่าแอปบนหน้าจอโฮมนับวันแยกจาก Safari และ "We do not expect the first-party in such a web application to have its website data deleted." — https://webkit.org/blog/10218/full-third-party-cookie-blocking-and-more/
- สรุป: เปิดผ่านแท็บ Safari = เสี่ยงโดนลบถ้าไม่เปิดใช้ 7 วัน (นับวันที่ใช้ Safari); ติดตั้งเป็นแอปบนหน้าจอโฮม = ไม่ควรโดนลบตามกฎนี้
- เรื่องนี้กระทบ "เว็บใน iPhone/Mac ที่ใช้ Safari" เท่านั้น แอป iOS ที่ build แบบเนทีฟไม่เกี่ยว (แต่ iOS ถูกระบุว่าอยู่นอกขอบเขตของโปรเจกต์ตอนนี้)

### 5.2 การลบเมื่อพื้นที่เครื่องใกล้เต็ม
- ปกติเว็บทุกเว็บอยู่ในโหมด "best-effort" (เก็บให้ตามความสามารถ) เมื่อเครื่องพื้นที่ไม่พอ เบราว์เซอร์ใช้นโยบาย LRU คือลบข้อมูลของเว็บที่ใช้งานล่าสุดนานที่สุดก่อน และ **ลบทั้งหมดของเว็บนั้นทีเดียว ไม่ใช่บางส่วน**; เว็บที่ได้โหมด "persistent" จะถูกข้าม — https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
- โควตา (พื้นที่สูงสุด) — แหล่งเดียวกัน:
  - Chrome: สูงสุด ~60% ของดิสก์
  - Firefox: best-effort = 10% ของดิสก์หรือ 10 GiB (แล้วแต่อันไหนน้อยกว่า); persistent = สูงสุด 50% ของดิสก์
  - Safari 17+ (macOS 14 / iOS 17): แอปเบราว์เซอร์ ~60% ของดิสก์ต่อเว็บ — ยืนยันใน https://webkit.org/blog/14403/updates-to-storage-policy/ (2023-08-10) และเว็บแอปบนหน้าจอโฮมได้โควตาเท่ากับในเบราว์เซอร์
- ข้อมูล SnowFlow (ไม่กี่ MB) ห่างจากโควตาเหล่านี้มาก ปัญหาจริงคือ "การโดนลบ" ไม่ใช่ "พื้นที่ไม่พอ" (ยกเว้น localStorage ที่มีเพดาน 5 MiB แยกต่างหาก)

### 5.3 `navigator.storage.persist()` — ขอให้เบราว์เซอร์ "อย่าลบ"
- **Firefox:** แสดงหน้าต่างถามผู้ใช้ว่าอนุญาตหรือไม่ — https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria
- **Chrome/Edge:** ไม่ถามผู้ใช้ ตัดสินใจอัตโนมัติจากประวัติการใช้งาน — MDN (แหล่งเดียวกัน); web.dev ระบุเกณฑ์ เช่น ความถี่ในการใช้เว็บ, ติดตั้งหรือบุ๊กมาร์กไว้, ได้สิทธิ์แจ้งเตือน — https://web.dev/articles/persistent-storage (อัปเดตล่าสุด 2020-05-12)
- **Safari:** ไม่ถามผู้ใช้ ตัดสินใจด้วย heuristics "like whether the website is opened as a Home Screen Web App"; เมื่อได้โหมด persistent เว็บนั้น "might be excluded from eviction" — https://webkit.org/blog/14403/updates-to-storage-policy/
- โหมด persistent **ช่วยกันการลบตอนพื้นที่เต็ม** แต่ผู้ใช้ยังลบข้อมูลเองได้เสมอผ่านการตั้งค่าเบราว์เซอร์ — https://web.dev/articles/persistent-storage
- persistent ใน Safari **ช่วยกันกฎ 7 วัน (ITP) ด้วยหรือไม่ เอกสาร WebKit ไม่ได้พูดชัด [ยังไม่ยืนยัน]**
- ผู้ดูแล hive_ce เคยลองเปิด `persist()` แล้ว "can't get persistence to enable on localhost" — https://github.com/IO-Design-Team/hive_ce/issues/73 (แปลว่าทดสอบตอนพัฒนาบนเครื่องอาจไม่เห็นผลจริง)
- ไม่มี package ไหนในรายการที่เรียก `persist()` ให้อัตโนมัติตามเอกสารที่อ่าน (drift เอกสารเว็บไม่พูดถึง — https://drift.simonbinder.eu/platforms/web/) → ถ้าต้องการ ต้องเรียกเองในแอป

### 5.4 "ใช้งานออฟไลน์" บนเว็บ — ตัวแอปเองต้องเปิดได้ด้วย
- การเก็บข้อมูลไว้ในเครื่องไม่ได้ทำให้ "หน้าเว็บของแอป" เปิดได้ตอนไม่มีเน็ต ส่วนนั้นต้องใช้ Service Worker แคชไฟล์แอปไว้
- Flutter มีแผน deprecate และเลิกสร้าง `flutter_service_worker.js` เพราะ service worker เริ่มต้น "not a good fit for all use-cases" (issue ยังเปิดอยู่) — https://github.com/flutter/flutter/issues/156910
- Flutter 3.35.3 ที่ใช้อยู่ยังสร้าง service worker แบบแคชออฟไลน์ (`offline-first`) เป็นค่าเริ่มต้น — ดูรายละเอียดและข้อจำกัดเมื่อโฮสต์ใต้ path ย่อยในหัวข้อ 6.3
- ข้อนี้เป็นปัญหาเท่ากันทุก package

---

## 6. ผลกระทบจากการใช้ GitHub Pages

เงื่อนไขจากเจ้าของโปรเจกต์: เว็บจะโฮสต์บน GitHub Pages แบบ project site น่าจะเป็น `https://symphonicz.github.io/snow_flow/`
(ตรวจเมื่อ 2026-10-03: ทั้ง `https://symphonicz.github.io/` และ `/snow_flow/` ยังตอบ 404 คือยังไม่มีเว็บเผยแพร่อยู่)

### 6.1 ตั้งค่า HTTP header เอง (COOP/COEP) ไม่ได้
- เอกสารทางการของ GitHub Pages (หน้า limits) **ไม่ได้พูดถึง** การตั้ง header เองบน GitHub.com เลย มีพูดเฉพาะ GitHub Enterprise Server — https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits
- ในกระทู้ GitHub Community "HTTP Headers (e.g. Content-Security-Policy) on Pages" บัญชี `yoannchaudet` ตอบ (2023-05-02) ว่า "We don't support this feature today so a `meta` tag unfortunately is the only way." และมีผู้ใช้ขอ COOP/COEP โดยเฉพาะในกระทู้เดียวกัน (2024-05) โดยยังไม่มีการเพิ่มฟีเจอร์ — https://github.com/orgs/community/discussions/54257 (บัญชีนี้เป็นพนักงาน GitHub หรือไม่ **[ยังไม่ยืนยัน]**)
- ทดสอบตรง (2026-10-03) ด้วย `curl -I https://kripken.github.io/sql.js/dist/sql-wasm.wasm` (เว็บบน GitHub Pages): ได้ `server: GitHub.com`, `content-type: application/wasm`, `cache-control: max-age=600` และ **ไม่มี** header `Cross-Origin-Opener-Policy` / `Cross-Origin-Embedder-Policy`
  - แปลว่า: ไฟล์ `sqlite3.wasm` ของ drift จะถูกส่งด้วยชนิดไฟล์ที่ถูกต้อง
  - `max-age=600` = เบราว์เซอร์อาจใช้ไฟล์เก่าในแคชได้นานถึง 10 นาทีหลัง deploy เวอร์ชันใหม่
- (ทางเลี่ยงที่คนใช้กัน เช่น service worker ที่ "ใส่ header ให้เอง" — ไม่ได้ตรวจจากแหล่งต้นทาง **[ยังไม่ยืนยัน]** และจะชนกับ service worker ของ Flutter)

**แต่ละ package จะใช้อะไรบน GitHub Pages:**

| Package | Chrome/Edge (คอมพิวเตอร์) | Chrome บน Android | Firefox | Safari (Mac/iPhone) |
|---|---|---|---|---|
| drift | `sharedIndexedDb` (IndexedDB + shared worker กันหลายแท็บ) | `unsafeIndexedDb` (IndexedDB, ไม่มี shared worker จึงกันหลายแท็บไม่ได้) | `opfsShared` (OPFS ผ่าน shared worker — ไม่ต้องใช้ header) | IndexedDB (ระบุในเอกสารว่า "Good (slightly slower)") — เป็นแบบ shared หรือ unsafe **[ยังไม่ยืนยัน]** |
| hive_ce | IndexedDB | IndexedDB | IndexedDB | IndexedDB |
| sembast_web | IndexedDB | IndexedDB | IndexedDB | IndexedDB |
| shared_preferences | localStorage | localStorage | localStorage | localStorage |

- ที่มาของแถว drift: ลำดับการเลือกและตารางเบราว์เซอร์ใน https://drift.simonbinder.eu/platforms/web/ (`opfsLocks` ต้องใช้ COOP/COEP จึงตัดออก; Chrome Android ไม่มี shared worker) — การจับคู่ "เบราว์เซอร์ → โหมด" ข้างบนเป็นการสรุปจากเอกสาร ไม่ได้รันทดสอบจริง; ของจริงให้ดูจาก `chosenImplementation` ตอนรัน
- ข้อสำคัญ: บน GitHub Pages ผู้ใช้ drift ส่วนใหญ่จะอยู่ใน **โหมด IndexedDB** ซึ่งเป็นโหมดที่เพิ่งมีบั๊กข้อมูลใน transaction หาย (2.34.2–2.35.0, แก้ใน 2.35.1) — https://github.com/simolus3/drift/issues/3864
- hive_ce / sembast_web / shared_preferences ไม่ได้ใช้ COOP/COEP อยู่แล้ว จึงไม่มีอะไรเปลี่ยน

### 6.2 "origin" เดียวกัน = แชร์พื้นที่เก็บข้อมูลกับทุก project site
- origin คือ scheme + โดเมน + พอร์ต; **path ไม่นับ** ตัวอย่างจาก MDN: `http://example.com/app1/index.html` กับ `http://example.com/app2/index.html` เป็น origin เดียวกัน — https://developer.mozilla.org/en-US/docs/Glossary/Origin
- ดังนั้น `https://symphonicz.github.io/snow_flow/` กับ project site อื่นของบัญชีเดียวกัน (เช่น `https://symphonicz.github.io/โปรเจกต์อื่น/`) และ user site `https://symphonicz.github.io/` **อยู่ origin เดียวกัน** → ใช้ localStorage, IndexedDB, OPFS และ Cache Storage ร่วมกัน (โควตาและการลบข้อมูลของเบราว์เซอร์คิดเป็น "ต่อ origin" — https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria)

ผลกระทบ:
1. **ชื่อชนกัน**
   - shared_preferences ใส่ prefix `flutter.` หน้าทุก key เป็นค่าเริ่มต้น — https://pub.dev/documentation/shared_preferences/latest/shared_preferences/SharedPreferences/setPrefix.html → แอป Flutter อื่นใต้ `symphonicz.github.io` ที่ใช้ key ชื่อเดียวกันจะ **อ่าน/เขียนทับข้อมูลกัน** แก้ได้ด้วย `setPrefix` เป็นชื่อเฉพาะ
   - hive_ce: 1 box = 1 ฐานข้อมูล IndexedDB ตั้งชื่อตามชื่อ box (จากโค้ด backend ข้างบน) → ถ้าอีกแอปใช้ box ชื่อเดียวกัน (เช่น `settings`) จะชนกัน
   - drift: ชื่อฐานข้อมูลที่ตั้งตอนเปิด (เช่น `name: 'app'`) จะเป็นชื่อใน IndexedDB/OPFS ของ origin → ชนได้เช่นกัน (สรุปจากหลักการ origin **[ยังไม่ยืนยันชื่อจริงที่ drift ใช้ใน IndexedDB]**)
   - sembast_web: ชื่อฐานข้อมูลก็อยู่ใน IndexedDB ของ origin เดียวกัน (สรุปจากหลักการเดียวกัน)
   - **ทางป้องกัน:** ตั้งชื่อ box/ฐานข้อมูล/prefix ให้มีชื่อแอปนำหน้า เช่น `snowflow_...` ตั้งแต่วันแรก (เปลี่ยนทีหลังต้องย้ายข้อมูล)
2. **โควตาและการโดนลบร่วมกัน:** เมื่อเบราว์เซอร์ลบข้อมูลของ origin ตอนพื้นที่เต็ม จะ "ลบทั้งหมดของ origin ทีเดียว" — https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria → ข้อมูลของทุก project site ใต้ `symphonicz.github.io` ไปพร้อมกัน; localStorage 5 MiB ก็เป็นเพดานรวมของทุกแอปใต้ origin นี้
3. **ผู้ใช้กด "ล้างข้อมูลไซต์" ของ symphonicz.github.io** → ข้อมูล SnowFlow หายไปพร้อมแอปอื่นทั้งหมด (สรุปจากหลักการ origin; เมนูของแต่ละเบราว์เซอร์อาจล้างระดับ "site" ซึ่งกว้างกว่า origin ด้วยซ้ำ **[ยังไม่ยืนยัน]**)
4. **กฎ 7 วันของ Safari** นับ "การใช้งานเว็บนั้น" ระดับ origin/site — ถ้าผู้ใช้เปิด project site อื่นใต้โดเมนเดียวกันอาจช่วยนับเป็นการใช้งานด้วย **[ยังไม่ยืนยัน]**
5. `navigator.storage.persist()` ก็ให้สิทธิ์ระดับ origin — ได้หรือไม่ได้ก็ทั้ง `symphonicz.github.io` (สรุปจากการที่โหมด persistent เป็นของ origin — https://webkit.org/blog/14403/updates-to-storage-policy/)
6. ถ้าวันหนึ่งย้ายโดเมน (เช่นไปใช้ custom domain) = origin ใหม่ → ข้อมูลเดิมในเบราว์เซอร์ผู้ใช้จะ **ไม่ตามไป** ต้องมีวิธีส่งออก/นำเข้า (สรุปจากนิยาม origin)

### 6.3 Service worker / ออฟไลน์ กับ build ปกติของ Flutter บน GitHub Pages
ข้อมูลจากการอ่านซอร์สของ Flutter 3.35.3 ที่ติดตั้งในเครื่อง (`C:\src\flutter\packages\flutter_tools`):
- `flutter build web` มีตัวเลือก `--pwa-strategy` ค่าเริ่มต้น `offline-first` คำอธิบายในซอร์ส: "Attempt to cache the application shell eagerly and then lazily cache all subsequent assets ... the offline cache will be preferred." (`lib/src/commands/build_web.dart`, `lib/src/web/file_generators/flutter_service_worker_js.dart`)
- เมื่อเป็น `offline-first` ไฟล์ `flutter_bootstrap.js` ที่สร้างอัตโนมัติจะลงทะเบียน service worker ให้ (`lib/src/build_system/targets/web.dart`)
- รายการไฟล์ที่ service worker แคช (`RESOURCES`) สร้างจากไฟล์ทั้งหมดใน `build/web` โดยเก็บเป็น **path สัมพัทธ์** เช่น `main.dart.js` (`web.dart`, class `WebServiceWorker`) → ไฟล์ `sqlite3.wasm`/`drift_worker.js` ที่วางใน `web/` ก็น่าจะถูกรวมด้วย **[ยังไม่ยืนยันด้วยการ build จริง]**
- **ข้อน่ากังวลสำหรับ project site:** ในตัว service worker (`flutter_service_worker.js`) ตอนดักคำขอ จะคำนวณ key จาก URL โดยตัดเฉพาะ origin ออก (`event.request.url.substring(origin.length + 1)`) → ที่ `https://symphonicz.github.io/snow_flow/main.dart.js` key จะเป็น `snow_flow/main.dart.js` ซึ่ง **ไม่ตรง** กับ key ใน `RESOURCES` (`main.dart.js`) และโค้ดเขียนว่าถ้าไม่เจอใน RESOURCES ให้ปล่อยเบราว์เซอร์โหลดจากเน็ตเอง → จากการอ่านโค้ด **service worker เริ่มต้นของ Flutter อาจไม่ทำให้แอปเปิดออฟไลน์ได้เมื่อโฮสต์ใต้ path ย่อย** อย่าง `/snow_flow/` **[ยังไม่ยืนยันด้วยการทดสอบจริง — ข้อสรุปจากการอ่านซอร์สเท่านั้น]**
- **ชื่อแคชตายตัว:** service worker ใช้ชื่อแคช `flutter-app-cache`, `flutter-temp-cache`, `flutter-app-manifest` เหมือนกันทุกแอป Flutter และ Cache Storage เป็นของ origin → แอป Flutter หลายตัวใต้ `symphonicz.github.io` อาจลบ/เขียนทับแคชของกันและกัน (เช่น ตอนอัปเกรดจะลบไฟล์ที่ไม่อยู่ใน manifest ของตัวเอง) **[ยังไม่ยืนยันด้วยการทดสอบจริง — ข้อสรุปจากการอ่านซอร์ส]** (แคชนี้เก็บ "ไฟล์แอป" ไม่ใช่ "ข้อมูลรายจ่าย")
- **ทิศทางของ Flutter:** มีแผน deprecate และเลิกสร้าง `flutter_service_worker.js` (issue ยังเปิด) — https://github.com/flutter/flutter/issues/156910 → ถ้าอัปเกรด Flutter ในอนาคต service worker เริ่มต้นอาจหายไป (ในเวอร์ชันไหน **[ยังไม่ยืนยัน]**)
- **ข้อควรระวังเรื่องอัปเดต:** มีรายงานใน bloc issue #4335 ว่าคนสงสัย service worker ของ Flutter ว่าทำข้อมูลหายหลัง deploy แต่สาเหตุจริงคือ key จากชื่อคลาสที่ถูกย่อ (ดูหัวข้อ hive_ce) — https://github.com/felangel/bloc/issues/4335
- สรุปสำหรับเกณฑ์ "ใช้งานได้แบบออฟไลน์" บนเว็บ: การเลือก package เก็บข้อมูล **ไม่ช่วย** เรื่องเปิดแอปตอนออฟไลน์ ต้องทดสอบ (และอาจต้องเขียน service worker เอง) เป็นงานแยก โดยทดสอบบน URL จริง `/snow_flow/`: เปิดครั้งแรกตอนมีเน็ต → ปิดเน็ต → ปิดแท็บ → เปิดใหม่

---

## ข้อสังเกตสำหรับการตัดสินใจ

(ข้อเท็จจริงที่น่าจะมีผลต่อการเลือก — ยังไม่ได้เลือกให้)

1. **เวอร์ชัน Dart ของเครื่องเป็นตัวแปรสำคัญ:** เครื่องตอนนี้ Dart 3.9.2 ทำให้ drift ใช้ได้สูงสุด 2.32.1 (มี.ค. 2026), sembast 3.8.10 (ธ.ค. 2024), sembast_web 2.4.2 (มิ.ย. 2025) ส่วน hive_ce และ shared_preferences ใช้เวอร์ชันล่าสุดได้เลย ถ้าจะใช้ drift/sembast รุ่นล่าสุดต้องอัปเกรด Flutter ก่อน (แหล่ง: pub.dev API ในแต่ละหัวข้อ)
2. **ทุกตัวที่รองรับทั้ง 3 แพลตฟอร์มจริงจังมี 3 ตัว:** drift, hive_ce, sembast(+sembast_web) shared_preferences รองรับครบแต่ผู้ทำเตือนว่าห้ามใช้เก็บข้อมูลสำคัญ และ localStorage มีเพดาน 5 MiB
3. **ความยุ่งยากบนเว็บ:** drift ต้องวางไฟล์ `sqlite3.wasm` + `drift_worker.js` และต้องอัปเดตไฟล์ทุกครั้งที่อัปเกรด drift; hive_ce และ sembast_web ไม่ต้อง
4. **code generation:** drift ต้องใช้แน่นอน; hive_ce ต้องใช้ถ้าเก็บ object ของเราเอง; sembast และ shared_preferences ไม่ต้อง (แต่ต้องเขียนแปลงข้อมูลเป็น Map/JSON เอง)
5. **ความสามารถในการค้นหา/สรุปยอด:** drift เป็น SQL (กรอง เรียง รวมยอดในฐานข้อมูลได้) ส่วน hive_ce/sembast/shared_preferences เป็นแบบ key-value/document — กับข้อมูล ~3,000 รายการ/ปี การโหลดมาคำนวณในแอปก็อาจพอ **[ยังไม่ยืนยันด้วยการวัดจริง]**
6. **ความเสี่ยงที่ "บั๊กของ package" ทำข้อมูลหาย:** drift เพิ่งมีบั๊กข้อมูลใน transaction หายบนเว็บโหมด IndexedDB (2.34.2–2.35.0) แก้แล้วใน 2.35.1; hive_ce ไม่พบบั๊กลักษณะนี้ที่เปิดค้าง → ไม่ว่าเลือกตัวไหน ควรมีเทสต์ "บันทึก → รีโหลดหน้า → ข้อมูลยังอยู่" บนเว็บจริง
7. **ความเสี่ยงที่ "เบราว์เซอร์" ลบข้อมูล เท่ากันทุก package:** Safari ลบหลัง 7 วันไม่ได้ใช้ (ยกเว้นติดตั้งบนหน้าจอโฮม), ทุกเบราว์เซอร์ลบได้ตอนพื้นที่เต็มถ้าไม่ได้ persistent, ผู้ใช้ล้างข้อมูลเว็บเองได้เสมอ → การเลือก package แก้ปัญหานี้ไม่ได้ สิ่งที่ช่วยได้คือ เรียก `navigator.storage.persist()`, แนะนำให้ "ติดตั้งแอป/เพิ่มไปหน้าจอโฮม", และมีปุ่มส่งออก/สำรองข้อมูล (backup)
8. **กับดักบนเว็บ release build:** อย่าใช้ชื่อคลาส/`runtimeType` เป็นชื่อ key/box/ตาราง เพราะชื่อจะถูกย่อและเปลี่ยนทุกครั้งที่ build ทำให้ดูเหมือนข้อมูลหาย (https://github.com/felangel/bloc/issues/4335)
9. **ออฟไลน์บนเว็บเป็นอีกเรื่องหนึ่ง:** ต้องมี Service Worker แคชตัวแอป และ Flutter กำลังเลิกสร้างให้อัตโนมัติ (https://github.com/flutter/flutter/issues/156910) — อาจต้องมีตั๋วแยก
10. **GitHub Pages ไม่มี COOP/COEP:** drift จะไม่ได้ใช้ OPFS บน Chrome/Safari (ใช้ IndexedDB แทน) ข้อได้เปรียบด้านความเร็วของ drift บนเว็บจึงลดลง แต่สำหรับข้อมูลไม่กี่ MB น่าจะไม่รู้สึก **[ยังไม่ยืนยันด้วยการวัดจริง]**
11. **แชร์ origin `symphonicz.github.io`:** ไม่ว่าเลือกตัวไหน ควรตั้งชื่อ box/ฐานข้อมูล/prefix ให้มีชื่อแอปนำหน้าตั้งแต่แรก และรู้ไว้ว่าการล้างข้อมูลไซต์หรือการโดนลบจะกระทบทุก project site ใต้บัญชีนี้พร้อมกัน
12. **Chrome บน Android + เปิดหลายแท็บ:** drift บอกว่ากันการแย่งเขียนระหว่างแท็บไม่ได้ (https://drift.simonbinder.eu/platforms/web/); สำหรับแอปผู้ใช้คนเดียวที่มักเปิดแท็บเดียว ผลกระทบน่าจะน้อย แต่ hive_ce/sembast_web จัดการหลายแท็บอย่างไร **[ยังไม่ยืนยัน]**
