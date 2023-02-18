<# CSV data file format

FirstName,LastName,Description
Odolen,Hayek,Description One
Talula,Wawra,Description Two
Leonora,Vrabel,Description Three
Moris,Koprziva,Description Four.
Parsival,Léharová,Description five.
Bojislava,Stehlík,Description Six
Robert,Zaruba,Description Seven.
Lucian,Zeman,Ing. arch.
Lilith,Burian,Description Nine
Jorga,Mašín,Description Ten

#>

# Local Admin Group
$group = "Administrators"

# Import the CSV data file
$CSVFile = ".\PathToCSV_File.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter "," -Encoding UTF8


Foreach($User in $CSVData){

    $UserFirstName = $User.FirstName
    $UserLastName = $User.LastName
    $UserDescription = $User.Description

    # For login username as first letter . last name (e.g: if name is John Doe, login will be jdoe)
    $UserLogin = ($UserFirstName).Substring(0,1) + $UserLastName

    $UserPassword = ConvertTo-SecureString "SomeRandomPassw0rd" -AsPlainText -Force
    
    # Verify that the user to be added does not already exist
    if (Get-LocalUser | Where-Object {$_.Name -eq $UserLogin})
    {
        Write-Warning "The user $UserLogin already exists"
    }
    else {
        New-LocalUser -FullName "$UserFirstName $UserLastName" `
                      -Name $UserLogin `
                      -Description "$UserDescription" `
                      -Password $UserPassword
                      
        Add-LocalGroupMember -Group $group -Member $UserLogin

        # Set users password to be changed at next logon
        $TmpUser = [ADSI]"WinNT://localhost/$UserLogin,user"
        $TmpUser.passwordExpired = 1
        $TmpUser.setinfo()

        Write-Host "User $UserLogin has been added to $group Group"
    }

}
