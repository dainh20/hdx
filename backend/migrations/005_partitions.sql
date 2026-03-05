DO $$
DECLARE
    start_date date := current_date;
    end_date   date := current_date + interval '6 months';
    d          date;
BEGIN
    d := start_date;

    WHILE d < end_date LOOP

        -------------------------
        -- ORDERS
        -------------------------
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS trading.orders_%s 
             PARTITION OF trading.orders
             FOR VALUES FROM (%L) TO (%L);',
            to_char(d, 'YYYYMMDD'),
            d,
            d + interval '1 day'
        );

        EXECUTE format(
            'CREATE INDEX IF NOT EXISTS idx_orders_acc_%s
             ON trading.orders_%s (account_id, created_at);',
            to_char(d, 'YYYYMMDD'),
            to_char(d, 'YYYYMMDD')
        );

        EXECUTE format(
            'CREATE INDEX IF NOT EXISTS idx_orders_stock_%s
             ON trading.orders_%s (stock_id, created_at);',
            to_char(d, 'YYYYMMDD'),
            to_char(d, 'YYYYMMDD')
        );

        -------------------------
        -- TRADES
        -------------------------
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS trading.trades_%s 
             PARTITION OF trading.trades
             FOR VALUES FROM (%L) TO (%L);',
            to_char(d, 'YYYYMMDD'),
            d,
            d + interval '1 day'
        );

        EXECUTE format(
            'CREATE INDEX IF NOT EXISTS idx_trades_stock_%s
             ON trading.trades_%s (stock_id, created_at);',
            to_char(d, 'YYYYMMDD'),
            to_char(d, 'YYYYMMDD')
        );

        -------------------------
        -- STOCK PRICES
        -------------------------
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS market.stock_prices_%s 
             PARTITION OF market.stock_prices
             FOR VALUES FROM (%L) TO (%L);',
            to_char(d, 'YYYYMMDD'),
            d,
            d + interval '1 day'
        );

        EXECUTE format(
            'CREATE INDEX IF NOT EXISTS idx_prices_stock_%s
             ON market.stock_prices_%s (stock_id, created_at);',
            to_char(d, 'YYYYMMDD'),
            to_char(d, 'YYYYMMDD')
        );

        d := d + interval '1 day';
    END LOOP;
END $$;