# Start-Cisco-VPN
Prompt user to login to Cisco VPN when not on the Rutgers network

Powershell script is designed to be run with Cisco AnyConnect client version 5.1x.
  1. Download the script, start-vpn.psi copy it to a location on your domain server for distribution.
  2. Create a GPO for the distribution on your domain. (Computer configuration > Preferences > Windows Settings > Files)
    3. Pick a location you can save it to on your local machines, ie: c:\system\start.vpn.ps1
  4. Add a scheduled task in your GPO (Computer Configuration > Control Panel Settings > Scheduled Tasks
    5. Action: Replace
       Name: StartVPN. <BR>
       When running the task, use the following user account: BUILTIN\Users
       Run with highest privileges (check box)
       Configure for: Windows Vista or Windows Server 2008
       Triggers: At log on: At log on of any user. (I also do weekly at 9:30am every weekday).
       Actions: Start a program:
             Program/script: conhost.exe
             Add arguments: --headless powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\systems\start-vpn.ps1"
       Common: Remove this item when it is no longer applied (checked).
     


<img width="1247" height="527" alt="image" src="https://github.com/user-attachments/assets/0c3d9a45-6c62-40c0-9497-8f6fa19f32df" />

<img width="1214" height="829" alt="image" src="https://github.com/user-attachments/assets/1590cf9c-6dc3-4361-971b-9e4acd0a465f" />

<img width="1107" height="490" alt="image" src="https://github.com/user-attachments/assets/ebffe7fe-a45f-498a-a751-3b86c1361ae7" />
