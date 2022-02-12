/*
***���� ������ SIPPLIERS_BASE***
�����: ������ ������, 2022
���� ������ ������������� ��� �������� � ��������� ������ 
�� ������� �����������. �������� ���������� �� ������������� ����������� (managers), 
�����������(suppliers), �������� ������� (product_groups), ������������ ������������ 
������� � ����� (nomenclature), ����������� ������� (orders) � �������� (payments).
*/

DROP DATABASE IF EXISTS suppliers_base;
CREATE DATABASE suppliers_base CHARACTER SET 'utf8';
USE suppliers_base;

-- ������� ������� Managers, � ������� ����� ���������
-- ������ � �����������: ���������� ������ ��������� � ������������:
-- ���, �������, ���������, Email, T������, ���� ��������������� (����� ��� ��������� ����� ����������). 

DROP TABLE IF EXISTS managers;
CREATE TABLE managers (
	id SERIAL PRIMARY KEY, 
	firstname VARCHAR (20) COMMENT '�������',
	lastname VARCHAR (20) COMMENT '���',
	email VARCHAR (30) UNIQUE COMMENT 'Email',
	phone BIGINT COMMENT '�������',
	started_at DATE DEFAULT NULL COMMENT '�������� �..',
	`position` ENUM ('�������� ��', '�������� ��') COMMENT '��������� ����������',
	speak_english BIT DEFAULT 0, -- �������� ������������ �������
	INDEX managers_firstname_lastname_idx(firstname, lastname)
) COMMENT = '��������� ������ ��������� � �����������';	

-- ������� ������� Suppliers, � ������� ����� ��������� 
-- ������ � �����������: ������������, ���������� ����, ������, �����, ���������� ����������, ������� ����������,
-- � ��� ������� ������ - ��������, ����������, ������������. 

DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
	id SERIAL PRIMARY KEY, 
	product_group_id BIGINT UNSIGNED,  
	company_name VARCHAR (100) NOT NULL COMMENT '������������ �����������',
	contact_person VARCHAR (50) NOT NULL COMMENT '���������� ����',
	contact_title VARCHAR (30) NOT NULL COMMENT '��������� ����������� ����',
	country VARCHAR (30) COMMENT '������',
	city VARCHAR (30) COMMENT '�����', 
	phone BIGINT CHECK (phone !='') COMMENT '�������', 
	email VARCHAR (30) CHECK (email !='') COMMENT 'Email', 
	`status` ENUM ('active', 'not-active', 'blocked') COMMENT '������� ������',
	`raiting` ENUM ('HIGH-A', 'MEDIUM-B', 'LOW-C') COMMENT '�������',
	added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '���� ���������� � ��',
	INDEX suppliers_name_idx(company_name)
	
) COMMENT = '����������';

-- ������� ������� Product_group, � ������� ����� ���������
-- ������ � ��������� ���������� �������: ������������ ������ (�������� �����, ���������).
-- ��� ��������� ����� ������� � ��� �������� ������: �����, ������� ���������, ������.

DROP TABLE IF EXISTS product_groups;
CREATE TABLE product_groups (
 	id SERIAL, 
	product_group_name VARCHAR (50) NOT NULL COMMENT '�������� ������',
	main_group ENUM ('1211 - �����', '1212 - ������� ���������', '1213 - ������', '1215 - ������')
) COMMENT = '�������� ������';

-- ������ ������� ���� ��� ������� Suppliers
ALTER TABLE suppliers ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_group_id) REFERENCES product_groups(id)
ON UPDATE CASCADE ON DELETE set NULL;

-- ������� ������� Nomenclature, � ������� ����� ���������
-- ������ � �������� �������: �������, ������������, ������.

