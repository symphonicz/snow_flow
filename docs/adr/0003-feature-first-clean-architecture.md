# ใช้ Clean Architecture แบบแบ่งฟีเจอร์ก่อน พร้อมโฟลเดอร์กลาง `core/` และ `shared/`

โค้ดใน `lib/` แบ่งตามฟีเจอร์ก่อน (`features/entries`, `entry_form`, `summary`, `settings`) แล้วในแต่ละฟีเจอร์ค่อยแบ่ง 3 ชั้นตาม Clean Architecture (`data/` `domain/` `presentation/`) ชั้นในห้ามรู้จักชั้นนอก แอปนี้มีข้อมูลหลักอยู่ชุดเดียว (รายการ) ที่ทุกหน้าจอใช้ร่วมกัน ของที่ใช้ร่วมกันจึงไม่ได้ฝากไว้กับฟีเจอร์ใดฟีเจอร์หนึ่ง แต่แยกออกมาเป็นสองโฟลเดอร์กลาง `core/` เก็บของเชิงเทคนิค (ไฟล์ธีมไฟล์เดียว, การแปลภาษา, ตัวจัดรูปเงิน/วันที่, การเปิด hive_ce) ส่วน `shared/{domain,data}` เก็บของเชิงธุรกิจ (Entry, Category, AppSettings, repository, logic รอบเดือน) **ฟีเจอร์ห้าม import ฟีเจอร์อื่น** เพราะถ้าให้ฟีเจอร์หนึ่งเป็นเจ้าของ Entry จะเกิดการอ้างอิงวนกัน (entries ต้องใช้การตั้งค่า ส่วนตั้งค่าก็ต้องลบหรือนำเข้ารายการ) ของจะย้ายเข้า `shared/` เมื่อมีฟีเจอร์ใช้ตั้งแต่ 2 ฟีเจอร์ขึ้นไป รายละเอียดอยู่ที่ [ตัดสินใจ: โครงสร้างโฟลเดอร์และสถาปัตยกรรม](https://github.com/symphonicz/snow_flow/issues/18)

## ข้อตกลงที่ตั้งใจเลือก แม้จะดูเกินจำเป็น

- **use case ครบทุกคำสั่ง** แม้ตัวที่ทำแค่ `return repository.add(entry);` ก็เป็นไฟล์แยก และ **Cubit ห้ามเรียก repository ตรง** เจ้าของโปรเจกต์เลือกแบบตำราเพื่อให้ทั้งแอปใช้รูปแบบเดียวกัน อย่า "ลดรูป" ด้วยการให้ Cubit เรียก repository ตรง
- use case ที่ส่งต่องานอย่างเดียว **ไม่ต้องมี test ของตัวเอง** ตัวที่ต้องมี test คือตัวที่มี if, มีการคำนวณ หรือเรียกมากกว่า 1 repository
- use case คืนค่า `Either<Failure, T>` จาก **fpdart** และ `Failure` เป็น sealed class แยกชนิด ส่วนการนำเข้าที่ข้ามบางแถวนับเป็น `Right` พร้อมรายงานผล stream ส่งข้อผิดพลาดผ่านช่อง error ของ stream เอง

## การประกอบแอป

- **get_it** ลงทะเบียนด้วยมือ ไม่ใช้ `injectable` แต่ละส่วนมีไฟล์ลงทะเบียนของตัวเอง (`core_injection.dart`, `shared_injection.dart`, `<feature>_injection.dart`) และ `lib/injection.dart` เรียกตามลำดับ core → shared → features
- **go_router** ใช้ `StatefulShellRoute` สำหรับแถบล่าง/sidebar และใช้ URL แบบ `#` เพราะ GitHub Pages ตั้งค่าเซิร์ฟเวอร์ไม่ได้ (URL แบบสวยจะเจอ 404 ตอนรีเฟรช) ฟอร์มจดรายการไม่มี route ของตัวเอง
- `lib/injection.dart` และ `lib/router.dart` เป็น **composition root** (จุดประกอบแอป) ซึ่งเป็นสองไฟล์เดียวที่ได้รับข้อยกเว้นให้ import ทุกฟีเจอร์
- เลย์เอาต์มือถือ/เว็บ: แยกไฟล์เฉพาะโครงแอป (แถบล่าง/sidebar) และวิธีเปิดฟอร์ม ส่วนหน้าที่แค่จัดเรียงต่างกันใช้ไฟล์เดียวที่ปรับตามความกว้าง

## Considered Options

- **Clean Architecture แบบแบ่งชั้นก่อน** (`lib/domain`, `lib/data`, `lib/presentation/<feature>`): ไม่เลือก เจ้าของต้องการให้แต่ละฟีเจอร์เป็นก้อนของตัวเอง
- **ให้ฟีเจอร์หนึ่งเป็นเจ้าของ Entry แล้วฟีเจอร์อื่น import ข้ามไปใช้**: ไม่เลือก เพราะเกิดการอ้างอิงวน
- **ใช้ use case เฉพาะตอนที่มี logic**: ไม่เลือก ดูข้อตกลงข้างบน
- **`Result` เขียนเองด้วย sealed class / exception ธรรมดา**: ไม่เลือก ใช้ `Either` ตามแบบตำรา
- **`RepositoryProvider` หรือต่อสายเองด้วยมือ**: ไม่เลือก เพราะเมื่อมี use case 20 ตัวขึ้นไป รายการ provider จะยาวมาก
- **auto_route / `injectable`**: ไม่เลือก เพราะต้องใช้ build_runner ซึ่งโปรเจกต์เลี่ยงมาตลอด (ไม่ใช้ freezed ตาม [ADR 0002](0002-money-as-minor-units-and-map-storage.md))

## Consequences

- `test/architecture_test.dart` บังคับกฎ import: `domain/` ใช้ได้เฉพาะ allowlist (`dart:core`/`dart:async`/`dart:convert`, `fpdart`, `equatable`, `meta`, `uuid` และ `domain/` ด้วยกัน), ฟีเจอร์ห้าม import ฟีเจอร์อื่น, `core/` และ `shared/` ห้าม import ฟีเจอร์ ถ้าจะเพิ่ม package ใน `domain/` ต้องแก้ allowlist อย่างตั้งใจ
- เปิด lint `always_use_package_imports` เพื่อให้ test ตรวจ import ได้ (ห้ามใช้ `../`)
- `test/` มีโครงเหมือน `lib/` ใช้ fake ที่เขียนเอง (`test/helpers/fakes/`) เป็นหลัก ใช้ mocktail เฉพาะกรณีที่ fake จำลองได้ยาก และมี contract test ชุดเดียวที่รันกับทั้ง fake และ repository hive_ce จริง
- package ที่เพิ่ม: `fpdart`, `get_it`, `go_router` และ (dev) `mocktail`, `bloc_test`
