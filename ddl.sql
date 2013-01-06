--
-- テーブル定義
--
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS entry_tag;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS revision;
DROP TABLE IF EXISTS entry;
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    user_no          INTEGER /* AUTO INCREMENT */ PRIMARY KEY NOT NULL,
    id          VARCHAR(64)  NOT NULL UNIQUE, -- id:hatena とか．64文字？
    password    VARCHAR(255),   
--    password_changed DATETIME,
--    password_expired DATETIME,
--    user_status      INTEGER NOT NULL DEFAULT 0,
--    user_sn          VARCHAR(64), -- Surname
--    user_cn          VARCHAR(64), -- Common name
--    user_email       VARCHAR(255) UNIQUE,
--    user_meta        TEXT, -- DUMPED TEXT
--    create_date      DATETIME,
--    create_function  VARCHAR(64) NOT NULL,
--    update_date      TIMESTAMP NOT NULL,
--    update_function  VARCHAR(64) NOT NULL,
--    update_count     INTEGER NOT NULL DEFAULT(1)
);

INSERT INTO user (user_id, password) VALUES ('user', 'pass');

--INSERT INTO user (user_id, user_password, user_sn, user_cn, create_function, update_date, update_function, update_count)
--VALUES('user0', 'pass', 'Foo', 'Bar', 'initialize', DATETIME(), 'initialize', DATETIME());

CREATE TABLE entry (
	entry_no         INTEGER /* AUTO INCREMENT */ PRIMARY KEY,
--	user_no          INTEGER NOT NULL REFERENCES user(user_no),
	title            VARCHAR(255) NOT NULL,
	stub             VARCHAR(255) NOT NULL UNIQUE,
	date             DATETIME NOT NULL,
	revision_no      INTEGER,
	entry_status     VARCHAR(255) DEFAULT('valid'),
	create_date      DATETIME,
	create_function  VARCHAR(64),
	update_date      TIMESTAMP,
	update_function  VARCHAR(64),
	update_count     INTEGER DEFAULT(0)
);
INSERT INTO entry (title, stub, date, revision_no)
VALUES('First Entry', 'first', DATETIME(), null);
INSERT INTO entry (title, stub, date, revision_no)
VALUES('Second Entry', 'second', DATETIME(), null);
UPDATE entry SET create_date = datetime(), update_date = datetime();

CREATE TABLE revision (
	entry_no         INTEGER REFERENCES entry(entry_no),
	revision_no      INTEGER /* AUTO INCREMENT */ PRIMARY KEY,
	text             TEXT,
	meta             TEXT,
	create_date      DATETIME,
	create_function  VARCHAR(64),
	update_date      TIMESTAMP,
	update_function  VARCHAR(64),
	update_count     INTEGER NOT NULL DEFAULT(0)
);
CREATE UNIQUE INDEX entry_revision ON revision(entry_no, revision_no);

UPDATE revision SET create_date = date(), update_date = date();

CREATE TABLE tag (
--	user_no          INTEGER NOT NULL REFERENCES user(user_no),
	tag_no           INTEGER /* AUTO INCREMENT */ PRIMARY KEY,
	title            VARCHAR(64) NOT NULL UNIQUE, --こんなに必要？
	stub             VARCHAR(64) NOT NULL UNIQUE, -- URL の表現
	color            VARCHAR(64), -- 色を決めれることに
	meta             TEXT
);
--CREATE UNIQUE INDEX user_tag      ON tag(user_no, tag_text);
--CREATE UNIQUE INDEX user_tag_stub ON tag(user_no, tag_stub);
 

INSERT INTO tag(title, stub)
VALUES('IT', 'it');
INSERT INTO tag(title, stub)
VALUES('Perl', 'perl');

CREATE TABLE entry_tag (
	entry_no          INTEGER NOT NULL REFERENCES entry(entry_no),
	tag_no            INTEGER NOT NULL REFERENCES tag(tag_no),
	PRIMARY KEY(entry_no, tag_no)
);
CREATE INDEX idx_entry_tag ON entry_tag(tag_no);
INSERT INTO entry_tag (entry_no, tag_no)
VALUES(1, 1);
INSERT INTO entry_tag (entry_no, tag_no)
VALUES(1, 2);

 INSERT INTO revision(entry_no, text)
 VALUES(1, 'はじめてのぶろぐTEST');
 INSERT INTO revision(entry_no, text)
 VALUES(1, '書き間違えの訂正');
 
 UPDATE entry SET revision_no = 2 WHERE entry_no = 1;
 
DROP VIEW view_entry_meta;
CREATE VIEW view_entry_meta
AS
	SELECT
		entry.*,
		LENGTH(HEX(revision.text)) / 2 AS length
	FROM
		entry
	LEFT OUTER JOIN
		revision
	ON entry.revision_no = revision.revision_no
;
		
 
-- select 'user', * from user;
 select 'entry', * from entry;
 select 'revision', * from revision;
 
 select 'tags', * from tag natural inner join entry_tag where entry_no = 1;