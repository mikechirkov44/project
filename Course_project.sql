/*
***БАЗА ДАННЫХ SIPPLIERS_BASE***
Автор: Чирков Михаил, 2022
База данных предназначена для хранения и обработки данных 
по заказам поставщикам. Содержит информацию об ответственных сотрудниках (managers), 
поставщиках(suppliers), товарных группах (product_groups), номенклатуре заказываемых 
товаров и услуг (nomenclature), размещенных заказов (orders) и платежах (payments).
*/

DROP DATABASE IF EXISTS suppliers_base;
CREATE DATABASE suppliers_base CHARACTER SET 'utf8';
USE suppliers_base;

-- Создаем таблицу Managers, в которой будут храниться
-- данные о сотрудниках: менеджерах отдела снабжения и аустсорсинга:
-- Имя, Фамилия, Должность, Email, Tелефон, Дата трудоустройства (важно для понимания опыта сотрудника). 

DROP TABLE IF EXISTS managers;
CREATE TABLE managers (
	id SERIAL PRIMARY KEY, 
	firstname VARCHAR (20) COMMENT 'Фамилия',
	lastname VARCHAR (20) COMMENT 'Имя',
	email VARCHAR (30) UNIQUE COMMENT 'Email',
	phone BIGINT COMMENT 'Телефон',
	started_at DATE DEFAULT NULL COMMENT 'Работает с..',
	`position` ENUM ('Менеджер ОС', 'Менеджер АУ') COMMENT 'Должность сотрудника',
	speak_english BIT DEFAULT 0, -- владение иностранными языками
	INDEX managers_firstname_lastname_idx(firstname, lastname)
) COMMENT = 'Менеджеры отдела снабжения и аутсорсинга';	

-- Создаем таблицу Suppliers, в которой будут храниться 
-- данные о поставщиках: Наименование, контактное лицо, страна, город, контактная информация, рейтинг поставщика,
-- и его текущий статус - активный, неактивный, заблокирован. 

DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
	id SERIAL PRIMARY KEY, 
	product_group_id BIGINT UNSIGNED,  
	company_name VARCHAR (100) NOT NULL COMMENT 'Наименование контрагента',
	contact_person VARCHAR (50) NOT NULL COMMENT 'Контактное лицо',
	contact_title VARCHAR (30) NOT NULL COMMENT 'Должность контактного лица',
	country VARCHAR (30) COMMENT 'Страна',
	city VARCHAR (30) COMMENT 'Город', 
	phone BIGINT CHECK (phone !='') COMMENT 'Телефон', 
	email VARCHAR (30) CHECK (email !='') COMMENT 'Email', 
	`status` ENUM ('active', 'not-active', 'blocked') COMMENT 'Текущий статус',
	`raiting` ENUM ('HIGH-A', 'MEDIUM-B', 'LOW-C') COMMENT 'Рейтинг',
	added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата добавления в БД',
	INDEX suppliers_name_idx(company_name)
	
) COMMENT = 'Поставщики';

-- Создаем таблицу Product_group, в которой будут храниться
-- данные о возможных подгруппах товаров: Наименование группы (например Ткани, Фурнитура).
-- Все подгруппы будут входить в три основные группы: сырье, готовая продукция, услуги.

DROP TABLE IF EXISTS product_groups;
CREATE TABLE product_groups (
 	id SERIAL, 
	product_group_name VARCHAR (50) NOT NULL COMMENT 'Товарная группа',
	main_group ENUM ('1211 - сырье', '1212 - готовая продукция', '1213 - услуги', '1215 - прочее')
) COMMENT = 'Товарные группы';

-- Задаем внешний ключ для таблицы Suppliers
ALTER TABLE suppliers ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_group_id) REFERENCES product_groups(id)
ON UPDATE CASCADE ON DELETE set NULL;

-- Создаем таблицу Nomenclature, в которой будут храниться
-- данные о товарных позиция: Артикул, Наименование, Группа.

