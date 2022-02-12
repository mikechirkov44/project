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
WHERE n.name = 'Ткань';

SELECT * FROM vw_ord_and_nmc;

-- считаем кол-во ожидаемых заказов по месяцам

SELECT 
	MONTHNAME (plan_delivery_date) AS month_name, 
	COUNT(*) AS cnt
FROM orders
GROUP BY month_name 
ORDER BY cnt DESC;

-- считаем среднюю стоимость товарной позиции в заказе и записываем ее в переменную.
-- далее выберем товарные позиции, цена которых выше средней по всем заказам.

SELECT AVG(unit_price) INTO @avg_price FROM orders;
SELECT * FROM orders WHERE unit_price > @avg_price; 

-- посмотреть все заявки в отдел снабжения из основого производства (id = 2)

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

-- Посчитаем кол-во поставщиков по странам
SELECT 
	COUNT(*) AS 'Кол-во поставщиков',
	country AS 'Страна'
FROM suppliers 
GROUP BY country 
ORDER BY id DESC;

-- Самый "опытный" менеджер:

SELECT id, firstname, lastname, started_at FROM managers ORDER BY started_at LIMIT 1;

-- Стаж работы менеджеров отделов снабжения и аутсорсинга в годах

SELECT firstname, lastname, `position`, TIMESTAMPDIFF(YEAR, started_at, NOW()) AS 'Стаж' FROM managers;

-- Функция для расчета активности отделов (процент заявок в отдел снабжения)

DROP FUNCTION IF EXISTS suppliers_base.dep_activity;

CREATE FUNCTION suppliers_base.dep_activity(dep_id BIGINT)
RETURNS FLOAT READS SQL DATA 
BEGIN
	DECLARE requests_from_dep INT; -- кол-во заявок в отдел снабжения
	DECLARE total_requests_qty INT; -- общее кол-во заявок

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

-- Посчитаем % заявок в отдел снабжения от Отдела продаж (id = 6)
SELECT suppliers_base.dep_activity(6) AS '% заявок в отдел снабжения';

-- Вывести ТОП-3 контрагента по кол-ву заказов
CREATE OR REPLACE VIEW vw_top_suppliers AS
SELECT
	supplier_id,
	(SELECT company_name FROM suppliers WHERE id = supplier_id) AS 'Контрагент',
	COUNT(*) AS cnt
FROM orders
GROUP BY supplier_id
ORDER BY cnt DESC;

SELECT * FROM vw_top_suppliers LIMIT 3;

-- Процедура для осуществления платежей при помощи транзакции с ветвлением.
-- В качестве аргументов передаем сумму платежа и ID заказа. 

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
		 	SELECT 'Вы пытаетесь совершить платеж с отрицательной суммой!';
		ELSE 
			SELECT 'Сумма платежа превышает остаток по задолженности!';
	END CASE;
END

-- Проверим работу процедуры arrange_payment:

CALL arrange_payment (2000, 1);
CALL arrange_payment (3040404, 1);

-- Процедура для размещения заявки в отдел снабжения.

DROP PROCEDURE IF EXISTS suppliers_base.send_request;
CREATE PROCEDURE suppliers_base.send_request (IN nom_id BIGINT, IN dep_id BIGINT, IN qty INT)
BEGIN
		START TRANSACTION;
		INSERT INTO requests (nomenclature_id, department_id, request_quanity, status)
		VALUES (nom_id, dep_id, qty, 'new-request');
		COMMIT;
		SELECT * FROM requests ORDER BY id  DESC LIMIT 1;
END

-- Проверим работы процедуры
CALL send_request (5, 3, 350);

-- Триггер - запрет на размещение заказов у поставщиков со статусом "Blocked"

DROP TRIGGER IF EXISTS check_if_supplier_blocked;
CREATE TRIGGER check_if_supplier_blocked AFTER INSERT ON orders
FOR EACH ROW
BEGIN
		SELECT `status` INTO @supplier_status FROM suppliers 
		WHERE id = (SELECT supplier_id FROM orders WHERE id = NEW.id); 
		IF(@supplier_status = 'blocked') THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Размещение заказов у поставщиков со статусом "Blocked" запрещено';
     	END IF;
END

-- Функция для подсчета % англоговорящих менеджеров

DROP FUNCTION IF EXISTS suppliers_base.english_speakers;
CREATE FUNCTION suppliers_base.english_speakers()
RETURNS FLOAT READS SQL DATA
BEGIN
	SET @speak_engl = (SELECT COUNT(*) FROM managers WHERE speak_english = b'1');
	SET @total_managers = (SELECT COUNT(*) FROM managers);
	RETURN truncate((@speak_engl / @total_managers), 2) * 100;  
END
-- проверим работу функции
SELECT english_speakers();

