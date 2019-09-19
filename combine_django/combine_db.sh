echo "waiting for MySQL container to be ready..."
while ! mysqladmin ping -h mysql --silent; do
	echo "waiting..."
	sleep 1
done
echo "ready!"

set -e

mysql -h mysql -u root -p$MYSQL_ADMIN_PASSWORD << EOF
CREATE DATABASE IF NOT EXISTS combine CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '$COMBINE_SUPERADMIN_USERNAME'@'%' IDENTIFIED BY '$COMBINE_SUPERADMIN_PASSWORD';
GRANT ALL PRIVILEGES ON * . * TO '$COMBINE_SUPERADMIN_USERNAME'@'%';
FLUSH PRIVILEGES;
EOF

python /opt/combine/manage.py makemigrations
python /opt/combine/manage.py migrate
python /opt/combine/manage.py makemigrations core
python /opt/combine/manage.py migrate core

python /opt/combine/manage.py shell << EOF
from django.contrib.auth.models import User
try:
	user = User.objects.get(username='$COMBINE_SUPERADMIN_USERNAME')
	user.is_superuser = True
	user.save()
except:
	User.objects.create_superuser('$COMBINE_SUPERADMIN_USERNAME', '$COMBINE_SUPERADMIN_EMAIL', '$COMBINE_SUPERADMIN_PASSWORD')
EOF
