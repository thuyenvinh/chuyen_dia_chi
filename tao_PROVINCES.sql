-- Create table
create table PROVINCES
(
  id            NUMBER not null,
  province_code VARCHAR2(2) not null,
  name          VARCHAR2(255) not null,
  short_name    VARCHAR2(255) not null,
  code          VARCHAR2(5) not null,
  place_type    VARCHAR2(255) not null,
  country       VARCHAR2(10) not null,
  created_at    TIMESTAMP(6),
  updated_at    TIMESTAMP(6)
)

BEGIN

INSERT INTO provinces  VALUES (1, '01', 'Thành phố Hà Nội', 'Thành phố Hà Nội', 'HNI', 'Thành phố Trung Ương', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (2, '04', 'Cao Bằng', 'Cao Bằng', 'CBG', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (3, '08', 'Tuyên Quang', 'Tuyên Quang', 'TGQ', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (4, '11', 'Điện Biên', 'Điện Biên', 'DBN', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (5, '12', 'Lai Châu', 'Lai Châu', 'LCU', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (6, '14', 'Sơn La', 'Sơn La', 'SLA', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (7, '15', 'Lào Cai', 'Lào Cai', 'LCI', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (8, '19', 'Thái Nguyên', 'Thái Nguyên', 'TNN', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (9, '20', 'Lạng Sơn', 'Lạng Sơn', 'LSN', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (10, '22', 'Quảng Ninh', 'Quảng Ninh', 'QNH', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (11, '24', 'Bắc Ninh', 'Bắc Ninh', 'BNH', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (12, '25', 'Phú Thọ', 'Phú Thọ', 'PTO', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (13, '31', 'Thành phố Hải Phòng', 'Thành phố Hải Phòng', 'HPG', 'Thành phố Trung Ương', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (14, '33', 'Hưng Yên', 'Hưng Yên', 'HYN', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (15, '37', 'Ninh Bình', 'Ninh Bình', 'NBH', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (16, '38', 'Thanh Hóa', 'Thanh Hóa', 'THA', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (17, '40', 'Nghệ An', 'Nghệ An', 'NAN', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (18, '42', 'Hà Tĩnh', 'Hà Tĩnh', 'HTH', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (19, '44', 'Quảng Trị', 'Quảng Trị', 'QTI', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (20, '46', 'Thành phố Huế', 'Thành phố Huế', 'TTH', 'Thành phố Trung Ương', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (21, '48', 'Thành phố Đà Nẵng', 'Thành phố Đà Nẵng', 'DNG', 'Thành phố Trung Ương', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (22, '51', 'Quảng Ngãi', 'Quảng Ngãi', 'QNI', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (23, '52', 'Gia Lai', 'Gia Lai', 'GLI', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (24, '56', 'Khánh Hòa', 'Khánh Hòa', 'KHA', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (25, '66', 'Đắk Lắk', 'Đắk Lắk', 'DLK', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (26, '68', 'Lâm Đồng', 'Lâm Đồng', 'LDG', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (27, '75', 'Đồng Nai', 'Đồng Nai', 'DNI', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (28, '79', 'Thành phố Hồ Chí Minh', 'Thành phố Hồ Chí Minh', 'HCM', 'Thành phố Trung Ương', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (29, '80', 'Tây Ninh', 'Tây Ninh', 'TNH', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (30, '82', 'Đồng Tháp', 'Đồng Tháp', 'DTP', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (31, '86', 'Vĩnh Long', 'Vĩnh Long', 'VLG', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (32, '91', 'An Giang', 'An Giang', 'AGG', 'Tỉnh', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (33, '92', 'Thành phố Cần Thơ', 'Thành phố Cần Thơ', 'CTO', 'Thành phố Trung Ương', 'VN', NULL, NULL);
INSERT INTO provinces  VALUES (34, '96', 'Cà Mau', 'Cà Mau', 'CMU', 'Tỉnh', 'VN', NULL, NULL);
COMMIT;
end;