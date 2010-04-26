rm -rf call-log/;
git clone git://github.com/tatecarr/call-log.git;
sudo sed -i 's/socket: \/tmp\/mysql.sock//' call-log/config/database.yml;
sudo sed -i 's/#password: number9/password: nearc/' call-log/config/database.yml;
sudo sed -i 's/#socket: \/var\/run\/mysqld\/mysqld.sock/socket: \/var\/run\/mysqld\/mysqld.sock/' call-log/config/database.yml;
sudo sed -i 's/#ENV/ENV['\''RAILS_ENV'\''] ||= '\''production'\'' #/' call-log/config/environment.rb
mkdir call-log/tmp;
touch call-log/tmp/restart.txt;
