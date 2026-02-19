<#
Функция, которая не выводит строки с пустыми свойствами, например 
get-service WSearch | fl *
содержит строки без значений.
Site                :
Container           :

get-service WSearch | Out-Clean
1.Отсортирует свойства по названию
2.Не выведет строки без значений(:и пусто) 

#>
function Out-Clean {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )
    process {
        foreach ($item in $InputObject) {
            $item.psobject.Properties | 
                Where-Object { 
                    $val = $_.Value
                    $null -ne $val -and ($val | Out-String).Trim() -ne "" 
                } | 
                Select-Object Name, @{Name="Value"; Expression={$_.Value.ToString()}} | 
                Sort-Object Name
        }
    }
}
