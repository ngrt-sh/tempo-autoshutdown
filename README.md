# tempo-autoshutdown
A fully customizable Proxmox bash script that automatically shutdown the server in a EDF Tempo red day.

# Explanations and context of my script creation

I created this bash script because I run a server in my homelab and also I live in France. In France, the main provider of electricity is EDF (Electricité De France) and we can have a contract called "Tempo". This contract provide us days called "Journée Bleue" (blue day), "Journée Blanche" (white day) and "Journée rouge" (red day). The red day is the worst day because the electricity price costs the most during peak hours (6 AM to 10 PM). So this is why I wanna make my own script to schedule automaticaly the power on and power off of my server.

# How it work?

I have found a *unoffical* Tempo API to fetch the color day of tomorrow. Everyday at 12h (or when the machine start), the bash script is automatically runned to fetch the tomorrow color day, if the API response request is "3" (red day), a shutdown at 6 AM tomorrow is scheduled and send a message to notify you of the shutdown via the Discord Webhook.

# Requirements

My script was tested on Proxmox VE 8.+ (Debian 12.x). It can works on some older versions of Proxmox VE or Debian but it haven't tested for.
> ⚠ **You need** to be **root** user! 
>
> Make sure you have `curl`, `jq` and `at` installed on your machine. Otherwise you need to run `apt install curl jq at`.

# Installation

## Upload script and setting up the permissions 

1. Use the `cd /usr/local/bin` command to be in your scripts directory.

2. After entering to the directory, upload (via SFTP) `tempo-autoshutdown.sh`. Modify the script file to add your Discord Webhook URL (do not modify other things than your Discord Webhook URL, only if you want make your proper version).

3. Setting up the permissions by running `chmod +x /usr/local/bin/tempo-autoshutdown.sh`.

## Setting the cronjob
For the script can be scheduled at 12h and/or at the startup of the server, we need to modify the cronjobs file.

1. Open the cronjobs editor by enter `crontab -e` command.

2.Just add these two lines at the end of the cronjob file:

```
0 12 * * * /usr/local/bin/tempo-autoshutdown.sh
@reboot /usr/local/bin/tempo-autoshutdown.sh
```

3. After added these two lines in our cronjob file, save your file and exit *nano* or *vim*.

## Testing

Before waiting a lot of time, I recommend you to run manually the script. It's not necessary but if you want check if the scheduled shutdown works great.

1. Make sure your are in the `/usr/local/bin/` directory and be sure the script is executable.

2. Run the script by running this command `./tempo-autoshutdown.sh`.

3. If it's configured, you will receive a Webhook notification and when the `atq` command is executed, you can view this output:
```
root@atlas:~# atq
2       Fri Jan 17 06:00:00 2025 a root
1       Fri Jan 17 06:00:00 2025 a root
```
As you can see, I have a scheduled shutdown for tomorrow.
> In my output it's 2 because I have tested the script before.

> The webhook preview:
> ![prev](https://github.com/ngrt-sh/tempo-autoshutdown/blob/main/Webhook_Preview.jpg?raw=true)

# Log file output

Automatically, the script save a output log every time the script is run.
To view the logs, run this command:
```
cat /var/log/tempo-autoshutdown.log
```

# Bonus: Add auto wake feature

I have also added a auto wake feature everyday at 22h (10 PM) in my BIOS/UEFI configuration by a RTC Wake event. To add a RTC Wake event, there are many tutorials to configure it according the manufacter of your motherboard.

> In some case, the BIOS/UEFI clock can be shifted of -1 or -2 hours. So if it's the case, and you want to wake the server at **22h (10 PM)**, configure the RTC Wake at 23h (11 PM) or 00h (12 nn) **in your BIOS/UEFI**.

# Contribution

Any contribution is welcome.
