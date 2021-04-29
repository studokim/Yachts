-- Оплата за аренду в случае краткосрочной аренды (до 1 недели) взимается при выдаче яхты. При аренде на срок до месяца возможна оплата по схеме 50% в момент выдачи яхты, 50% в момент возвращения яхты. При аренде яхты на более длительные сроки оплата аренды производится ежемесячно.

CREATE FUNCTION IssueSingleInvoiceFunction(DocumentId CHAR(10), RentId INT, Amount INT, IssueDate DATE)
    RETURNS VOID
    LANGUAGE plpgsql
    AS
$$
BEGIN
    INSERT INTO VInvoice (DocumentId, RentId, Amount, IssueDate)
        VALUES (DocumentId, RentId, Amount, IssueDate);
END;
$$
;

CREATE FUNCTION IssueWeekInvoicesFunction(DocumentId CHAR(10), RentId INT, totalAmount INT, StartDate DATE, EndDate DATE)
    RETURNS VOID
    LANGUAGE plpgsql
    AS
$$
BEGIN
    PERFORM IssueSingleInvoiceFunction(DocumentId, RentId, totalAmount, StartDate);
END;
$$
;

CREATE FUNCTION IssueFiftyFiftyInvoicesFunction(DocumentId CHAR(10), RentId INT, totalAmount INT, StartDate DATE, EndDate DATE)
    RETURNS VOID
    LANGUAGE plpgsql
    AS
$$
DECLARE
    halfAmount INT;
BEGIN
    halfAmount := totalAmount / 2;
    PERFORM IssueSingleInvoiceFunction(DocumentId, RentId, halfAmount, StartDate);
    PERFORM IssueSingleInvoiceFunction(DocumentId, RentId, totalAmount - halfAmount, EndDate);
END;
$$
;

CREATE FUNCTION IssueMonthlyInvoicesFunction(DocumentId CHAR(10), RentId INT, totalAmount INT, StartDate DATE, EndDate DATE)
    RETURNS VOID
    LANGUAGE plpgsql
    AS
$$
DECLARE
    months REAL;
    monthAmount INT;
    remainderAmount INT;
    currentDate DATE;
BEGIN
    months = (EndDate - StartDate + 1) / 30.0;
    monthAmount = totalAmount / CEIL(months);
    remainderAmount = totalAmount - monthAmount * CEIL(months);
    PERFORM IssueSingleInvoiceFunction(DocumentId, RentId, monthAmount + remainderAmount, StartDate);
    currentDate = StartDate + 30;
    WHILE (currentDate < EndDate) LOOP
        PERFORM IssueSingleInvoiceFunction(DocumentId, RentId, monthAmount, currentDate);
        currentDate = currentDate + 30;
    END LOOP;
END;
$$
;

CREATE FUNCTION IssueInvoicesFunction()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS
$$
DECLARE
    duration INT;
    totalAmount INT;
    cost INT;
BEGIN
    duration := NEW.EndDate - NEW.StartDate + 1;
    cost := (SELECT DailyCost FROM Class WHERE ClassId =
        (SELECT ClassId FROM Yacht WHERE YachtId = NEW.YachtId));
    totalAmount := duration * cost;
    IF (duration <= 7) THEN
        PERFORM IssueWeekInvoicesFunction(NEW.DocumentId, NEW.RentId, totalAmount, NEW.StartDate, NEW.EndDate);
    ELSIF (duration <= 30) THEN
        PERFORM IssueFiftyFiftyInvoicesFunction(NEW.DocumentId, NEW.RentId, totalAmount, NEW.StartDate, NEW.EndDate);
    ELSE
        PERFORM IssueMonthlyInvoicesFunction(NEW.DocumentId, NEW.RentId, totalAmount, NEW.StartDate, NEW.EndDate);
    END IF;
    RETURN NULL;
END;
$$
;

CREATE TRIGGER IssueInvoicesTrigger
    AFTER INSERT ON Rent
    FOR EACH ROW
    EXECUTE FUNCTION IssueInvoicesFunction();
