CREATE INDEX ind_Client_Name ON Client (Name);
CREATE INDEX ind_Client_PhoneNumber ON Client (PhoneNumber);

CREATE INDEX ind_Yacht_Title ON Yacht (Title);

CREATE INDEX ind_Inspection_YachtId ON Inspection (YachtId);
CREATE INDEX ind_Inspection_Date ON Inspection (Date);

CREATE INDEX ind_Rent_YachtId ON Rent (YachtId);
CREATE INDEX ind_Rent_DocumentId ON Rent (DocumentId);
CREATE INDEX ind_Rent_StartDate ON Rent (StartDate);

CREATE INDEX ind_Invoice_DocumentId ON Invoice (DocumentId);
CREATE INDEX ind_Invoice_RentId ON Invoice (RentId);
CREATE INDEX ind_Invoice_IssueDate ON Invoice (IssueDate)
