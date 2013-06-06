CREATE TABLE GENIE_PAGE (
	PAGE_ID	VARCHAR2(100),
	TITLE		VARCHAR2(100),
	PARAM1	VARCHAR2(100),
	PARAM2	VARCHAR2(100),
	PARAM3	VARCHAR2(100),
	PRIMARY KEY (PAGE_ID)
)
/

CREATE TABLE GENIE_PAGE_SQL (
	PAGE_ID	VARCHAR2(100),
	SEQ		NUMBER(3),
	TITLE		VARCHAR2(100),
	SQL_STMT	VARCHAR2(1000),
	INDENT	NUMBER(3)		DEFAULT 0,
	PRIMARY KEY (PAGE_ID, SEQ),
	FOREIGN KEY (PAGE_ID) REFERENCES GENIE_PAGE ON DELETE CASCADE
)
/

CREATE TABLE GENIE_WORK_SHEET (
	ID			VARCHAR2(100),
	SQL_STMTS	VARCHAR2(4000),
	COORDS		VARCHAR2(4000),
	UPDATED     DATE DEFAULT SYSDATE,
	PRIMARY KEY (ID)
)
/

CREATE TABLE GENIE_TABLE_COL (
	TNAME			VARCHAR2(30),
	CNAME			VARCHAR2(30),
	CAPT			VARCHAR2(30),
	LOOKUP_SQL		VARCHAR2(500),
	PRIMARY KEY (TNAME, CNAME)
)
/

CREATE TABLE GENIE_LINK (
	TNAME		VARCHAR2(30),
	SQL_STMTS	VARCHAR2(4000),
	PRIMARY KEY (TNAME)
)
/

CREATE TABLE GENIE_PA (
	PACKAGE_NAME		VARCHAR2(30),
	CREATED             DATE,
	PRIMARY KEY (PACKAGE_NAME)
)
/


CREATE TABLE GENIE_PA_TABLE (
	PACKAGE_NAME		VARCHAR2(30),
	PROCEDURE_NAME		VARCHAR2(30),
	TABLE_NAME			VARCHAR2(30),
	OP_SELECT			CHAR(1),
	OP_INSERT			CHAR(1),
	OP_UPDATE			CHAR(1),
	OP_DELETE			CHAR(1)
	PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, TABLE_NAME)
)
/

CREATE INDEX GENIE_PA_TABLE_IDX ON GENIE_PA_TABLE(TABLE_NAME)
/

CREATE TABLE GENIE_PA_DEPENDENCY (
	PACKAGE_NAME		VARCHAR2(30),
	PROCEDURE_NAME		VARCHAR2(30),
	TARGET_PKG_NAME	    VARCHAR2(30),
	TARGET_PROC_NAME	VARCHAR2(30)
	PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, TARGET_PKG_NAME, TARGET_PROC_NAME)
)
/

CREATE INDEX GENIE_PA_DEPENDENCY_IDX ON GENIE_PA_DEPENDENCY(TARGET_PKG_NAME, TARGET_PROC_NAME)
/

CREATE TABLE GENIE_PA_PROCEDURE (
	PACKAGE_NAME		VARCHAR2(30),
	PROCEDURE_NAME		VARCHAR2(30),
	START_LINE	        NUMBER,
	END_LINE            NUMBER,
	PROCEDURE_LABEL     VARCHAR2(30),
	PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, START_LINE)
)
/

CREATE TABLE GENIE_TR (
	TRIGGER_NAME		VARCHAR2(30),
	CREATED             DATE,
	PRIMARY KEY (TRIGGER_NAME)
)
/


CREATE TABLE GENIE_TR_TABLE (
	TRIGGER_NAME		VARCHAR2(30),
	TABLE_NAME			VARCHAR2(30),
	OP_SELECT			CHAR(1),
	OP_INSERT			CHAR(1),
	OP_UPDATE			CHAR(1),
	OP_DELETE			CHAR(1)
	PRIMARY KEY (TRIGGER_NAME, TABLE_NAME)
)
/

CREATE INDEX GENIE_TR_TABLE_IDX ON GENIE_TR_TABLE(TABLE_NAME)
/