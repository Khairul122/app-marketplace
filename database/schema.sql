-- ==========================================
-- SCHEMA DATABASE: ootday_db
-- Deskripsi: Skema basis data MySQL untuk aplikasi marketplace Ootday Pelanggan
-- ==========================================

CREATE DATABASE IF NOT EXISTS ootday_db;
USE ootday_db;

-- 0. Tabel User/Pengguna (users)
CREATE TABLE IF NOT EXISTS users (
    uid VARCHAR(128) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'pelanggan', -- 'pelanggan' atau 'owner'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1. Tabel Toko (stores)
CREATE TABLE IF NOT EXISTS stores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_uid VARCHAR(128) NULL,
    owner_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    store_name VARCHAR(100) NOT NULL,
    description TEXT,
    address TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_uid) REFERENCES users(uid) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabel Kategori (categories)
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    icon_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabel Produk Utama (products)
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    category_id INT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    stock INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    description TEXT,
    sold_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabel Galeri Gambar Produk (product_images)
CREATE TABLE IF NOT EXISTS product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary TINYINT(1) DEFAULT 0,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabel Varian Produk (product_variants)
CREATE TABLE IF NOT EXISTS product_variants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    size VARCHAR(50) NOT NULL,
    color VARCHAR(50) NOT NULL,
    stock INT DEFAULT 0,
    price DECIMAL(15, 2) DEFAULT NULL,
    price_adjustment DECIMAL(15, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_variant (product_id, size, color)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tabel Alamat Pengguna (addresses)
CREATE TABLE IF NOT EXISTS addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    full_address TEXT NOT NULL,
    is_main TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Tabel Item Keranjang Belanja (cart_items)
CREATE TABLE IF NOT EXISTS cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    variant_id INT NOT NULL,
    quantity INT DEFAULT 1,
    is_selected TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Tabel Metode Pembayaran (payment_methods)
CREATE TABLE IF NOT EXISTS payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Tabel Metode Pengiriman (shipping_methods)
CREATE TABLE IF NOT EXISTS shipping_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    base_cost DECIMAL(15, 2) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Tabel Utama Pesanan/Transaksi (orders)
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    user_id VARCHAR(128) NOT NULL,
    store_id INT NOT NULL,
    payment_method_id INT,
    shipping_method_id INT,
    subtotal DECIMAL(15, 2) NOT NULL,
    shipping_cost DECIMAL(15, 2) NOT NULL,
    total_price DECIMAL(15, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'diproses',
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(uid) ON DELETE CASCADE,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Tabel Detail Item Pesanan (order_items)
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    variant_label VARCHAR(100) NOT NULL,
    image_url VARCHAR(255),
    price DECIMAL(15, 2) NOT NULL,
    quantity INT DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==========================================
-- SEEDER DATA AWAL (INITIAL DATA POPULATION)
-- ==========================================

-- A. Seeder Default Users
INSERT INTO users (uid, name, email, phone, role)
VALUES ('1', 'Guest User', 'guest@ootday.com', '08000000000', 'pelanggan')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- B. Seeder Default Store
INSERT INTO stores (id, owner_name, email, password, phone, store_name, description, address, status)
VALUES (1, 'Ootday Owner', 'owner@ootday.com', 'owner123', '081234567890', 'Ootday Fashion Store', 'Pusat Fashion Pria & Wanita Terlengkap', 'Jakarta, Indonesia', 'active')
ON DUPLICATE KEY UPDATE store_name=VALUES(store_name);

-- C. Seeder Default Categories
INSERT INTO categories (id, store_id, name, icon_url) VALUES
(1, 1, 'Pria', 'assets/images/pria icons.png'),
(2, 1, 'Wanita', 'assets/images/wanita_icons.png'),
(3, 1, 'rok', 'assets/images/rok_icons.png'),
(4, 1, 'celana', 'assets/images/celana_icons.png')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- D. Seeder Homepage Products
-- Produk 101-106 untuk tampilan awal halaman utama
INSERT INTO products (id, store_id, category_id, name, price, stock, status, description, sold_count) VALUES
(101, 1, 2, 'Trendy Red Dress', 150000.00, 100, 'active', 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.', 15),
(102, 1, 1, 'Casual White Shirt', 95000.00, 100, 'active', 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.', 25),
(103, 1, 1, 'Stylish Denim Jacket', 250000.00, 100, 'active', 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.', 8),
(104, 1, 3, 'Floral Summer Skirt', 120000.00, 100, 'active', 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.', 12),
(105, 1, 1, 'Black Leather Shoes', 300000.00, 100, 'active', 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.', 5),
(106, 1, 4, 'Classic Blue Jeans', 180000.00, 100, 'active', 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.', 30)
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

-- Gambar untuk Homepage Products
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(101, 'assets/images/Produk_1.png', 1, 0),
(102, 'assets/images/produk_2.png', 1, 0),
(103, 'assets/images/produk_3.png', 1, 0),
(104, 'assets/images/produk_4.png', 1, 0),
(105, 'assets/images/produk_5.png', 1, 0),
(106, 'assets/images/produk_6.png', 1, 0)
ON DUPLICATE KEY UPDATE image_url=VALUES(image_url);

-- Varian untuk Homepage Products
INSERT IGNORE INTO product_variants (product_id, size, color, stock, price, price_adjustment) VALUES
(101, 'S', 'Default', 25, 150000.00, 0.00),
(101, 'M', 'Default', 25, 150000.00, 0.00),
(101, 'L', 'Default', 25, 150000.00, 0.00),
(101, 'XL', 'Default', 25, 150000.00, 0.00),

(102, 'S', 'Default', 25, 95000.00, 0.00),
(102, 'M', 'Default', 25, 95000.00, 0.00),
(102, 'L', 'Default', 25, 95000.00, 0.00),
(102, 'XL', 'Default', 25, 95000.00, 0.00),

(103, 'S', 'Default', 25, 250000.00, 0.00),
(103, 'M', 'Default', 25, 250000.00, 0.00),
(103, 'L', 'Default', 25, 250000.00, 0.00),
(103, 'XL', 'Default', 25, 250000.00, 0.00),

(104, 'S', 'Default', 25, 120000.00, 0.00),
(104, 'M', 'Default', 25, 120000.00, 0.00),
(104, 'L', 'Default', 25, 120000.00, 0.00),
(104, 'XL', 'Default', 25, 120000.00, 0.00),

(105, 'S', 'Default', 25, 300000.00, 0.00),
(105, 'M', 'Default', 25, 300000.00, 0.00),
(105, 'L', 'Default', 25, 300000.00, 0.00),
(105, 'XL', 'Default', 25, 300000.00, 0.00),

(106, 'S', 'Default', 25, 180000.00, 0.00),
(106, 'M', 'Default', 25, 180000.00, 0.00),
(106, 'L', 'Default', 25, 180000.00, 0.00),
(106, 'XL', 'Default', 25, 180000.00, 0.00);


-- E. Kemeja Wanita (Kategori 2: id 1 s.d. 20)
INSERT INTO products (id, store_id, category_id, name, price, stock, status, description) VALUES
(1, 1, 2, 'Pink Ribbon Bow Shirt – Kemeja Pita Cantik', 95000.00, 100, 'active', 'Kemeja wanita elegan dengan detail pita cantik. Cocok untuk kerja maupun hangout.'),
(2, 1, 2, 'Cream Bow Ruffle Blouse', 90000.00, 100, 'active', 'Blouse krem dengan detail ruffle yang anggun dan feminin.'),
(3, 1, 2, 'Wide Collar Drawstring Sleeve Blouse', 95000.00, 100, 'active', 'Blouse dengan kerah lebar dan lengan drawstring yang modis.'),
(4, 1, 2, 'Kemeja Wanita Elegan Style 4', 115000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(5, 1, 2, 'Kemeja Wanita Elegan Style 5', 120000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(6, 1, 2, 'Kemeja Wanita Elegan Style 6', 125000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(7, 1, 2, 'Kemeja Wanita Elegan Style 7', 130000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(8, 1, 2, 'Kemeja Wanita Elegan Style 8', 135000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(9, 1, 2, 'Kemeja Wanita Elegan Style 9', 140000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(10, 1, 2, 'Kemeja Wanita Elegan Style 10', 145000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(11, 1, 2, 'Kemeja Wanita Elegan Style 11', 150000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(12, 1, 2, 'Kemeja Wanita Elegan Style 12', 155000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(13, 1, 2, 'Kemeja Wanita Elegan Style 13', 160000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(14, 1, 2, 'Kemeja Wanita Elegan Style 14', 165000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(15, 1, 2, 'Kemeja Wanita Elegan Style 15', 170000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(16, 1, 2, 'Kemeja Wanita Elegan Style 16', 175000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(17, 1, 2, 'Kemeja Wanita Elegan Style 17', 180000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(18, 1, 2, 'Kemeja Wanita Elegan Style 18', 185000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(19, 1, 2, 'Kemeja Wanita Elegan Style 19', 190000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.'),
(20, 1, 2, 'Kemeja Wanita Elegan Style 20', 195000.00, 100, 'active', 'Kemeja wanita elegan dan modern. Sangat cocok untuk kerja maupun hangout.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

-- Gambar Kemeja Wanita
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(1, 'assets/images/kemeja_wanita/1.jpeg', 1, 0),
(2, 'assets/images/kemeja_wanita/2.jpeg', 1, 0),
(3, 'assets/images/kemeja_wanita/3.jpeg', 1, 0),
(4, 'assets/images/kemeja_wanita/4.jpeg', 1, 0),
(5, 'assets/images/kemeja_wanita/5.jpeg', 1, 0),
(6, 'assets/images/kemeja_wanita/6.jpeg', 1, 0),
(7, 'assets/images/kemeja_wanita/7.jpeg', 1, 0),
(8, 'assets/images/kemeja_wanita/8.jpeg', 1, 0),
(9, 'assets/images/kemeja_wanita/9.jpeg', 1, 0),
(10, 'assets/images/kemeja_wanita/10.jpeg', 1, 0),
(11, 'assets/images/kemeja_wanita/11.jpeg', 1, 0),
(12, 'assets/images/kemeja_wanita/12.jpeg', 1, 0),
(13, 'assets/images/kemeja_wanita/13.jpeg', 1, 0),
(14, 'assets/images/kemeja_wanita/14.jpeg', 1, 0),
(15, 'assets/images/kemeja_wanita/15.jpeg', 1, 0),
(16, 'assets/images/kemeja_wanita/16.jpeg', 1, 0),
(17, 'assets/images/kemeja_wanita/17.jpeg', 1, 0),
(18, 'assets/images/kemeja_wanita/18.jpeg', 1, 0),
(19, 'assets/images/kemeja_wanita/19.jpeg', 1, 0),
(20, 'assets/images/kemeja_wanita/20.jpeg', 1, 0)
ON DUPLICATE KEY UPDATE image_url=VALUES(image_url);


-- F. Kemeja Pria (Kategori 1: id 21 s.d. 25)
INSERT INTO products (id, store_id, category_id, name, price, stock, status, description) VALUES
(21, 1, 1, 'Kemeja Pria Exclusive 1', 160000.00, 100, 'active', 'Kemeja pria exclusive dengan bahan premium, nyaman dan stylish.'),
(22, 1, 1, 'Kemeja Pria Exclusive 2', 170000.00, 100, 'active', 'Kemeja pria exclusive dengan bahan premium, nyaman dan stylish.'),
(23, 1, 1, 'Kemeja Pria Exclusive 3', 180000.00, 100, 'active', 'Kemeja pria exclusive dengan bahan premium, nyaman dan stylish.'),
(24, 1, 1, 'Kemeja Pria Exclusive 4', 190000.00, 100, 'active', 'Kemeja pria exclusive dengan bahan premium, nyaman dan stylish.'),
(25, 1, 1, 'Kemeja Pria Exclusive 5', 200000.00, 100, 'active', 'Kemeja pria exclusive dengan bahan premium, nyaman dan stylish.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

-- Gambar Kemeja Pria
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(21, 'assets/images/kemeja_pria/1.jpeg', 1, 0),
(22, 'assets/images/kemeja_pria/2.jpeg', 1, 0),
(23, 'assets/images/kemeja_pria/3.jpeg', 1, 0),
(24, 'assets/images/kemeja_pria/4.jpeg', 1, 0),
(25, 'assets/images/kemeja_pria/5.jpeg', 1, 0)
ON DUPLICATE KEY UPDATE image_url=VALUES(image_url);


-- G. Rok (Kategori 3: id 26 s.d. 31)
INSERT INTO products (id, store_id, category_id, name, price, stock, status, description) VALUES
(26, 1, 3, 'Asymmetrical Layered Floral Skirt', 155000.00, 100, 'active', 'Rok cantik koleksi terbaru yang anggun dan menawan.'),
(27, 1, 3, 'Floral Pleated Long Skirt', 100000.00, 100, 'active', 'Rok lipit panjang dengan motif bunga yang elegan.'),
(28, 1, 3, 'Rok Cantik Koleksi 3', 150000.00, 100, 'active', 'Rok cantik koleksi terbaru yang anggun dan menawan.'),
(29, 1, 3, 'Rok Cantik Koleksi 4', 160000.00, 100, 'active', 'Rok cantik koleksi terbaru yang anggun dan menawan.'),
(30, 1, 3, 'Rok Cantik Koleksi 5', 170000.00, 100, 'active', 'Rok cantik koleksi terbaru yang anggun dan menawan.'),
(31, 1, 3, 'Rok Cantik Koleksi 6', 180000.00, 100, 'active', 'Rok cantik koleksi terbaru yang anggun dan menawan.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

-- Gambar Rok
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(26, 'assets/images/Rok/1.jpeg', 1, 0),
(27, 'assets/images/Rok/2.jpeg', 1, 0),
(28, 'assets/images/Rok/3.jpeg', 1, 0),
(29, 'assets/images/Rok/4.jpeg', 1, 0),
(30, 'assets/images/Rok/5.jpeg', 1, 0),
(31, 'assets/images/Rok/6.jpeg', 1, 0)
ON DUPLICATE KEY UPDATE image_url=VALUES(image_url);


-- H. Celana (Kategori 4: id 32 s.d. 36)
INSERT INTO products (id, store_id, category_id, name, price, stock, status, description) VALUES
(32, 1, 4, 'High Waist Slim Fit Denim Pants', 150000.00, 100, 'active', 'Celana denim slim fit high waist yang trendy.'),
(33, 1, 4, 'Celana Trend Terbaru 2', 130000.00, 100, 'active', 'Celana trend terbaru dengan desain modern dan bahan melar/nyaman.'),
(34, 1, 4, 'Celana Trend Terbaru 3', 140000.00, 100, 'active', 'Celana trend terbaru dengan desain modern dan bahan melar/nyaman.'),
(35, 1, 4, 'Celana Trend Terbaru 4', 150000.00, 100, 'active', 'Celana trend terbaru dengan desain modern dan bahan melar/nyaman.'),
(36, 1, 4, 'Celana Trend Terbaru 5', 160000.00, 100, 'active', 'Celana trend terbaru dengan desain modern dan bahan melar/nyaman.')
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price);

-- Gambar Celana
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(32, 'assets/images/celana/cowo1.jpeg', 1, 0),
(33, 'assets/images/celana/cowo2.jpeg', 1, 0),
(34, 'assets/images/celana/cowo3.jpeg', 1, 0),
(35, 'assets/images/celana/cowo4.jpeg', 1, 0),
(36, 'assets/images/celana/cowo5.jpeg', 1, 0)
ON DUPLICATE KEY UPDATE image_url=VALUES(image_url);


-- I. Varian Otomatis untuk Semua Produk Lainnya
-- Kemeja Wanita (Category 2) -> Putih (S, M, L, XL)
INSERT IGNORE INTO product_variants (product_id, size, color, stock, price, price_adjustment)
SELECT p.id, v.size, v.color, 25, p.price, 0.00
FROM products p
CROSS JOIN (
  SELECT 'S' as size, 'Putih' as color UNION ALL
  SELECT 'M', 'Putih' UNION ALL
  SELECT 'L', 'Putih' UNION ALL
  SELECT 'XL', 'Putih'
) v
WHERE p.category_id = 2 AND p.id <= 20;

-- Kemeja Pria (Category 1) -> Hitam (S, M, L, XL)
INSERT IGNORE INTO product_variants (product_id, size, color, stock, price, price_adjustment)
SELECT p.id, v.size, v.color, 25, p.price, 0.00
FROM products p
CROSS JOIN (
  SELECT 'S' as size, 'Hitam' as color UNION ALL
  SELECT 'M', 'Hitam' UNION ALL
  SELECT 'L', 'Hitam' UNION ALL
  SELECT 'XL', 'Hitam'
) v
WHERE p.category_id = 1 AND p.id <= 25;

-- Rok (Category 3) dan Celana (Category 4) -> Navy (S, M, L, XL)
INSERT IGNORE INTO product_variants (product_id, size, color, stock, price, price_adjustment)
SELECT p.id, v.size, v.color, 25, p.price, 0.00
FROM products p
CROSS JOIN (
  SELECT 'S' as size, 'Navy' as color UNION ALL
  SELECT 'M', 'Navy' UNION ALL
  SELECT 'L', 'Navy' UNION ALL
  SELECT 'XL', 'Navy'
) v
WHERE p.category_id IN (3, 4) AND p.id <= 36;


-- J. Payment Methods
INSERT INTO payment_methods (id, name, type, is_active) VALUES
(1, 'DANA', 'ewallet', 1),
(2, 'GoPay', 'ewallet', 1),
(3, 'OVO', 'ewallet', 1),
(4, 'BCA Transfer', 'bank_transfer', 1),
(5, 'Mandiri Transfer', 'bank_transfer', 1),
(6, 'COD (Bayar di Tempat)', 'cod', 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), type=VALUES(type), is_active=VALUES(is_active);


-- K. Shipping Methods
INSERT INTO shipping_methods (id, name, base_cost, is_active) VALUES
(1, 'Hemat Kargo - SPX Hemat', 10000.00, 1),
(2, 'Reguler - SPX Reguler', 15000.00, 1),
(3, 'Express - J&T Express', 25000.00, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), base_cost=VALUES(base_cost), is_active=VALUES(is_active);
