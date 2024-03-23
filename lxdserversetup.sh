uname -a
sudo apt update
sudo apt upgrade -y
sudo apt install openssh-server -y
sudo systemctl status ssh
clear

sudo ufw allow ssh
sudo ufw enable && sudo ufw reload
clear
sudo apt install net-tools
ifconfig

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
mv id_rsa.pub ~/.ssh/authorized_keys

sudo snap install curl
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

sudo snap install lxd
sudo -H gedit /etc/systemd/logind.conf
systemctl restart systemd-logind.service

ls
clear
ls
mkdir git

cd git
mkdir lxc-builds

sudo apt install make

sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install     ca-certificates     curl     gnupg     lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER

sudo snap install distrobuilder --classic
   
lxd init
sudo ufw allow 8443/tcp
sudo ufw reload

sudo cat <<EOF | sudo tee /etc/apt/preferences.d/bionic-proposed.pref
Package: *
Pin: release a=bionic-proposed
Pin-Priority: -1
EOF

sudo add-apt-repository 'deb http://archive.canonical.com/ubuntu bionic-proposed restricted main multiverse universe'
apt-cache policy debootstrap
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* && sudo apt update

sudo apt install debootstrap

make ecs ecs

sudo ufw allow in on lxdbr0
sudo ufw route allow in on lxdbr0
sudo ufw route allow out on lxdbr0

ldc launch ecs ecs

# Add Subnet Route from lxd network list to tailscale
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

sudo tailscale up --advertise-routes=10.61.34.0/24,fd42:3142:fcab:16cc::/64
  
manssh add ecs jldeen@10.x.x.x -i ~/.ssh/id_rsa
