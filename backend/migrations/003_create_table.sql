CREATE TABLE core.users (
    id              BIGSERIAL PRIMARY KEY,
    username        TEXT NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    status          TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);



CREATE TABLE account.accounts (
    id                BIGSERIAL PRIMARY KEY,
    user_id           BIGINT NOT NULL REFERENCES core.users(id),
    available_balance NUMERIC(20,4) NOT NULL DEFAULT 0,
    frozen_balance    NUMERIC(20,4) NOT NULL DEFAULT 0,
    status            TEXT NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);



CREATE TABLE market.stocks (
    id          BIGSERIAL PRIMARY KEY,
    symbol      TEXT NOT NULL UNIQUE,
    exchange    TEXT NOT NULL,
    status      TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);



CREATE TABLE portfolio.portfolios (
    id          BIGSERIAL PRIMARY KEY,
    account_id  BIGINT NOT NULL REFERENCES account.accounts(id),
    stock_id    BIGINT NOT NULL REFERENCES market.stocks(id),
    quantity    NUMERIC(20,4) NOT NULL,
    avg_price   NUMERIC(20,4) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(account_id, stock_id)
);



CREATE TABLE account.deposit_requests (
    id          BIGSERIAL PRIMARY KEY,
    account_id  BIGINT NOT NULL REFERENCES account.accounts(id),
    amount      NUMERIC(20,4) NOT NULL,
    status      TEXT NOT NULL,
    approved_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);




CREATE TABLE account.asset_freezes (
    id          BIGSERIAL PRIMARY KEY,
    order_id    BIGINT,
    account_id  BIGINT NOT NULL REFERENCES account.accounts(id),
    type        TEXT NOT NULL,
    status      TEXT NOT NULL,
    amount      NUMERIC(20,4) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);



CREATE TABLE trading.orders (
    id              BIGSERIAL,
    account_id      BIGINT NOT NULL REFERENCES account.accounts(id),
    stock_id        BIGINT NOT NULL REFERENCES market.stocks(id),
    side            TEXT NOT NULL,
    order_type      TEXT NOT NULL,
    price           NUMERIC(20,4),
    quantity        NUMERIC(20,4) NOT NULL,
    filled_quantity NUMERIC(20,4) NOT NULL DEFAULT 0,
    status          TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);


CREATE TABLE trading.trades (
    id            BIGSERIAL,
    buy_order_id  BIGINT NOT NULL,
    sell_order_id BIGINT NOT NULL,
    stock_id      BIGINT NOT NULL REFERENCES market.stocks(id),
    price         NUMERIC(20,4) NOT NULL,
    quantity      NUMERIC(20,4) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);




CREATE TABLE market.stock_prices (
    id          BIGSERIAL,
    stock_id    BIGINT NOT NULL REFERENCES market.stocks(id),
    price       NUMERIC(20,4) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);