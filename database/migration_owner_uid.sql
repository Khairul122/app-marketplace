-- Migrasi: hubungkan stores ke Firebase UID owner
-- Jalankan sekali di database yang sudah ada (tanpa recreate schema)

USE ootday_db;

ALTER TABLE stores
  ADD COLUMN IF NOT EXISTS owner_uid VARCHAR(128) NULL AFTER id;

-- Catatan: MySQL versi lama tanpa IF NOT EXISTS bisa gagal jika kolom sudah ada.
-- Alternatif manual:
-- ALTER TABLE stores ADD COLUMN owner_uid VARCHAR(128) NULL AFTER id;
