# xui.one Auto Install Script

This script will work on Ubuntu and probably other distros of the same families, although no support is offered for them. It isn't bulletproof but it will probably work if you simply want to setup a Xui.one Portal on your Ubuntu box. It has been designed to be as unobtrusive and universal as possible.

<b>Script work only on Clean Ubuntu install servers</b>

🏆 Support OS:</br>

✅ Ubuntu 18</br>
✅ Ubuntu 20</br>
✅ Ubuntu 22</br>
✅ Ubuntu 24</br>

for Ubuntu 24.04 before install run this

apt update && apt upgrade -y

echo "HostKeyAlgorithms +ssh-rsa" >> /etc/ssh/sshd_config.d/50-cloud-init.conf.conf
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/sshd_config.d/50-cloud-init.conf.conf

systemctl restart sshd # (systemctl restart ssh #for u24)

wget http://de.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

>[!TIP]
> <b>Script crack automate Xui.One</b>

> [!TIP]
   > **Installing**
   >
   > 1. apt-get install git -y
   > 2. git clone https://github.com/jczapatap/xui.one
   > 3. cd xui.one
   > 4. chmod +x install.sh
   > 5. ./install.sh
