<#######<Script>#######>
<#######<Header>#######>
# Name: Start-Cisco-VPN
# Authors: Ed Smith and Sarah Ramos, Rutgers University Libraries, https://www.libraries.rutgers.edu 
# Date 2025-01-24
# Script modified from: Gerry Williams,  https://automationadmin.com/2018/04/ps-autolaunch-cisco-anyconnect-vpn/
# This work is licensed under CC BY-NC-SA 4.0, https://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1
<#######</Header>#######>
<#######<Body>#######>

# goto function from: https://pavolkutaj.medium.com/how-to-bring-program-to-the-front-with-powershell-8c3f8b3cfc8f#:~:text=For%20example%2C%20bringing%20a%20running,static%20extern%20method%20for%20SetForegroundWindow%20.

function goto ($process_name) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Program {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

    $processes = Get-Process -Name "*${process_name}*"
    $process = $processes | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($process) {
        $hwnd = $process.MainWindowHandle
        [Program]::SetForegroundWindow($hwnd)
    } else {
        Write-Host "Program is not running or does not have a MainWindowHandle."
    }
}

$wshell = New-Object -ComObject wscript.shell
Add-Type -AssemblyName System.Windows.Forms

Function Start-VPN
{
   <#
.Description
Starts a VPN connection assuming you have internet and are not already connected to internal network.
#>

   [Cmdletbinding()]
   Param
   (
   )
      
   Begin
   {       
   }
      
   Process
   {   
      Try
      {
   #A - checks for RU network connection; B - checks for internet connection              
            $A = Test-Connection -Computername rad.rutgers.edu -Quiet -Count 2
  			$B = Test-Connection -Computername 8.8.8.8 -Quiet -Count 2
         
            If ($A) 
            {
               $Internal = 1
               $Justinternet = 0
               $Notconnected = 0
               Write-Output "Connected to internal network already"
			   
	       }
            Elseif ($B)
            {
               $Internal = 0
               $Justinternet = 1
               $Notconnected = 0
               Write-Output "Connected to internet, but not Rutgers network. Need to start VPN!"
             
           	Function MsgBox($Message, $Title)
		{
   			[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
   			[Microsoft.VisualBasic.Interaction]::MsgBox($Message, "SystemModal,Exclamation", $Title)
		}
		MsgBox "For your security, please connect to the Libraries encrypted VPN, vpn.rutgers.edu" "Connect to VPN"

            }
            Else
            {
               $Internal = 0
               $Justinternet = 0
               $Notconnected = 1
               Write-Output "Not connected to the internet"
            }
#To test while on campus and execute VPN client, change from 1 to 0
            If ($Justinternet -Eq 1)
            {
               Get-Process | Foreach-Object `
               {
                  If ($_.Processname.Tolower() -Eq "csc_ui")
                  {
                        $Id = $_.Id; Stop-Process $Id -Force
                  }
               }
               Get-Process | Foreach-Object `
               {
                  If ($_.Processname.Tolower() -Eq "Vpnui")
                  {
                        $Id = $_.Id; Stop-Process $Id -Force
                  }
               }
	#old VPN client	4.8
               if (Test-Path -Path "C:\Program Files (X86)\Cisco\Cisco Anyconnect Secure Mobility Client\Vpnui.Exe") 
               {
                  Start-Process -Filepath "C:\Program Files (X86)\Cisco\Cisco Anyconnect Secure Mobility Client\Vpnui.Exe"
			Start-Sleep -Seconds 3
			goto("Vpnui")
			[System.Windows.Forms.SendKeys]::SendWait("{TAB}"*3)
			$wshell.SendKeys('vpn.rutgers.edu')
			[System.Windows.Forms.SendKeys]::SendWait("{TAB}{TAB}{TAB}{ENTER}")
               }
	#new VPN client 5.1x  
		   elseif (Test-Path -Path "C:\Program Files (X86)\Cisco\Cisco Secure Client\UI\csc_ui.exe") 
               {
               	Start-Process -Filepath "C:\Program Files (X86)\Cisco\Cisco Secure Client\UI\csc_ui.exe"
			Start-Sleep -Seconds 3
			goto("csc_ui")
			[System.Windows.Forms.SendKeys]::SendWait("{TAB}"*9)
			$wshell.SendKeys('vpn.rutgers.edu')
			[System.Windows.Forms.SendKeys]::SendWait("{TAB}{ENTER}")
               } 
               else
               {
               	Write-Output "Cisco VPN is not on this device."
			Exit
               }
              
            }
            Else
            {
               # Do nothing
            }

      }
      Catch
      {
         Write-Error -Message $($_.Exception.Message)
      }
   }

   End
   {
         
   }

}

Start-VPN
<#######</Body>#######>
<#######</Script>#######>