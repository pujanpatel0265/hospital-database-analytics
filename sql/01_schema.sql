-- ============================================================
-- CST2102 Final Project - Hospital Database
-- Group 7
-- Includes: DDL, DML, Business Queries, Users
-- ============================================================
CREATE DATABASE cst2112_group7
USE cst2112_group7;
GO

-- ============================================================
-- PART 1: DDL - DROP TABLES (FK-safe order)
-- ============================================================
IF OBJECT_ID('RoomAssignment','U') IS NOT NULL DROP TABLE RoomAssignment;
IF OBJECT_ID('Prescription',  'U') IS NOT NULL DROP TABLE Prescription;
IF OBJECT_ID('MedicalRecord', 'U') IS NOT NULL DROP TABLE MedicalRecord;
IF OBJECT_ID('Billing',       'U') IS NOT NULL DROP TABLE Billing;
IF OBJECT_ID('Appointment',   'U') IS NOT NULL DROP TABLE Appointment;
IF OBJECT_ID('Room',          'U') IS NOT NULL DROP TABLE Room;
IF OBJECT_ID('Staff',         'U') IS NOT NULL DROP TABLE Staff;
IF OBJECT_ID('Medicine',      'U') IS NOT NULL DROP TABLE Medicine;
IF OBJECT_ID('Doctor',        'U') IS NOT NULL DROP TABLE Doctor;
IF OBJECT_ID('Patient',       'U') IS NOT NULL DROP TABLE Patient;
IF OBJECT_ID('Department',    'U') IS NOT NULL DROP TABLE Department;
GO

-- ============================================================
-- PART 2: DDL - CREATE TABLES
-- ============================================================

CREATE TABLE Department (
    DepartmentID    INT           NOT NULL,
    DepartmentName  VARCHAR(100)  NOT NULL,
    Location        VARCHAR(150)  NOT NULL,
    PhoneExtension  VARCHAR(20)   NOT NULL,
    CONSTRAINT PK_Department PRIMARY KEY (DepartmentID),
    CONSTRAINT UQ_Department_Name UNIQUE (DepartmentName)
);
GO

CREATE TABLE Patient (
    PatientID              INT           NOT NULL,
    FirstName              VARCHAR(50)   NOT NULL,
    LastName               VARCHAR(50)   NOT NULL,
    DateOfBirth            DATE          NOT NULL,
    Gender                 VARCHAR(10)   NOT NULL,
    Address                VARCHAR(200)  NOT NULL,
    PhoneNumber            VARCHAR(20)   NOT NULL,
    Email                  VARCHAR(100)  NOT NULL,
    EmergencyContactName   VARCHAR(100)  NOT NULL,
    EmergencyContactPhone  VARCHAR(20)   NOT NULL,
    CONSTRAINT PK_Patient    PRIMARY KEY (PatientID),
    CONSTRAINT UQ_Patient_Email UNIQUE (Email),
    CONSTRAINT UQ_Patient_Phone UNIQUE (PhoneNumber)
);
GO

