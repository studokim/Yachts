-- 1. Написать процедуру, увеличивающую стоимость проката всех яхт на заданную в качестве параметра величину в процентном соотношении (например, если в качестве параметра передается 10, значит стоимость проката всех яхт надо увеличить на 10 %). Для тех клиентов, у кого яхты на даный момент находятся на руках и кто внес полностью оплату за прокат в соответсвии со старой ценой проката, стоимость проката не изменяется – им не надо ничего доплачивать. Но для тех клиентов, которые внесли стоимость проката не полностью, необходимо увеличить размер оставшихся платежей на то же число процентов, насколько увеличивается стоимость проката.

CREATE FUNCTION UpdatePricesFunction(percent INT)
    RETURNS VOID
    LANGUAGE plpgsql
    AS
$$
BEGIN
    UPDATE VClass SET DailyCost = CEIL(DailyCost * (1 + percent / 100.0));
    UPDATE VInvoice SET Amount = CEIL(Amount * (1 + percent / 100.0))
        WHERE (PaidDate IS NULL);
END;
$$
;

-- 2. Написать функцию, вычисляющую возможную скидку для данного клиента. В качестве входного параметра передается id клиента, на выходе функция возращает процент скидки. Скидка вычислется по следующим правилам: клиент может получить скидку, если он ни разу не просрочил платеж и всегда возвращал яхты в хорошем состоянии. В противном случае скидка невозможна. Если клиент удовлетворяет данным условиям, то размер скидки в процентах равен некоторому коэффициенту с1, умноженному на общую сумму денег, которую данный клиент заплатил по предыдущим договарам «Синей птице», но не может превышать 25%. Величина коэффициента с1 определена как константа в функции, ее значение меньше единицы (например, 0.01).

CREATE FUNCTION CalculateRevenueFunction(docId CHAR(10))
    RETURNS INT
    LANGUAGE plpgsql
    AS
$$
BEGIN
    RETURN (SELECT SUM(Deposit) FROM VInvoice WHERE (DocumentId = docId));
END;
$$
;

CREATE FUNCTION CalculateDiscountFunction(docId CHAR(10))
    RETURNS INT
    LANGUAGE plpgsql
    AS
$$
DECLARE
    clientExists BOOLEAN;
    overdueReturn BOOLEAN;
    overduePay BOOLEAN;
    badContition BOOLEAN;
    c1 REAL;
    revenue INT;
    discount INT;
BEGIN
    c1 := 0.0001;
    clientExists := EXISTS (SELECT DocumentId FROM VClient WHERE (DocumentId = docId));
    IF (NOT clientExists) THEN
        RAISE EXCEPTION 'The client with id % does not exist.', docId;
    END IF;
    overdueReturn := EXISTS (SELECT RentId FROM VRent WHERE (DocumentId = docId AND ReturnDate > EndDate
        OR (EndDate < CURRENT_DATE AND ReturnDate IS NULL)));
    overduePay := EXISTS (SELECT InvoiceId FROM VInvoice WHERE (DocumentId = docId AND PaidDate > IssueDate));
    badContition := EXISTS (SELECT DocumentId FROM VBadRent WHERE (DocumentId = docId));
    IF (overduePay OR overdueReturn OR badContition) THEN
        RAISE EXCEPTION 'Sorry, the client % does not deserve any discount.', docId;
    END IF;
    discount := CEIL(CalculateRevenueFunction(docId) * c1);
    IF (discount > 25) THEN
        RETURN 25;
    ELSE
        RETURN discount;
    END IF;
END;
$$
;

-- 3. Написать функцию, возвращающую список ожидаемых платежей по всем контрактам в срок до даты, переданной в качестве параметра. Передаваемая дата должна быть в будущем, возвращаем номер договора аренды, по которому должен пройти платеж, сумму платежа, ожидаемую дату платежа, ФИО клиента и номер его счета, если он указан в базе.

CREATE FUNCTION GetWaitingInvoicesFunction(date DATE)
    RETURNS TABLE (
        RentId INT,
        ToPay INT,
        IssueDate DATE,
        Name VARCHAR(50),
        BankAccount CHAR(16)
    )
    LANGUAGE plpgsql
    AS
$$
BEGIN
    IF (date <= CURRENT_DATE) THEN
        RAISE EXCEPTION 'The date must be a future one.';
    END IF;
    RETURN QUERY (SELECT VRent.RentId, VInvoice.Amount - VInvoice.Deposit AS ToPay,
        VInvoice.IssueDate, VClient.Name, VClient.BankAccount
        FROM VRent JOIN VClient ON VRent.DocumentId = VClient.DocumentId
        JOIN VInvoice ON VInvoice.RentId = VRent.RentId AND PaidDate IS NULL AND VInvoice.IssueDate < date
        WHERE (VInvoice.IssueDate > CURRENT_DATE));
END;
$$
;
