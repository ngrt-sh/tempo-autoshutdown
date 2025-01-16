# tempo-autoshutdown
A Proxmox bash script that automatically shutdown the server in a EDF Tempo red day

# Explainations and context of my script creation

I created this bash script because I run a server in my homelab and also I live in France. In France, the main provider of electricity is EDF (Electricité De France) and we can have a contract called "Tempo". This contract provide us days called "Journée Bleue" (blue day), "Journée Blanche" (white day) and "Journée rouge" (red day). The red day is the worst day because the electricity price costs the most during peak hours (6 AM to 10 PM). So this is why I wanna make my own script to schedule automaticaly the power on and power off of my server.

# How it work?

I have found a *unoffical* Tempo API to fetch the color day of tomorrow. Everyday at 12h (or when the machine start), the bash script is automaticaly runned to fetch the tomorrow color day, if the API response request is "3" (red day), a shutdown at 6 AM tomorrow is scheduled and send a message to notify you of the shutdown via the Discord Webhook.

# Requirements

My script was tested on Proxmox VE 8.+ (Debian 12.x). It can works on some older versions of Proxmox VE or Debian.
> Make sure you have `curl`, `jq` and `at` installed on your machine. Otherwise you need to run `apt install curl jq at`.
> 
> ⚠ **You need** to run all commands as **root** user! 

# Installation

## 1. Go to the good directory

Run `cd /usr/local/bin` to be in your scripts directory.

And at the root of the directory, upload `tempo-autoshutdown.sh`

> Make sure to run `chmod +x tempo-autoshutdown.sh` and add your Discord Webhook URL

- Now open the crontab editor by enter `crontab -e`
- Add these lines to the crontab file:
```
0 12 * * * /usr/local/bin/tempo-autoshutdown.sh
@reboot /usr/local/bin/tempo-autoshutdown.sh
```
Ctrl+O and Ctrl+X to save and exit.
- Run the script by running this command `./tempo-autoshutdown.sh`
> Be sure to be in `/usr/local/bin/` directory before run the script.

# View the log file

Automatically, the script save a output log every time the script is run.
To view the logs, run this command:
```
cat /var/log/tempo-autoshutdown.log
```

# Bonus: Add auto wake feature

I have also added a auto wake feature everyday at 22h (10 PM) in my BIOS/UEFI configuration by a RTC Wake event. To add a RTC Wake event, there are many tutorials to configure it according the manufacter of your motherboard.
> In some case, the BIOS/UEFI clock can be shifted of -1 or -2 hours. So if it's the case, and you want to wake the server at **22h (10 PM)**, configure the RTC Wake at 23h (11 PM) or 00h (12 nn).

# Contribution

Any contribution is welcome.
