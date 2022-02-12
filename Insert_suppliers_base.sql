USE suppliers_base;

INSERT INTO managers (firstname, lastname, email, phone, `position`, speak_english, started_at)
VALUES
('Александр', 'Петров', 'petrov.a@company.ru', '74942454540', 'Менеджер АУ', 1, '2010-02-10'),
('Михаил', 'Головей', 'golovey.m@company.ru', '74942454541', 'Менеджер ОС', 0, '2012-04-12'),
('Сергей', 'Игнатьев', 'ignatiev.s@company.ru', '74942454542', 'Менеджер ОС', 0, '2015-06-20'),
('Анна', 'Иванова', 'ivanova.a@company.ru', '74942454543', 'Менеджер АУ', 1, '2017-05-21'),
('Татьяна', 'Шишкина', 'shishkina.t@company.ru', '74942454544', 'Менеджер АУ', 1, '2016-01-15'),
('Федор', 'Сумкин', 'sumkin.f@company.ru', '74942454545', 'Менеджер ОС', 0, '2009-02-28'),
('Игорь', 'Гордеев', 'gordeev.i@company.ru', '74942454546', 'Менеджер ОС', 0, '2011-11-09'),
('Светлана', 'Рязанова', 'ryazanoca.s@company.ru', '74942454547', 'Менеджер ОС', 0, '2001-09-11'),
('Владлен', 'Михайлов', 'mikhailov.v@company.ru', '74942454548', 'Менеджер АУ', 1, '2018-09-25'),
('Тимур', 'Гольдшмидт', 'goldshmidt.t@company.ru', '74942454549', 'Менеджер АУ', 0, '2005-02-14'),
('Ирина', 'Славина', 'slavina.i@company.ru', '74942454550', 'Менеджер АУ', 1, '2008-04-14');


INSERT INTO product_groups  
VALUES
(1,'Ткани','1211 - сырье'),
(2,'Фурнитура','1211 - сырье'),
(3,'ВА - Куртки','1212 - готовая продукция'),
(4,'ЛА - Рубашки','1212 - готовая продукция'),
(5,'Услуги по отшиву','1213 - услуги');


INSERT INTO suppliers (product_group_id, company_name, contact_person, contact_title, country, city, phone, email, `status`, `raiting`)
VALUES
(1, 'ООО БКЛМ', 'Чернов Андрей', 'Менеджер по продажам', 'Россия', 'Иваново', '49432565656', 'manager@bklm.ru','active','HIGH-A'),
(1, 'ООО ОРБИ', 'Иванова Анна', 'Менеджер по продажам', 'Россия', 'Рязань', '4912222323', 'manager1@orby.ru','active','MEDIUM-B'),
(2, 'ООО Фурнитура37', 'Доколина Вера', 'Менеджер по продажам', 'Россия', 'Иваново', '49432565347', 'dokolina@furnitura37.ru','active','HIGH-A'),
(3, 'Amontre clothes', 'Cindy Liu', 'Export manager', 'China', 'Shenzhen', '861112304546', 'amontre@qq.cn','active','HIGH-A'),
(5, 'ООО Швейная фабрика 44', 'Чекренев Владислав', 'Менеджер по продажам', 'Россия', 'Кострома', '4942546587', 'chekrenev@fabrika44.ru','active','HIGH-A'),
(5, 'ООО Иваново крой', 'Петрова Алиса', 'Директор', 'Россия', 'Иваново', '494325446287', 'director@ivanovokroy.ru','not-active','LOW-C'),
(4, 'ООО Екатеринбург-текстиль', 'Семенов Александр', 'Директор', 'Россия', 'Екатеринбург', '3433452345', 'emenov@ekattex.ru','active','MEDIUM-B'),
(4, 'ООО Легкий текстиль', 'Жигунова Светлана', 'Руководитель отдела продаж', 'Россия', 'Москва', '4952405678', 'sales@lighttextile77.ru','active','HIGH-A'),
(2, 'Lucky company', 'Ben Lee', 'Chief Manager', 'China', 'Guangzhou', '8613323012345', 'benlee@lucky.cn','active','HIGH-A'),
(1, 'ZEBRA LTD', 'Rachel Wu', 'Sales Manager', 'China', 'Shanghai', '8612332301325', 'rachelwu@zebra.cn','active','HIGH-A'),
(2, 'Biu Chun LTD', 'Chris Chan', 'Sales Manager', 'China', 'Shanghai', '8612331213131', 'chrischan@biuchun.cn','active','HIGH-A');


