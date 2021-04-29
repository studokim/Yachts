INSERT INTO VClient (DocumentId, Name, PhoneNumber, Address, BankAccount) VALUES
    ('1234567890', 'Arthur Conan Doyle', '+79091430954', 'A', '1234567812345678'),
    ('0123456789', 'Bond James Bond', '+79091430955', 'B', '8123456781234567'),
    ('9012345678', 'Hercule Jules Poirot', '+79091430956', 'C', '7812345678123456'),
    ('8901234567', 'Jules Gabriel Verne', '+79091430957', 'D', '6781234567812345'),
    ('7890123456', 'Samuel Richardson', '+79091430958', 'E', '5678123456781234');


INSERT INTO VClass (ClassId, DailyCost) VALUES
    ('A', 1000),
    ('B', 800),
    ('C', 500),
    ('D', 150)
;

INSERT INTO VYacht (YachtId, Title, ClassId, Size, Draught) VALUES
    (152, 'Augusta Maria', 'A', 150, 44),
    (246, 'Maria Theresia', 'D', 10, 2),
    (965, 'Franklin', 'C', 20, 4),
    (600, 'Roosevelt', 'B', 15, 15),
    (512, 'Kitty', 'B', 30, 3)
;

INSERT INTO VInspection (YachtId, Date) VALUES
    (152, '2021-03-20'),
    (246, '2021-03-21'),
    (965, '2021-03-22'),
    (600, '2021-03-23'),
    (512, '2021-03-24')
;