DROP TABLE IF EXISTS nomenclature;
CREATE TABLE nomenclature (
 	id SERIAL PRIMARY KEY,
 	group_id BIGINT UNSIGNED,
	`number` INT (100) NOT NULL UNIQUE COMMENT 'Артикул/Номер', 
	name VARCHAR (255) NOT NULL COMMENT 'Наименование', 
	units ENUM ('шт.', 'м', 'п.м.') COMMENT 'Ед.измерения',
FOREIGN KEY (group_id) REFERENCES product_groups(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Номенклатура';

-- Создаем таблицу Orders, в которой будут храниться

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL PRIMARY KEY, 
	manager_id 	BIGINT UNSIGNED,
	nomenclature_id BIGINT UNSIGNED, 
	supplier_id BIGINT UNSIGNED,
	order_number BIGINT UNSIGNED UNIQUE NOT NULL COMMENT 'Номер заказа',
	quantity INT UNSIGNED NOT NULL COMMENT 'Кол-во', 
	unit_price DECIMAL (11,2) NOT NULL COMMENT 'Цена за ед.', 
	discount FLOAT (3,2) UNSIGNED COMMENT 'К-т скидки', -- к-т скидки: 1 - если нет скидки, 0.7- скидка 30%, 0.9 - скидка 10%
	total_amount FLOAT AS (quantity * unit_price * discount) COMMENT 'Итого сумма заказа', 
	order_status ENUM ('fully-confirmed', 'partly-confirmed', 'waiting confirmation', 'rejected', 'delayed') COMMENT 'Статус заказа',
	plan_delivery_date DATE COMMENT 'Плановая дата поставки',
	fact_delivery_date DATE DEFAULT NULL COMMENT 'Фактическая дата поставки',
	total_delay_days TINYINT AS (fact_delivery_date - plan_delivery_date) COMMENT 'Отлонение План/Факт, дн.',
	order_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата заказа',
FOREIGN KEY (manager_id) REFERENCES managers(id) ON UPDATE CASCADE ON DELETE SET NULL,
FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id) ON UPDATE CASCADE ON DELETE SET NULL,
FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = 'Заказы поставщикам';
 
-- Создаем таблицу Payments, в которой будут храниться
-- данные о платежах пл контрагентам: Дата платежа, Внешний ключ на таблицу заказов, 
-- Сумма платежа, сумма внесенной предоплаты по заказу, сумма балансового платежа.

DROP TABLE IF EXISTS payments; 
CREATE TABLE payments (
	id SERIAL PRIMARY KEY,
	order_id BIGINT UNSIGNED,
	payment_date_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата платежа',
	payment_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Дата обновления платежа', -- например при доплате
	paid_amount DECIMAL (11,2) COMMENT 'Оплачено (предоплата)',
	amount DECIMAL (11,2) COMMENT 'Сумма платежа ИТОГО', 
	balance FLOAT AS (amount - paid_amount) COMMENT 'Осталось оплатить',
FOREIGN KEY (order_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = 'Платежи поставщикам';



-- Создаем таблицу Departments, в которой будут храниться
-- данные об отделах и департаментах предприятия (id, имя, дата создания). 

DROP TABLE IF EXISTS departments; 
CREATE TABLE departments (
	id SERIAL PRIMARY KEY,
	department_name VARCHAR (255) NOT NULL UNIQUE COMMENT 'Департамент',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'Департаменты';

-- Создаем таблицу Requests, в которой будут храниться
-- данные о поступающих заявках в отдел снабжения: внешние ключи nomenclature_id, department_id, 
-- требуемое кол-во, статус заявки, дата заявки, дата закрытия заявки (поступление товаров на склад). 

DROP TABLE IF EXISTS requests; 
CREATE TABLE requests (
	id SERIAL PRIMARY KEY,
	department_id BIGINT UNSIGNED,
	nomenclature_id BIGINT UNSIGNED,
	request_date_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата заявки',
	request_closed_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
	request_quanity INT UNSIGNED NOT NULL COMMENT 'Кол-во',
	`status` ENUM ('closed', 'cancelled', 'in-process') COMMENT 'Статус заявки',
	FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (department_id) REFERENCES departments(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = 'Заявки в снабжение';

ALTER TABLE requests CHANGE status status ENUM('closed', 'cancelled', 'in-process', 'new-request');