INSERT INTO nomenclature
VALUES
(1, 1, '11010', 'Ткань', 'п.м.'),
(2, 1, '11011', 'Ткань', 'п.м.'),
(3, 1, '11012', 'Ткань', 'п.м.'),
(4, 1, '11013', 'Ткань', 'п.м.'),
(5, 2, '21010', 'Молния №1', 'м'),
(6, 2, '21011', 'Молния №2', 'м'),
(7, 2, '21012', 'Молния №3', 'м'),
(8, 2, '21013', 'Молния №4', 'м'),
(9, 3, '30001', 'Куртка зимняя для мальчика размер M', 'шт.'),
(10, 3, '30002', 'Куртка зимняя для девочки размер S', 'шт.'),
(11, 3, '30003', 'Куртка осенняя для девочки размер S', 'шт.'),
(12, 4, '40001', 'Рубашка для девочки размер S', 'шт.'),
(13, 4, '40002', 'Рубашка для мальчика размер M', 'шт.');


INSERT INTO orders (id, manager_id,nomenclature_id,supplier_id, order_number, quantity, unit_price, discount, order_status, plan_delivery_date)
VALUES 
(1, 1, 1, 1, 1111111, 1200, 303, 1, 'fully-confirmed',  '2022-03-30'),
(2, 2, 2, 2, 1111122, 850, 250, 0.9, 'fully-confirmed',  '2022-02-15'),
(3, 3, 3, 2, 1111332, 700, 430, 0.85, 'waiting confirmation',  NULL),
(4, 4, 4, 10, 1111441, 2000, 750, 0.95, 'fully-confirmed','2022-05-30'),
(5, 5, 5, 3, 1111553, 10000, 85, 1, 'fully-confirmed','2022-02-10'),
(6, 6, 6, 9, 1111996, 8000, 75, 0.95, 'fully-confirmed','2022-02-28'),
(7, 7, 7, 9, 1111997, 8000, 70, 0.95, 'fully-confirmed','2022-03-03'),
(8, 8, 8, 3, 1111338, 3000, 115, 0.85, 'fully-confirmed','2022-02-20'),
(9, 9, 9, 4, 1111449, 400, 2500, 0.88, 'fully-confirmed','2022-06-01'),
(10, 1, 10, 4, 1111429, 200, 1500, 0.9, 'fully-confirmed','2022-06-10'),
(11, 1, 10, 4, 1111422, 400, 2500, 0.88, 'fully-confirmed','2022-05-12');


INSERT INTO payments (order_id, amount, paid_amount)
VALUES 
(1, 363600, 150000),
(2, 191250, 80000),
(3, 255850, 125000),
(4, 1425000, 540000),
(5,  850000, 425000),
(6,  570000, 237500),
(7,  532000, 185000),
(8,  293250, 100000),
(9,  880000, 540000),
(10,  270000, 135000),
(11,  880000, 440000);


INSERT INTO departments (department_name)
VALUES 
('Отдел маркетинга'),
('Основное производство'),
('Вспомогательное производство'),
('Бухгалтерия'),
('ИТ'),
('Отдел продаж');

INSERT INTO requests (department_id, nomenclature_id, request_quanity, `status`)
VALUES 
(2, 1, 1200, 'in-process'),
(2, 2, 850, 'in-process'),
(2, 3, 700, 'in-process'),
(2, 4, 2000, 'in-process'),
(2, 5, 10000, 'in-process'),
(3, 6, 8000, 'in-process'),
(3, 7, 8000, 'in-process'),
(3, 8, 3000, 'in-process'),
(6, 9, 400, 'in-process'),
(6, 10, 200, 'in-process'),
(6, 11, 400, 'in-process');





