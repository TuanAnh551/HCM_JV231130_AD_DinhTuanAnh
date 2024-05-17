--tạo database
CREATE DATABASE QLBH_DinhTuanAnh
COLLATE utf8_unicode_ci;
--sử dụng database
USE QLBH_DinhTuanAnh;

--tạo bảng
CREATE TABLE customer(
    cID INT,
    cName VARCHAR(25),
    cAge TINYINT
);

CREATE TABLE orders(
    oID INT,
    cID INT,
    oDate DATE,
    oTotalPrice INT
);

CREATE TABLE product(
    pID INT,
    pName VARCHAR(25),
    pPrice INT
);

CREATE TABLE orderdetail(
    oID INT,
    pID INT,
    odQTY INT
);

--thêm khóa chính, khóa phụ cho các bảng
ALTER TABLE customer
    ADD PRIMARY KEY(cID);

ALTER TABLE orders
    ADD PRIMARY KEY(oID),
    ADD FOREIGN KEY(cID) REFERENCES customer(cID);

ALTER TABLE product
    ADD PRIMARY KEY(pID);

ALTER TABLE orderdetail
    ADD FOREIGN KEY(oID) REFERENCES orders(oID),
    ADD FOREIGN KEY(pID) REFERENCES product(pID);

--thêm dữ liệu vào bảng
INSERT INTO customer(cID, cName, cAge)
VALUES
    (1, 'Minh Quan', 10),
    (2, 'Ngoc Oanh', 20),
    (3, 'Hong Ha', 50);

INSERT INTO orders(oID, cID, oDate)
VALUES
    (1, 1, '2006-03-21'),
    (2, 2, '2006-03-23'),
    (3, 1, '2006-03-16');

INSERT INTO product(pID, pName, pPrice)
VALUES
    (1, 'May Giat', 3),
    (2, 'Tu Lanh', 5),
    (3, 'Dieu Hoa', 7),
    (4, 'Quat', 1),
    (5, 'Bep Dien', 2);

INSERT INTO orderdetail(oID, pID, odQTY)
VALUES
    (1, 1, 3),
    (1, 3, 7),
    (1, 4, 2),
    (2, 1, 1),
    (3, 1, 8),
    (2, 5, 4),
    (2, 3, 3);

2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn
trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa
đơn mới hơn nằm trên:
SELECT oID, oDate, oTotalPrice
FROM orders
ORDER BY oDate DESC;

3. Hiển thị tên và giá của các sản phẩm có giá cao nhất:
SELECT pName, pPrice
FROM product
WHERE pPrice = (SELECT MAX(pPrice) FROM product);

4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản phẩm được mua bởi các khách đó:
SELECT cName, pName
FROM customer
INNER JOIN orders ON customer.cID = orders.cID
INNER JOIN orderdetail ON orders.oID = orderdetail.oID
INNER JOIN product ON orderdetail.pID = product.pID;

5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào:
SELECT cName
FROM customer
WHERE cID NOT IN (SELECT cID FROM orders);
6. Hiển thị chi tiết của từng hóa đơn:
SELECT orders.oID, pName, oDate, odQTY, pName, pPrice
FROM orders
INNER JOIN orderdetail ON orders.oID = orderdetail.oID
INNER JOIN product ON orderdetail.pID = product.pID
ORDER BY orders.oID;

7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng xuất hiện trong hóa đơn. Giá bán của từng loại được tính = odQTY*pPrice):
SELECT orders.oID, oDate, SUM(odQTY*pPrice) AS oTotalPrice
FROM orders
INNER JOIN orderdetail ON orders.oID = orderdetail.oID
INNER JOIN product ON orderdetail.pID = product.pID
GROUP BY oID;

8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị:
CREATE VIEW Sales AS
SELECT orders.oID, oDate, SUM(odQTY*pPrice) AS oTotalPrice
FROM orders
INNER JOIN orderdetail ON orders.oID = orderdetail.oID
INNER JOIN product ON orderdetail.pID = product.pID
GROUP BY oID;
9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng:
ALTER TABLE orderdetail
    DROP FOREIGN KEY orderdetail_ibfk_1,
    DROP FOREIGN KEY orderdetail_ibfk_2;
ALTER TABLE orders
    DROP PRIMARY KEY,
    DROP FOREIGN KEY orders_ibfk_1;
ALTER TABLE product
    DROP PRIMARY KEY;
ALTER TABLE customer
    DROP PRIMARY KEY;

10.Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa
mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo:
DELIMITER //
CREATE TRIGGER cusUpdate
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN
    UPDATE orders
    SET cID = NEW.cID
    WHERE cID = OLD.cID;
END;
//
DELIMITER ;

11.Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên
vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong bảng OrderDetail:
DELIMITER //
CREATE PROCEDURE delProduct(IN input_pName VARCHAR(25))
BEGIN
    DECLARE pID INT;
    SELECT pID INTO pID
    FROM product
    WHERE pName = input_pName;
    DELETE FROM orderdetail
    WHERE pID = pID;
    DELETE FROM product
    WHERE pName = input_pName;
END;
//
DELIMITER ;

--GỌI PROCEDURE
CALL delProduct('May Giat');


















