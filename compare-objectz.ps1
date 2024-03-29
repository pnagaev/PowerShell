<#
Compare-Objectz.ps1

С помощью этого скрипта можно сравнивать два объекта PowerShell одного типа и выводить на экран только различающиеся свойства.

Это очень удобно при траблшутинге Exchange Server, когда у одного пользователя "что-нибудь" не работает, а у остальных работает и необходимо сравнить свойства почтового ящика.
А также при миграциях, когда необходимо создать ещё один объект - Receive  connector, Virtual Directory и т.д.

https://www.youtube.com/ITVideoPRO - канал про Exchange Server, PowerShell и безопасность.

#>

if ((Get-PSSession |where ConfigurationName -Eq "Microsoft.Exchange") -eq $null){

$s = New-PSSession -ConfigurationName Microsoft.Exchange `
					   -ConnectionUri http://$($env:COMPUTERNAME)/PowerShell/ `
					   -Authentication Kerberos
	Import-PSSession $s


}	


Function Compare-ObjectProperties {
    Param(
        [PSObject]$ReferenceObject,
        [PSObject]$DifferenceObject
        
    )
    $Exclusions = "WhenC|Server|ServerName|Identity|Id|Guid|FQDN|DistinguishedName|AdminDisplayVersion|MetabasePath"
    

    $objprops = $ReferenceObject   | Get-Member -MemberType Property,NoteProperty | % Name
    $objprops += $DifferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
    $objprops = $objprops | Sort | Select -Unique
    $diffs = @()
    foreach ($objprop in $objprops) {
        $diff = Compare-Object $ReferenceObject $DifferenceObject -Property $objprop
        if ($objprop -notmatch $Exclusions ){
        if ($diff) {            
            $diffprops = @{
                PropertyName=$objprop
                RefValue =($diff | ? {$_.SideIndicator -eq '<='} | % $($objprop))
                DiffValue=($diff | ? {$_.SideIndicator -eq '=>'} | % $($objprop))
            }
            $diffs += New-Object PSObject -Property $diffprops
        }     
        }   
    }
    if ($diffs) {return ($diffs | Select PropertyName,RefValue,DiffValue)}     
}
 



#$a=Get-OwaVirtualDirectory -Server MyServer1 
#$b=Get-OwaVirtualDirectory -Server MyServer2


#$a=Get-casmailbox irud
#$b=Get-casmailbox sbuldakov

$a=Get-ReceiveConnector "SRV02\Anonymous-senders"
$b=Get-ReceiveConnector "SRV02\Anonymous-senders-NEW"

$myd=Compare-ObjectProperties $a $b 
$myd |ogv

