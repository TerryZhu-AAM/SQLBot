docker run -d \
  --name sqlbot \
  --restart unless-stopped \
  -p 7010:8000 \
  -p 7011:8001 \
  -p 7012:5432 \
  -v ./data/sqlbot/excel:/opt/sqlbot/data/excel \
  -v ./data/sqlbot/images:/opt/sqlbot/images \
  -v ./data/sqlbot/logs:/opt/sqlbot/logs \
  -v ./data/postgresql:/var/lib/postgresql/data \
  --privileged=true \
  dataease/sqlbot
