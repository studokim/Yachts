CREATE VIEW VRent AS(
    SELECT RentId, YachtId, DocumentId, StartDate, EndDate, (EndDate - StartDate + 1) AS Duration, ReturnDate
    FROM Rent
);

CREATE VIEW VClient AS(
    SELECT DocumentId, Name, PhoneNumber, Address, BankAccount
    FROM Client
);

CREATE VIEW VInspection AS(
    SELECT YachtId, Date, Type, StatusOk, TroubleShooting
    FROM Inspection
);

CREATE VIEW VYacht AS(
    SELECT YachtId, Title, ClassId, Size, Draught
    FROM Yacht
);

CREATE VIEW VClass AS(
    SELECT ClassId, DailyCost
    FROM Class
);

CREATE VIEW VInvoice AS(
    SELECT InvoiceId, RentId, DocumentId, Amount, Deposit, IssueDate, PaidDate, PaymentMethod
    FROM Invoice
);

CREATE VIEW VClientInvoice AS(
    SELECT InvoiceId, RentId, VInvoice.DocumentId, Name, PhoneNumber, Amount, Deposit, IssueDate, PaidDate, PaymentMethod
    FROM VInvoice JOIN VClient ON VInvoice.DocumentId = VClient.DocumentId
);

CREATE VIEW VClientRentYacht AS(
    SELECT RentId, StartDate, EndDate, Duration, Title, ClassId, Name, VClient.DocumentId, PhoneNumber
    FROM VRent JOIN VClient ON VRent.DocumentId = VClient.DocumentId
    JOIN VYacht ON VRent.YachtId = VYacht.YachtId
);

CREATE VIEW VBadRent AS(
    WITH BadRent AS(
        SELECT RentId, VRent.YachtId, Date AS InspectionDate, ReturnDate, TroubleShooting, DocumentId
        FROM VRent JOIN VInspection ON (VRent.YachtId = VInspection.YachtId) AND (NOT StatusOk) AND (Type = 'post-rental'))
    SELECT *
    FROM BadRent
    WHERE ReturnDate = (SELECT MAX(ReturnDate)
                FROM BadRent
                WHERE ReturnDate <= InspectionDate)
);
