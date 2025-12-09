# PowerShell Script to Forward Port 3000 to default WSL2 Instance
# ADMINISTRATOR PRIVILEGES REQUIRED

# 1. Get the current IP of your WSL2 instance
# (We trim whitespace and split to get just the first IP if multiple exist)
$wsl_ip = (wsl hostname -I).Trim().Split(" ")[0]

# 2. Update the Port Forwarding Rule
# (Netsh will overwrite the old rule for port 3000 automatically)
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=$wsl_ip

# 3. Output success message
Write-Host "Port 3000 forwarded to WSL IP: $wsl_ip" -ForegroundColor Green