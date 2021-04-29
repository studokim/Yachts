INSERT INTO VRent (YachtId, DocumentId, StartDate, EndDate, ReturnDate) VALUES
    (600, '9012345678', '2021-03-30', '2021-04-02', '2021-04-02'),
    (512, '9012345678', '2021-03-29', '2021-04-03', '2021-04-03')
;

INSERT INTO VInspection (YachtId, Date, Type, StatusOk) VALUES
    (600, '2021-04-03', 'post-rental', false),
    (512, '2021-04-04', 'post-rental', true),

    (600, '2020-03-29', 'pre-rental', true),
    (600, '2019-03-28', 'pre-rental', true),
    (512, '2018-03-29', 'pre-rental', true),
    (600, '2017-03-01', 'pre-rental', true),
    (512, '2016-03-29', 'pre-rental', true),
    (152, '2015-03-29', 'pre-rental', true),
    (246, '2014-03-29', 'pre-rental', true),
    (600, '2013-03-29', 'pre-rental', true),
    (600, '2012-03-29', 'pre-rental', true),
    (512, '2011-03-29', 'pre-rental', true),
    (600, '2010-03-29', 'pre-rental', true),
    (512, '2009-03-29', 'pre-rental', true),
    (152, '2008-03-29', 'pre-rental', true),
    (246, '2007-03-29', 'pre-rental', true)
;

INSERT INTO VRent (YachtId, DocumentId, StartDate, EndDate, ReturnDate) VALUES
    (600, '9012345678', '2020-03-30', '2021-03-03', '2021-03-03'),
    (600, '9012345678', '2019-03-30', '2019-07-08', '2019-07-08'),
    (512, '9012345678', '2018-03-30', '2018-05-06', '2018-05-06'),
    (600, '9012345678', '2017-03-04', '2017-03-30', '2017-03-30'),
    (512, '9012345678', '2016-03-30', '2017-11-21', '2017-11-21'),
    (152, '9012345678', '2015-03-30', '2016-12-21', '2016-12-21'),
    (246, '9012345678', '2014-03-30', '2014-11-12', '2014-11-12'),

    (600, '7890123456', '2013-03-30', '2016-05-08', '2016-05-07'),
    (600, '7890123456', '2012-03-30', '2012-08-05', '2012-08-04'),
    (512, '7890123456', '2011-03-30', '2011-09-09', '2011-09-01'),

    (600, '0123456789', '2010-03-30', '2011-11-11', '2011-11-11'),
    (512, '0123456789', '2009-03-30', '2009-04-07', '2009-04-07'),
    (152, '0123456789', '2008-03-30', '2008-04-12', '2008-04-12'),
    (246, '0123456789', '2007-03-30', '2009-04-08', '2009-04-08')
;

select payInvoicesFunction('9012345678', 10000000, 'cash');
select payInvoicesFunction('7890123456', 908800, 'card', '2011-03-30');
select payInvoicesFunction('7890123456', 103200, 'card', '2012-03-30');
select payInvoicesFunction('7890123456', 131200, 'card', '2013-03-30');

INSERT INTO VInspection (YachtId, Date, Type, StatusOk) VALUES
    (246, '2024-03-30', 'pre-rental', true),
    (246, '2024-05-01', 'post-rental', true),
    (246, '2024-05-28', 'routine', true),
    (246, '2024-08-15', 'post-rental', true)
;
INSERT INTO VRent (YachtId, DocumentId, StartDate, EndDate, ReturnDate) VALUES
    (246, '1234567890', '2024-03-30', '2024-04-30', '2024-04-28'),
    (246, '1234567890', '2024-05-30', '2024-08-15', '2024-08-15')
;

--select payInvoicesFunction('1234567890', 10000000, 'card');
