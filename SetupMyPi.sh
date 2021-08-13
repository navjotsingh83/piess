#!/bin/bash
echo "###########################"
echo "Setting up your PI..."
echo "###########################"

echo "####### Updating bluetooth #######"
sudo apt install bluetooth pi-bluetooth bluez blueman -y
echo -n "####### Bluetooth updated!! #######"

echo "####### Making chromium faster #######"

echo "Setting up ZRAM..."
git clone https://github.com/foundObjects/zram-swap
cd zram-swap
sudo ./install.sh

echo "Backing-up and moving chromium cache to RAM..."
sudo cp -fR /home/pi/.config/chromium /home/pi/.config/chromium_orig
sudo chown -R pi:pi /home/pi/.config/chromium_orig
sudo rm -rf /home/pi/.config/chromium
sudo mkdir /var/chrome_files
sudo chown -R pi:pi /var/chrome_files
sudo -u pi ln -s /var/chrome_files /home/pi/.config/chromium 

echo "tmpfs /var/chrome_files tmpfs nosuid,nodev,size=128M 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/log tmpfs nosuid,nodev,size=128M 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/tmp tmpfs nosuid,nodev,size=128M 0 0" | sudo tee -a /etc/fstab

sudo crontab -l > chromium_cron
echo "*/15 * * * * sudo -u pi cp -fR /var/chrome_files/* /home/pi/.config/chromium_orig" >> chromium_cron
echo "@reboot sudo -u pi cp -fR /home/pi/.config/chromium_orig/* /var/chrome_files" >> chromium_cron
sudo crontab chromium_cron

echo "Setting up DRAM for chromium to watch OTT"
sudo apt install libwidevinecdm0

echo "Rebooting..."
sudo reboot -f
