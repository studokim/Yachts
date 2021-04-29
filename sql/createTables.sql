CREATE TABLE Client(
    DocumentId  CHAR(10) PRIMARY KEY,
    Name        VARCHAR(50) NOT NULL,
    PhoneNumber CHAR(12) NOT NULL,
    Address     VARCHAR(50) NOT NULL,
    BankAccount CHAR(16),

    CONSTRAINT check_DocumentId CHECK (DocumentId ~* '^[0-9]+$'),
    CONSTRAINT check_PhoneNumber CHECK (PhoneNumber ~* '^\+[0-9]+$'),
    CONSTRAINT check_BankAccount CHECK (BankAccount ~* '^[0-9]+$'),
    CONSTRAINT check_Name CHECK (Name ~
        '^[A-Z][a-z]+ [A-Z][a-z]+(?: [A-Z][a-z]+)?$'),
    CONSTRAINT check_Address CHECK (Address ~* '^([a-z]|[0-9]| )+$')
);

CREATE TABLE Class(
    ClassId CHAR(1) PRIMARY KEY,
    DailyCost INT NOT NULL,

    CONSTRAINT check_ClassId CHECK (ClassId ~ '[A-Z]')
);

CREATE TABLE Yacht(
    YachtId INT PRIMARY KEY,
    Title VARCHAR(20),
    ClassId CHAR(1) NOT NULL REFERENCES Class(ClassId) ON DELETE RESTRICT,
    Size INT NOT NULL,
    Draught INT NOT NULL

    CONSTRAINT check_Size CHECK (Size > 0),
    CONSTRAINT check_Draught CHECK (Draught > 0),
    CONSTRAINT check_Yacht_Title CHECK (Title IS NULL
        OR Title ~* '^([a-z]|[0-9]| )+$')
);

CREATE TABLE Inspection(
    YachtId INT NOT NULL REFERENCES Yacht(YachtId) ON DELETE RESTRICT,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    Type CHAR(11) NOT NULL DEFAULT 'routine',
    StatusOk BOOLEAN NOT NULL DEFAULT true,
    TroubleShooting VARCHAR(200),

    CONSTRAINT check_Inspection_Type CHECK (Type IN
        ('routine', 'pre-rental', 'post-rental'))
);

CREATE TABLE Rent(
    RentId SERIAL PRIMARY KEY,
    YachtId INT NOT NULL REFERENCES Yacht(YachtId) ON DELETE RESTRICT,
    DocumentId CHAR(10) NOT NULL REFERENCES Client(DocumentId) ON DELETE RESTRICT,
    StartDate DATE NOT NULL DEFAULT CURRENT_DATE,
    EndDate DATE NOT NULL,
    ReturnDate DATE,

    CONSTRAINT check_Rent_Dates CHECK (StartDate <= EndDate)
);

CREATE TABLE Invoice(
    InvoiceId SERIAL PRIMARY KEY,
    DocumentId CHAR(10) NOT NULL REFERENCES Client(DocumentId) ON DELETE RESTRICT,
    RentId INT NOT NULL REFERENCES Rent(RentId) ON DELETE RESTRICT,
    Amount INT NOT NULL,
    Deposit INT NOT NULL DEFAULT 0,
    IssueDate DATE NOT NULL DEFAULT CURRENT_DATE,
    PaidDate DATE,
    PaymentMethod CHAR(4),

    CONSTRAINT check_PaymentMethod CHECK (PaymentMethod IN
        ('card', 'cash', 'part')),
    CONSTRAINT check_Invoice_Amount CHECK (Amount > 0 AND Deposit >= 0)
);
