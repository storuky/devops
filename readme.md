# Server setup

## Create **deploy** user with sudo priveleges

```
USER_NAME="deploy"
PUBLIC_KEY=""

# Create a new user
sudo adduser --disabled-password --gecos "" $USER_NAME

# Create SSH directory and set permissions
sudo mkdir -p /home/$USER_NAME/.ssh
sudo chmod 700 /home/$USER_NAME/.ssh

# Add public key to authorized_keys
echo $PUBLIC_KEY | sudo tee /home/$USER_NAME/.ssh/authorized_keys

# Set permissions for authorized_keys
sudo chmod 600 /home/$USER_NAME/.ssh/authorized_keys
sudo chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh
```

## Update packages list

```
sudo apt-get update
```

## Install PostgreSQL

```
sudo apt-get install postgresql postgresql-contrib libpq-dev
```

## Create production database (**project_production**) and privileged postgres user (**deploy**) with password "**mypass**". Please, change these bold fields to your own!

```
sudo -u postgres psql
postgres=# create database project_production;
postgres=# create user deploy with encrypted password 'mypass';
postgres=# grant all privileges on database project_production to deploy;
```

## Install RVM

```
sudo apt install gnupg2
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source /home/deploy/.rvm/scripts/rvm
rvm install 2.6.3
rvm use 2.6.3@project_name --create --default
```

## Install NodeJS with pm2 and Yarn

```
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt-get install nodejs
sudo npm install -g pm2

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
```

## Deploy rails

Copy files from _./rails/local_ directory to your local Rails application (don't forget to change specific fields)

```
mina production setup
```

Nex we should initiate first deploy. Don't worry if you got fail that's ok for now.

```
mina deploy
```

Copy files from _./rails/remote/config_ **(don't forget to change specific fields!)** to _~/project_name/shared/config_. They will be auto-linked. You can do it using `scp` from your local machine or create files manually.

```
scp -r ./rails/remote/config/* deploy@server_ip:/home/deploy/project_name/shared/config
```

Connect to your server

```
ssh deploy@server_ip
```

Go to `/home/deploy/project_name/`

Create directories to store **puma** and **pumactl** socket and pid files

```
mkdir /home/deploy/project_name/shared/tmp/sockets
mkdir /home/deploy/project_name/shared/tmp/pids

```

Try deploy again. Don't forget about SECRET_KEY_BASE in your environments.

```
mina production deploy
mina production puma:start
```

Redeploy to be sure that puma restart phased works fine

```
mina production deploy
```

If you got a message **Puma is not running!** make sure you changed correcty all paths inside _shared/config/puma.rb_ and created directories to write pids and sockets to them.
If you see **Command phased-restart sent success** – my congratulations!

## Nginx

If you haven't installed Nginx:

```
sudo apt-get install nginx
```

Let's write our own configs. We don't need default config. So, let's remove it and create custom:

```
cd /etc/nginx/sites-enabled/
sudo rm default
sudo vim api.project_name.storuky.com.conf

sudo rm ../sites-available/default
sudo ln -s vim api.project_name.storuky.com.conf ../sites-available/vim api.project_name.storuky.com.conf

sudo service nginx restart
```

Just to be sure that config is valid:

```
sudo nginx -t
```

# Deploy Vue app with yarn and mina

Inside your frontend add you should add mina package:

```
yarn add mina
```

Copy deploy configs from _./yarn/deploy_ to _your_app/deploy_. **Don't forget to change specific fields**.

Add to your _package.json_ **scripts** section these commands:

```
"scripts": {
  "deploy-production": "MINA_CONFIG=deploy/production.json mina deploy",
  "restart-production": "pm2 kill && PORT=3003 pm2 start server.js"
},
```

Run a deploy script:

```
yarn run deploy-production
```

If there are no errors you can find your application started on 3003 port.

Lets add an Nginx proxy from 80 port to 3003. You can find example in _./nginx/project.storuky.com_

```
sudo vim /etc/nginx/sites-enabled/project_name.storuky.com.conf

ln -s /etc/nginx/sites-enabled/project_name.storuky.com.conf /etc/nginx/sites-available/project_name.storuky.com.conf

sudo service nginx restart
```
