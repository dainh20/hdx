CREATE TRIGGER trg_users_updated
BEFORE UPDATE ON core.users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_accounts_updated
BEFORE UPDATE ON account.accounts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_stocks_updated
BEFORE UPDATE ON market.stocks
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_portfolios_updated
BEFORE UPDATE ON portfolio.portfolios
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_deposit_requests_updated
BEFORE UPDATE ON account.deposit_requests
FOR EACH ROW EXECUTE FUNCTION set_updated_at();