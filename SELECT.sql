USE suppliers_base;

CREATE OR REPLACE VIEW vw_ord_and_nmc AS
SELECT
	o.order_number,
	n.name,
	n.number,
	o.quantity,
	n.units,
	o.unit_price, 
	o.total_amount, 
	o.plan_delivery_date
FROM orders o
JOIN nomenclature n ON n.id = o.nomenclature_id
WHERE n.name = '�����';

SELECT * FROM vw_ord_and_nmc;

-- ������� ���-�� ��������� ������� �� �������

SELECT 
	MONTHNAME (plan_delivery_date) AS month_name, 
	COUNT(*) AS cnt
FROM orders
GROUP BY month_name 
ORDER BY cnt DESC;

-- ������� ������� ��������� �������� ������� � ������ � ���������� �� � ����������.
-- ����� ������� �������� �������, ���� ������� ���� ������� �� ���� �������.

SELECT AVG(unit_price) INTO @avg_price FROM orders;
SELECT * FROM orders WHERE unit_price > @avg_price; 

-- ���������� ��� ������ � ����� ��������� �� �������� ������������ (id = 2)

SELECT 
	r.id,
	r.request_date_at,
	r.request_quanity, 
	r.nomenclature_id, 
	n.name, 
	n.`number` 
FROM departments d 
JOIN requests r ON d.id = r.department_id
JOIN nomenclature n ON r.nomenclature_id = n.id
WHERE d.id = 2;

-- ��������� ���-�� ����������� �� �������
SELECT 
	COUNT(*) AS '���-�� �����������',
	country AS '������'
FROM suppliers 
GROUP BY country 
ORDER BY id DESC;

-- ����� "�������" ��������:

SELECT id, firstname, lastname, started_at FROM managers ORDER BY started_at LIMIT 1;

-- ���� ������ ���������� ������� ��������� � ����������� � �����

SELECT firstname, lastname, `position`, TIMESTAMPDIFF(YEAR, started_at, NOW()) AS '����' FROM managers;

-- ������� ��� ������� ���������� ������� (������� ������ � ����� ���������)

DROP FUNCTION IF EXISTS suppliers_base.dep_activity;

CREATE FUNCTION suppliers_base.dep_activity(dep_id BIGINT)
RETURNS FLOAT READS SQL DATA 
BEGIN
	DECLARE requests_from_dep INT; -- ���-�� ������ � ����� ���������
	DECLARE total_requests_qty INT; -- ����� ���-�� ������

	SET requests_from_dep = (
		SELECT count(*) 
		FROM requests
		WHERE department_id  = (SELECT id FROM departments WHERE id = dep_id) 
		);
	SELECT count(*)
	INTO  total_requests_qty 
	FROM requests; 
	
	RETURN truncate((requests_from_dep / total_requests_qty),2) * 100;
END

-- ��������� % ������ � ����� ��������� �� ������ ������ (id = 6)
SELECT suppliers_base.dep_activity(6) AS '% ������ � ����� ���������';

-- ������� ���-3 ����������� �� ���-�� �������
CREATE OR REPLACE VIEW vw_top_suppliers AS
SELECT
	supplier_id,
	(SELECT company_name FROM suppliers WHERE id = supplier_id) AS '����������',
	COUNT(*) AS cnt
FROM orders
GROUP BY supplier_id
ORDER BY cnt DESC;

SELECT * FROM vw_top_suppliers LIMIT 3;

-- ��������� ��� ������������� �������� ��� ������ ���������� � ����������.
-- � �������� ���������� �������� ����� ������� � ID ������. 

DROP PROCEDURE IF EXISTS suppliers_base.arrange_payment;
CREATE PROCEDURE suppliers_base.arrange_payment(IN amount FLOAT, IN id BIGINT)
BEGIN
	SET @order_balance = (SELECT balance FROM payments WHERE order_id = id);
	CASE 
		WHEN amount <= @order_balance THEN 
			START TRANSACTION;
			SELECT paid_amount INTO @already_paid FROM payments WHERE order_id = id;
			UPDATE payments SET paid_amount = @already_paid + amount  WHERE order_id = id;
			SELECT balance, paid_amount FROM payments WHERE order_id = id;
			COMMIT;
		WHEN amount < 0 THEN 
		 	SELECT '�� ��������� ��������� ������ � ������������� ������!';
		ELSE 
			SELECT '����� ������� ��������� ������� �� �������������!';
	END CASE;
END

-- �������� ������ ��������� arrange_payment:

CALL arrange_payment (2000, 1);
CALL arrange_payment (3040404, 1);

-- ��������� ��� ���������� ������ � ����� ���������.

DROP PROCEDURE IF EXISTS suppliers_base.send_request;
CREATE PROCEDURE suppliers_base.send_request (IN nom_id BIGINT, IN dep_id BIGINT, IN qty INT)
BEGIN
		START TRANSACTION;
		INSERT INTO requests (nomenclature_id, department_id, request_quanity, status)
		VALUES (nom_id, dep_id, qty, 'new-request');
		COMMIT;
		SELECT * FROM requests ORDER BY id  DESC LIMIT 1;
END

-- �������� ������ ���������
CALL send_request (5, 3, 350);

-- ������� - ������ �� ���������� ������� � ����������� �� �������� "Blocked"

DROP TRIGGER IF EXISTS check_if_supplier_blocked;
CREATE TRIGGER check_if_supplier_blocked AFTER INSERT ON orders
FOR EACH ROW
BEGIN
		SELECT `status` INTO @supplier_status FROM suppliers 
		WHERE id = (SELECT supplier_id FROM orders WHERE id = NEW.id); 
		IF(@supplier_status = 'blocked') THEN
		SIGNAL SQLSTATE '45000' SET message_text = '���������� ������� � ����������� �� �������� "Blocked" ���������';
     	END IF;
END

-- ������� ��� �������� % �������������� ����������

DROP FUNCTION IF EXISTS suppliers_base.english_speakers;
CREATE FUNCTION suppliers_base.english_speakers()
RETURNS FLOAT READS SQL DATA
BEGIN
	SET @speak_engl = (SELECT COUNT(*) FROM managers WHERE speak_english = b'1');
	SET @total_managers = (SELECT COUNT(*) FROM managers);
	RETURN truncate((@speak_engl / @total_managers), 2) * 100;  
END
-- �������� ������ �������
SELECT english_speakers();

