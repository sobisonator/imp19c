CREATE TABLE IF NOT EXISTS province_setup (
	ProvID INTEGER PRIMARY KEY,
	Culture VARCHAR,
	Religion VARCHAR,
	TradeGoods VARCHAR,
	Citizens INTEGER,
	Freedmen INTEGER,
	LowerStrata INTEGER,
	MiddleStrata INTEGER,
	Proletariat INTEGER,
	Slaves INTEGER,
	Tribesmen INTEGER,
	UpperStrata INTEGER,
	Civilization INTEGER,
	Barbarian BOOLEAN,
	NameRef VARCHAR,
	AraRef VARCHAR
);

CREATE TABLE IF NOT EXISTS definition (
	Province_id INTEGER PRIMARY KEY,
	R VARCHAR,
	G VARCHAR,
	B VARCHAR,
	Name VARCHAR,
	x VARCHAR
);

CREATE TABLE IF NOT EXISTS province_checksums (
	province_checksum INTEGER PRIMARY KEY
);