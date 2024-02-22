$form = New-Object System.Windows.Forms.Form
$form.Text = "Denis Toolbox"
$form.Size = New-Object System.Drawing.Size(600, 500)

# Creating six buttons
$button1 = New-Object System.Windows.Forms.Button
$button1.Text = "Disk Management"
$button1.Size = New-Object System.Drawing.Size(150, 50)

$button2 = New-Object System.Windows.Forms.Button
$button2.Text = "Firewall"
$button2.Size = New-Object System.Drawing.Size(150, 50)

$button3 = New-Object System.Windows.Forms.Button
$button3.Text = "Activate Hyper-V"
$button3.Size = New-Object System.Drawing.Size(150, 50)

$button4 = New-Object System.Windows.Forms.Button
$button4.Text = "Network Adapters Configuration"
$button4.Size = New-Object System.Drawing.Size(150, 50)

$button5 = New-Object System.Windows.Forms.Button
$button5.Text = "Password Generator"
$button5.Size = New-Object System.Drawing.Size(150, 50)

$button6 = New-Object System.Windows.Forms.Button
$button6.Text = "System Information"
$button6.Size = New-Object System.Drawing.Size(150, 50)

# Event handler for Button 1 click
$button1.Add_Click({
    OpenDiskManagement
})

# Event handler for Button 2 click
$button2.Add_Click({
    # Launch Windows Firewall with Advanced Security console
    Start-Process "wf.msc"
})

# Event handler for Button 3 click
$button3.Add_Click({
    # Content of the Hyper V activation Batch file 
    $batchScript = @"
pushd "%~dp0"
dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt
for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
del hyper-v.txt
Dism /online /enable-feature /featurename:Microsoft-Hyper-V -All /LimitAccess /ALL
pause
"@

    # Specify the path for the batch script on the desktop
    $desktopPath = [System.Environment]::GetFolderPath('Desktop')
    $batchScriptPath = Join-Path -Path $desktopPath -ChildPath 'Enable_Hyper-V.bat'

    # Write the batch script content to the file
    Set-Content -Path $batchScriptPath -Value $batchScript

    # Inform the user about the location of the created batch script
    [System.Windows.Forms.MessageBox]::Show("Batch script to enable Hyper-V feature has been created on your desktop.", "Information")
})

# Function to list Network Adapter Configuration
function ListIPAddresses {
    $command = "Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | Select-Object -ExpandProperty IPAddress"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $command
}

# Event handler for Button 4 click
$button4.Add_Click({
    # Get network adapter configurations
    $networkAdapters = Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true

    # Network adapter information message
    $message = @"
Network Adapter Configuration:
-------------------------------
$($networkAdapters | Format-Table -AutoSize | Out-String)
"@.Trim()

    # Display network adapter information in a message box
    [System.Windows.Forms.MessageBox]::Show($message, "Network Adapter Configuration", "OK", "Information")
})

# Event handler for Button 5 click
$button5.Add_Click({
    # Define the character set for the password
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?'

    # Initialize an empty string to store the password
    $password = ""

    # Generate 14 random characters from the character set
    1..14 | ForEach-Object {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }

    # Display the generated password in a message box with a Copy button
    $result = [System.Windows.Forms.MessageBox]::Show("Generated Password: $password`n`nDo you want to copy this password to the clipboard?", "Random Password Generator", "YesNoCancel", "Information")

    if ($result -eq "Yes") {
        # Copy the password to the clipboard
        [System.Windows.Forms.Clipboard]::SetText($password)
        [System.Windows.Forms.MessageBox]::Show("Password copied to clipboard.", "Random Password Generator", "OK", "Information")
    }
})

# Event handler for Button 6 click
$button6.Add_Click({
    # Get system information
    $systemInfo = Get-CimInstance -ClassName Win32_ComputerSystem
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $networkInfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

    # Construct system information message
    $message = @"
System Information:
--------------------
Computer Name: $($systemInfo.Name)
Manufacturer: $($systemInfo.Manufacturer)
Model: $($systemInfo.Model)
OS Version: $($osInfo.Caption) $($osInfo.Version)
Installed Memory: $([math]::Round($systemInfo.TotalPhysicalMemory / 1GB)) GB
IP Address: $($networkInfo.IPAddress)
"@.Trim()

    # Display system information in a message box
    [System.Windows.Forms.MessageBox]::Show($message, "System Information", "OK", "Information")
})

# Function to open Disk Management
function OpenDiskManagement {
    Start-Process "diskmgmt.msc"
}

# Function to calculate buttons positions so whenever I resize the GUI,the buttons match the layout
function UpdateButtonPositions {
    $button1.Location = New-Object System.Drawing.Point([Math]::Round($form.ClientSize.Width * 0.1), [Math]::Round($form.ClientSize.Height * 0.1))
    $button2.Location = New-Object System.Drawing.Point([Math]::Round($form.ClientSize.Width * 0.1), [Math]::Round($form.ClientSize.Height * 0.4))
    $button3.Location = New-Object System.Drawing.Point([Math]::Round($form.ClientSize.Width * 0.1), [Math]::Round($form.ClientSize.Height * 0.7))
    $button4.Location = New-Object System.Drawing.Point([Math]::Round($form.ClientSize.Width * 0.6), [Math]::Round($form.ClientSize.Height * 0.1))
    $button5.Location = New-Object System.Drawing.Point([Math]::Round($form.ClientSize.Width * 0.6), [Math]::Round($form.ClientSize.Height * 0.4))
    $button6.Location = New-Object System.Drawing.Point([Math]::Round($form.ClientSize.Width * 0.6), [Math]::Round($form.ClientSize.Height * 0.7))
}

# Add buttons to form
$form.Controls.AddRange(@($button1, $button2, $button3, $button4, $button5, $button6))

# Initial button positions
UpdateButtonPositions

# Event handler for form resize
$form.Add_Resize({
    UpdateButtonPositions
})

# Show the form
$form.ShowDialog() | Out-Null