CREATE TABLE Doctor (
    DoctorID        INT           NOT NULL,
    FirstName       VARCHAR(50)   NOT NULL,
    LastName        VARCHAR(50)   NOT NULL,
    Specialization  VARCHAR(100)  NOT NULL,
    PhoneNumber     VARCHAR(20)   NOT NULL,
    Email           VARCHAR(100)  NOT NULL,
    DepartmentID    INT           NOT NULL,
    Availability    VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_Doctor         PRIMARY KEY (DoctorID),
    CONSTRAINT UQ_Doctor_Email   UNIQUE      (Email),
    CONSTRAINT FK_Doctor_Dept    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
GO

CREATE TABLE Medicine (
    MedicineID    INT            NOT NULL,
    MedicineName  VARCHAR(100)   NOT NULL,
    Manufacturer  VARCHAR(100)   NOT NULL,
    StockQuantity INT            NOT NULL,
    Price         DECIMAL(10,2)  NOT NULL,
    CONSTRAINT PK_Medicine PRIMARY KEY (MedicineID),
    CONSTRAINT UQ_Medicine_Name UNIQUE (MedicineName),
    CONSTRAINT CK_Medicine_Stock CHECK (StockQuantity >= 0),
    CONSTRAINT CK_Medicine_Price CHECK (Price > 0)
);
GO

CREATE TABLE Staff (
    StaffID      INT          NOT NULL,
    FirstName    VARCHAR(50)  NOT NULL,
    LastName     VARCHAR(50)  NOT NULL,
    Role         VARCHAR(50)  NOT NULL,
    DepartmentID INT          NOT NULL,
    PhoneNumber  VARCHAR(20)  NOT NULL,
    Email        VARCHAR(100) NOT NULL,
    ShiftHours   VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Staff       PRIMARY KEY (StaffID),
    CONSTRAINT UQ_Staff_Email UNIQUE      (Email),
    CONSTRAINT FK_Staff_Dept  FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);
GO

CREATE TABLE Room (
    RoomID             INT          NOT NULL,
    RoomNumber         VARCHAR(20)  NOT NULL,
    DepartmentID       INT          NOT NULL,
    RoomType           VARCHAR(50)  NOT NULL,
    AvailabilityStatus VARCHAR(30)  NOT NULL,
    CONSTRAINT PK_Room           PRIMARY KEY (RoomID),
    CONSTRAINT UQ_Room_Number    UNIQUE      (RoomNumber),
    CONSTRAINT FK_Room_Dept      FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT CK_Room_Type      CHECK (RoomType IN ('General','Private','ICU','Operating','Recovery')),
    CONSTRAINT CK_Room_Status    CHECK (AvailabilityStatus IN ('Available','Occupied','Under Maintenance'))
);
GO

CREATE TABLE Appointment (
    AppointmentID   INT          NOT NULL,
    PatientID       INT          NOT NULL,
    DoctorID        INT          NOT NULL,
    DepartmentID    INT          NOT NULL,
    AppointmentDate DATE         NOT NULL,
    AppointmentTime TIME         NOT NULL,
    Status          VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Appointment       PRIMARY KEY (AppointmentID),
    CONSTRAINT FK_Appt_Patient      FOREIGN KEY (PatientID)    REFERENCES Patient(PatientID),
    CONSTRAINT FK_Appt_Doctor       FOREIGN KEY (DoctorID)     REFERENCES Doctor(DoctorID),
    CONSTRAINT FK_Appt_Dept         FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT CK_Appt_Status       CHECK (Status IN ('Scheduled','Completed','Cancelled'))
);
GO

CREATE TABLE MedicalRecord (
    RecordID       INT           NOT NULL,
    PatientID      INT           NOT NULL,
    DoctorID       INT           NOT NULL,
    VisitDate      DATE          NOT NULL,
    Diagnosis      VARCHAR(200)  NOT NULL,
    TreatmentPlan  VARCHAR(300)  NOT NULL,
    Prescription   VARCHAR(200)  NOT NULL,
    CONSTRAINT PK_MedicalRecord    PRIMARY KEY (RecordID),
    CONSTRAINT FK_MedRec_Patient   FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT FK_MedRec_Doctor    FOREIGN KEY (DoctorID)  REFERENCES Doctor(DoctorID)
);
GO

CREATE TABLE Prescription (
    PrescriptionID  INT          NOT NULL,
    RecordID        INT          NOT NULL,
    MedicineID      INT          NOT NULL,
    Dosage          VARCHAR(50)  NOT NULL,
    Frequency       VARCHAR(50)  NOT NULL,
    Duration        VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Prescription     PRIMARY KEY (PrescriptionID),
    CONSTRAINT FK_Rx_Record        FOREIGN KEY (RecordID)   REFERENCES MedicalRecord(RecordID),
    CONSTRAINT FK_Rx_Medicine      FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID)
);
GO

CREATE TABLE Billing (
    BillingID      INT            NOT NULL,
    PatientID      INT            NOT NULL,
    TotalAmount    DECIMAL(10,2)  NOT NULL,
    PaymentStatus  VARCHAR(10)    NOT NULL,
    PaymentDate    DATE           NULL,
    PaymentMethod  VARCHAR(50)    NULL,
    CONSTRAINT PK_Billing          PRIMARY KEY (BillingID),
    CONSTRAINT FK_Billing_Patient  FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT CK_Billing_Status   CHECK (PaymentStatus IN ('Paid','Unpaid')),
    CONSTRAINT CK_Billing_Amount   CHECK (TotalAmount > 0)
);
GO

CREATE TABLE RoomAssignment (
    AssignmentID   INT   NOT NULL,
    RoomID         INT   NOT NULL,
    PatientID      INT   NOT NULL,
    AdmissionDate  DATE  NOT NULL,
    DischargeDate  DATE  NOT NULL,
    CONSTRAINT PK_RoomAssignment    PRIMARY KEY (AssignmentID),
    CONSTRAINT FK_RoomAssign_Room   FOREIGN KEY (RoomID)    REFERENCES Room(RoomID),
    CONSTRAINT FK_RoomAssign_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT CK_RoomAssign_Dates  CHECK (DischargeDate >= AdmissionDate)
);
GO