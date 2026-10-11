# ตั้งค่า GitHub

สิ่งที่เจ้าของ repo ต้องตั้งเองใน GitHub เพื่อให้ CI และ deploy เว็บทำงาน ([ตัดสินใจ: วิธี deploy เว็บขึ้น GitHub Pages](https://github.com/symphonicz/snow_flow/issues/40))

workflow อยู่ใน `.github/workflows/`:

- `ci.yml` (ชื่อ **CI**): `flutter analyze` + `flutter test` ทุก PR
- `deploy.yml` (ชื่อ **Deploy web**): merge เข้า `main` → ตรวจซ้ำ → build → deploy ขึ้น `https://symphonicz.github.io/snow_flow/` ข้ามเมื่อแก้แค่ `docs/**` หรือ `*.md`, กดรันเองได้ที่ Actions → Deploy web → **Run workflow**

## 1. Pages

- [x] Settings → Pages → Build and deployment → Source = **GitHub Actions**

ต้องตั้งก่อน merge PR แรกที่มี `deploy.yml` ไม่อย่างนั้น job `deploy` รอบแรกจะล้ม (ตั้งแล้วกด Run workflow ใหม่ได้)

## 2. Ruleset ของ `main`

Settings → Rules → Rulesets → `protect-main`

- [x] Target = branch default (`main`)
- [x] Require a pull request before merging, required approvals = 0
- [x] Restrict deletions, Block force pushes
- [x] Bypass list: Repository admin แบบ *For pull requests only*
- [x] Require status checks to pass → เพิ่ม check **`test`** (จาก GitHub Actions) และ**ไม่ติ๊ก** "Require branches to be up to date before merging"

ข้อควรระวัง:

- check จะค้นเจอในช่องเพิ่มก็ต่อเมื่อ workflow CI รันมาแล้วอย่างน้อยหนึ่งครั้ง (เปิด PR ใดก็ได้)
- ชื่อ check มาจากชื่อ job `test` ใน `ci.yml` ถ้าเปลี่ยนชื่อ job ต้องแก้ ruleset ด้วย ไม่อย่างนั้นทุก PR จะค้างรอ check ที่ไม่มีวันมา

## 3. PR จากคนนอก

- [x] Settings → Actions → General → Approval for running fork pull request workflows = **Require approval for all external contributors**

workflow ห้ามใช้ `pull_request_target` และไม่มี secret (job deploy ใช้แค่สิทธิ์ `pages: write` และ `id-token: write`)

## ตั้งผ่าน `gh`

ทุกข้อด้านบนตั้งผ่าน `gh api` ตาม comment ใน [#40](https://github.com/symphonicz/snow_flow/issues/40) (Claude ตั้งให้ได้ แต่ต้องอนุญาตใหม่ทุกครั้ง) ถ้าต้องตั้ง repo ใหม่ ทำตามรายการด้านบนได้ทั้งในหน้าเว็บและผ่าน `gh api`:

- Pages: `gh api -X POST repos/<owner>/<repo>/pages -f build_type=workflow`
- check `test` ใน ruleset: rule `required_status_checks` ที่มี `{"context": "test", "integration_id": 15368}` (15368 = GitHub Actions) และ `strict_required_status_checks_policy: false`