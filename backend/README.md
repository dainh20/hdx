Source/
│
├── cmd/                        # Entry point (main app)
│   └── api/
│       └── main.go (hoặc main.py / Application.java)
│
├── internal/
│   ├── user/
│   │   ├── handler/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── model/
│   │   └── router.go
│   │
│   ├── account/
│   │   ├── handler/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── model/
│   │   └── router.go
│   │
│   ├── order/
│   ├── trade/
│   ├── stock/
│   ├── portfolio/
│   ├── transaction/
│   ├── deposit/
│   ├── freeze/
│   │
│   └── middleware/
│
├── pkg/                        # Shared utilities
│   ├── database/
│   ├── logger/
│   ├── auth/
│   ├── utils/
│   └── errors/
│
├── migrations/                 # SQL migration files
│   ├── 001_create_users.sql
│   ├── 002_create_accounts.sql
│   ├── ...
│
├── configs/
│   └── config.yaml
│
├── docker/
│   ├── Dockerfile
│   └── postgres/
│
├── tests/
│
├── docker-compose.yml
└── README.md




### CDC
## 1. Tạo TK debezium
```sql
CREATE ROLE debezium WITH LOGIN PASSWORD 'debezium123';
ALTER ROLE debezium WITH REPLICATION;
GRANT ALL PRIVILEGES ON DATABASE hdx TO debezium;
GRANT CONNECT ON DATABASE hdx TO debezium;
GRANT ALL PRIVILEGES ON DATABASE hdx TO debezium; -- Full quyền
ALTER ROLE debezium WITH REPLICATION; -- Quyền replication
```

## 2. Config postgres
```sql
SHOW config_file; -- /var/lib/postgresql/data/postgresql.conf
```

## 3. Vào Container
```shell
docker exec -it hdx-postgres bash
```

# Chỉnh config_file
# Cài đặt nano nếu thiếu
"""
apt update
apt install -y nano
"""

```shell
nano /var/lib/postgresql/data/postgresql.conf
```

# Sửa:
wal_level = logical
max_wal_senders = 10
max_replication_slots = 10
wal_keep_size = 1GB

## 4. Restart docker
```shell
docker restart hdx-postgres
```
## sql
```sql
CREATE PUBLICATION hdx_publication
FOR TABLE core.users;


SELECT * FROM pg_publication; -- Kiểm tra publication
-- Kết quả mong đợi:
pubname      = hdx_publication
pubinsert    = t
pubupdate    = t
pubdelete    = t
pubtruncate  = t
```

Trạng thái hệ thống hiện tại:
wal_level = logical ✅
replication slot = hdx_slot ✅
publication = hdx_publication ✅
consumer (Debezium) ❌

## 5. Config Debezium
```shell
curl -Method POST http://localhost:8083/connectors `
   -Headers @{ "Content-Type" = "application/json" } `
   -Body '{
     "name": "hdx-postgres-connector",
     "config": {
       "connector.class": "io.debezium.connector.postgresql.PostgresConnector",

       "database.hostname": "hdx-postgres",
       "database.port": "5432",
       "database.user": "admin",
       "database.password": "admin123",                                                                                                                                                                               "database.dbname": "hdx",                                                                                                                                                                                                                                                                                                                                                                                                     "topic.prefix": "hdx",                                                                                                                                                                                         "plugin.name": "pgoutput",
       "slot.name": "hdx_slot",
       "publication.name": "hdx_publication",

       "snapshot.mode": "initial",

       "database.history.kafka.bootstrap.servers": "10.0.9.178:9094",
       "database.history.kafka.topic": "schema-changes.hdx",

       "bootstrap.servers": "10.0.9.178:9094"
     }
   }'
```
# Kết quả mong đợi:
StatusCode        : 201
StatusDescription : Created
Content           : {"name":"hdx-postgres-connector","config":{"connector.class":"io.debezium.connector.postgresql.PostgresConnector","database.hostname":"hdx-postgres","database.port":"5432","database.user":
                    "admin","dat...
RawContent        : HTTP/1.1 201 Created
                    Content-Length: 594
                    Content-Type: application/json
                    Date: Thu, 05 Mar 2026 04:02:56 GMT
                    Location: http://localhost:8083/connectors/hdx-postgres-connector
                    Server: Jetty(9.4.52....
Forms             : {}
Headers           : {[Content-Length, 594], [Content-Type, application/json], [Date, Thu, 05 Mar 2026 04:02:56 GMT], [Location, http://localhost:8083/connectors/hdx-postgres-connector]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 594