DROP TABLE IF EXISTS nomenclature;
CREATE TABLE nomenclature (
 	id SERIAL PRIMARY KEY,
 	group_id BIGINT UNSIGNED,
	`number` INT (100) NOT NULL UNIQUE COMMENT '�������/�����', 
	name VARCHAR (255) NOT NULL COMMENT '������������', 
	units ENUM ('��.', '�', '�.�.') COMMENT '��.���������',
FOREIGN KEY (group_id) REFERENCES product_groups(id) ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = '������������';

-- ������� ������� Orders, � ������� ����� ���������

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL PRIMARY KEY, 
	manager_id 	BIGINT UNSIGNED,
	nomenclature_id BIGINT UNSIGNED, 
	supplier_id BIGINT UNSIGNED,
	order_number BIGINT UNSIGNED UNIQUE NOT NULL COMMENT '����� ������',
	quantity INT UNSIGNED NOT NULL COMMENT '���-��', 
	unit_price DECIMAL (11,2) NOT NULL COMMENT '���� �� ��.', 
	discount FLOAT (3,2) UNSIGNED COMMENT '�-� ������', -- �-� ������: 1 - ���� ��� ������, 0.7- ������ 30%, 0.9 - ������ 10%
	total_amount FLOAT AS (quantity * unit_price * discount) COMMENT '����� ����� ������', 
	order_status ENUM ('fully-confirmed', 'partly-confirmed', 'waiting confirmation', 'rejected', 'delayed') COMMENT '������ ������',
	plan_delivery_date DATE COMMENT '�������� ���� ��������',
	fact_delivery_date DATE DEFAULT NULL COMMENT '����������� ���� ��������',
	total_delay_days TINYINT AS (fact_delivery_date - plan_delivery_date) COMMENT '��������� ����/����, ��.',
	order_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '���� ������',
FOREIGN KEY (manager_id) REFERENCES managers(id) ON UPDATE CASCADE ON DELETE SET NULL,
FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id) ON UPDATE CASCADE ON DELETE SET NULL,
FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = '������ �����������';
 
-- ������� ������� Payments, � ������� ����� ���������
-- ������ � �������� �� ������������: ���� �������, ������� ���� �� ������� �������, 
-- ����� �������, ����� ��������� ���������� �� ������, ����� ����������� �������.

DROP TABLE IF EXISTS payments; 
CREATE TABLE payments (
	id SERIAL PRIMARY KEY,
	order_id BIGINT UNSIGNED,
	payment_date_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '���� �������',
	payment_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '���� ���������� �������', -- �������� ��� �������
	paid_amount DECIMAL (11,2) COMMENT '�������� (����������)',
	amount DECIMAL (11,2) COMMENT '����� ������� �����', 
	balance FLOAT AS (amount - paid_amount) COMMENT '�������� ��������',
FOREIGN KEY (order_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = '������� �����������';



-- ������� ������� Departments, � ������� ����� ���������
-- ������ �� ������� � ������������� ����������� (id, ���, ���� ��������). 

DROP TABLE IF EXISTS departments; 
CREATE TABLE departments (
	id SERIAL PRIMARY KEY,
	department_name VARCHAR (255) NOT NULL UNIQUE COMMENT '�����������',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = '������������';

-- ������� ������� Requests, � ������� ����� ���������
-- ������ � ����������� ������� � ����� ���������: ������� ����� nomenclature_id, department_id, 
-- ��������� ���-��, ������ ������, ���� ������, ���� �������� ������ (����������� ������� �� �����). 

DROP TABLE IF EXISTS requests; 
CREATE TABLE requests (
	id SERIAL PRIMARY KEY,
	department_id BIGINT UNSIGNED,
	nomenclature_id BIGINT UNSIGNED,
	request_date_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '���� ������',
	request_closed_at DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
	request_quanity INT UNSIGNED NOT NULL COMMENT '���-��',
	`status` ENUM ('closed', 'cancelled', 'in-process') COMMENT '������ ������',
	FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (department_id) REFERENCES departments(id) ON UPDATE CASCADE ON DELETE SET NULL
) COMMENT = '������ � ���������';

ALTER TABLE requests CHANGE status status ENUM('closed', 'cancelled', 'in-process', 'new-request');





