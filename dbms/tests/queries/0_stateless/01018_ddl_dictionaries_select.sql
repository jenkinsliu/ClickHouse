SET send_logs_level = 'none';

DROP DATABASE IF EXISTS database_for_dict;

CREATE DATABASE database_for_dict Engine = Ordinary;

CREATE TABLE database_for_dict.table_for_dict
(
  key_column UInt64,
  second_column UInt8,
  third_column String,
  fourth_column Float64
)
ENGINE = MergeTree()
ORDER BY key_column;

INSERT INTO database_for_dict.table_for_dict SELECT number, number % 17, toString(number * number), number / 2.0 from numbers(100);

DROP DICTIONARY IF EXISTS database_for_dict.dict1;

CREATE DICTIONARY database_for_dict.dict1
(
  key_column UInt64 DEFAULT 0,
  second_column UInt8 DEFAULT 1,
  third_column String DEFAULT 'qqq',
  fourth_column Float64 DEFAULT 42.0
)
PRIMARY KEY key_column
SOURCE(CLICKHOUSE(HOST 'localhost' PORT 9000 USER 'default' TABLE 'table_for_dict' PASSWORD '' DB 'database_for_dict'))
LIFETIME(MIN 1 MAX 10)
LAYOUT(FLAT());

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', toUInt64(11));
SELECT dictGetString('database_for_dict.dict1', 'third_column', toUInt64(12));
SELECT dictGetFloat64('database_for_dict.dict1', 'fourth_column', toUInt64(14));

select count(distinct(dictGetUInt8('database_for_dict.dict1', 'second_column', toUInt64(number)))) from numbers(100);

DETACH DICTIONARY database_for_dict.dict1;

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', toUInt64(11)); -- {serverError 36}

ATTACH DICTIONARY database_for_dict.dict1;

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', toUInt64(11));

DROP DICTIONARY database_for_dict.dict1;

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', toUInt64(11)); -- {serverError 36}

CREATE DICTIONARY database_for_dict.dict1
(
  key_column UInt64 DEFAULT 0,
  second_column UInt8 DEFAULT 1,
  third_column String DEFAULT 'qqq',
  fourth_column Float64 DEFAULT 42.0
)
PRIMARY KEY key_column, third_column
SOURCE(CLICKHOUSE(HOST 'localhost' PORT 9000 USER 'default' TABLE 'table_for_dict' PASSWORD '' DB 'database_for_dict'))
LIFETIME(MIN 1 MAX 10)
LAYOUT(COMPLEX_KEY_CACHE(SIZE_IN_CELLS 50));

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', tuple(toUInt64(11), '121'));
SELECT dictGetFloat64('database_for_dict.dict1', 'fourth_column', tuple(toUInt64(14), '196'));

DETACH DICTIONARY database_for_dict.dict1;

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', tuple(toUInt64(11), '121')); -- {serverError 36}

ATTACH DICTIONARY database_for_dict.dict1;

SELECT dictGetUInt8('database_for_dict.dict1', 'second_column', tuple(toUInt64(11), '121'));

DROP DATABASE IF EXISTS database_for_dict;
