#Store App Paterns to get app paterns use wmi query and as example have left xbox app
$UWPAppspattern = @(

#"Microsoft.XboxApp*"

)

#New Array for full package names
$FullpackageNames = @()

foreach ($Pattern in $UWPAppspattern) {

Write-Host "[*] Getting Full Package Names of StoreApp -  $Pattern" -ForegroundColor Green
#Getting full name of store app and store full package names in new array list
$apps_name = Get-AppxPackage -AllUsers | Where-Object {$_.PackageFullName -like $Pattern} | select PackageFullName
$FullpackageNames += $apps_name

#Writing message if package is not found returns empty 
if ($FullpackageNames) {

    Write-Host "[*] Package Full Name Added to Array" -ForegroundColor Green

}
else{
    
    Write-Host "[*] Package Already Deleted" -ForegroundColor Red

}

}



#Write-Host $FullpackageNames.PackageFullName
#RemoveAppx UWP App

foreach ($i in $FullpackageNames.PackageFullName) {

 try {

        Write-Host "[*] Trying to remove $i" -ForegroundColor Green
        Get-AppxPackage -AllUsers | Where-Object PackageFullName -eq $i | Remove-AppxPackage -AllUsers -ErrorAction Continue
        Get-AppxPackage -allUsers $i | Remove-AppxPackage


        # Remove the app from the local Windows Image to prevent re-install on new user accounts
        Get-AppxProvisionedPackage -Online | Where-Object PackageFullName -eq $i | Remove-AppxProvisionedPackage -Online

        # Cleanup Local App Data
        $appPath="$Env:LOCALAPPDATA\Packages\$i"
        Remove-Item $appPath -Recurse -Force -ErrorAction 0

        Write-Host "[*] $i package successfully deleted" -ForegroundColor Green
 }

 Catch {

        $message = $_
        Write-Host "[*] $i Failed to remove package - $message" -ForegroundColor Red   
 
 }
 
}


#Removing Bundle Appx
foreach ($b in $UWPAppspattern) {

 try {

        Write-Host "[*] Trying to remove bundle $b" -ForegroundColor Green
        Get-AppxPackage -AllUsers -PackageTypeFilter Bundle -Name $b | Remove-AppxPackage -AllUsers -Confirm

        # Remove the app from the local Windows Image to prevent re-install on new user accounts
        Get-AppxProvisionedPackage -Online | Where-Object PackageFullName -eq $b | Remove-AppxProvisionedPackage -Online

        # Cleanup Local App Data
        $appPath="$Env:LOCALAPPDATA\Packages\$b"
        Remove-Item $appPath -Recurse -Force -ErrorAction 0

        Write-Host "[*] $b package successfully deleted" -ForegroundColor Green
 }

 Catch {

        $message = $_
        Write-Host "[*] $b Failed to remove package - $message" -ForegroundColor Red   
 
 }
 
}
