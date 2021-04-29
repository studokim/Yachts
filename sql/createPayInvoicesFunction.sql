CREATE FUNCTION PayInvoicesFunction(docId CHAR(10), payAmount INT, payMethod CHAR(4), payDate DATE DEFAULT CURRENT_DATE)
    RETURNS VOID
    LANGUAGE plpgsql
    AS
$$
DECLARE
    unpaidInvoice record;
    remainderAmount INT;
    toPay INT;
BEGIN
    remainderAmount := payAmount;
    FOR unpaidInvoice IN (SELECT * FROM VInvoice
        WHERE (DocumentId = docId)
            AND (PaidDate IS NULL)
            ORDER BY IssueDate) LOOP
        toPay := unpaidInvoice.Amount - unpaidInvoice.Deposit;
        IF (toPay <= remainderAmount) THEN
            IF (unpaidInvoice.Deposit = 0) THEN
                UPDATE VInvoice SET PaymentMethod = payMethod
                    WHERE (VInvoice.InvoiceId = unpaidInvoice.InvoiceId);
            ELSE
                UPDATE VInvoice SET PaymentMethod = 'part'
                    WHERE (VInvoice.InvoiceId = unpaidInvoice.InvoiceId);
            END IF;
            UPDATE VInvoice SET Deposit = Amount, PaidDate = payDate
                    WHERE (VInvoice.InvoiceId = unpaidInvoice.InvoiceId);
            remainderAmount := remainderAmount - toPay;
        ELSIF (remainderAmount > 0) THEN
            UPDATE VInvoice SET Deposit = Deposit + remainderAmount, PaymentMethod = 'part'
                    WHERE (VInvoice.InvoiceId = unpaidInvoice.InvoiceId);
            remainderAmount := 0;
        ELSE
            RETURN;
        END IF;
    END LOOP;
    RAISE NOTICE 'The change to client % is %.', docId, remainderAmount;
END;
$$
;
