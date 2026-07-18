-- product_images untuk kemeja wanita (product id 1-20)
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
(20, 'assets/images/kemeja_wanita/20.jpeg', 1, 0);

-- product_images untuk kemeja pria (product id 21-25)
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(21, 'assets/images/kemeja_pria/1.jpeg', 1, 0),
(22, 'assets/images/kemeja_pria/2.jpeg', 1, 0),
(23, 'assets/images/kemeja_pria/3.jpeg', 1, 0),
(24, 'assets/images/kemeja_pria/4.jpeg', 1, 0),
(25, 'assets/images/kemeja_pria/5.jpeg', 1, 0);

-- product_images untuk rok (product id 26-31)
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(26, 'assets/images/Rok/1.jpeg', 1, 0),
(27, 'assets/images/Rok/2.jpeg', 1, 0),
(28, 'assets/images/Rok/3.jpeg', 1, 0),
(29, 'assets/images/Rok/4.jpeg', 1, 0),
(30, 'assets/images/Rok/5.jpeg', 1, 0),
(31, 'assets/images/Rok/6.jpeg', 1, 0);

-- product_images untuk celana (product id 32-36)
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(32, 'assets/images/celana/cowo1.jpeg', 1, 0),
(33, 'assets/images/celana/cowo2.jpeg', 1, 0),
(34, 'assets/images/celana/cowo3.jpeg', 1, 0),
(35, 'assets/images/celana/cowo4.jpeg', 1, 0),
(36, 'assets/images/celana/cowo5.jpeg', 1, 0);

-- product_variants untuk semua produk (S, M, L, XL)
INSERT IGNORE INTO product_variants (product_id, size, color, stock, price)
SELECT p.id, v.size, v.color, 25, p.price
FROM products p
CROSS JOIN (
  SELECT 'S' as size, 'Putih' as color UNION ALL
  SELECT 'M', 'Putih' UNION ALL
  SELECT 'L', 'Putih' UNION ALL
  SELECT 'XL', 'Putih'
) v
WHERE p.category_id = 2;

INSERT IGNORE INTO product_variants (product_id, size, color, stock, price)
SELECT p.id, v.size, v.color, 25, p.price
FROM products p
CROSS JOIN (
  SELECT 'S' as size, 'Hitam' as color UNION ALL
  SELECT 'M', 'Hitam' UNION ALL
  SELECT 'L', 'Hitam' UNION ALL
  SELECT 'XL', 'Hitam'
) v
WHERE p.category_id = 1;

INSERT IGNORE INTO product_variants (product_id, size, color, stock, price)
SELECT p.id, v.size, v.color, 25, p.price
FROM products p
CROSS JOIN (
  SELECT 'S' as size, 'Navy' as color UNION ALL
  SELECT 'M', 'Navy' UNION ALL
  SELECT 'L', 'Navy' UNION ALL
  SELECT 'XL', 'Navy'
) v
WHERE p.category_id IN (3, 4);

-- Payment methods
INSERT IGNORE INTO payment_methods (name, type, is_active) VALUES
('DANA', 'ewallet', 1),
('GoPay', 'ewallet', 1),
('OVO', 'ewallet', 1),
('BCA Transfer', 'bank_transfer', 1),
('Mandiri Transfer', 'bank_transfer', 1),
('COD (Bayar di Tempat)', 'cod', 1);

-- Shipping methods
INSERT IGNORE INTO shipping_methods (name, base_cost, is_active) VALUES
('Hemat Kargo - SPX Hemat', 10000, 1),
('Reguler - SPX Reguler', 15000, 1),
('Express - J&T Express', 25000, 1);
