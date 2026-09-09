CREATE TABLE IF NOT EXISTS inmon_layer.exchange_rate (
    date DATE NOT NULL,
    base CHAR(3) NOT NULL,
    quote CHAR(3) NOT NULL,
    rate NUMERIC(18,8) NOT NULL,

    CONSTRAINT pk_exchange_rate
        PRIMARY KEY (date, base, quote),

    CONSTRAINT chk_exchange_rate_positive
        CHECK (rate > 0)
);