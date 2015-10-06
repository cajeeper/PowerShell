function Out-DataTable
{
    [CmdletBinding()]
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject)


    Begin
    {
        $dt = new-object Data.datatable  
        $First = $true 
    }
    Process
    {
        foreach ($object in $InputObject)
        {
            $DR = $DT.NewRow()  
            foreach($property in $object.PsObject.get_properties())
            {  
                if ($first)
                {  
                    $Col =  new-object Data.DataColumn  
                    $Col.ColumnName = $property.Name.ToString()  
                    if ($property.value)
                    {
                        if ($property.value -isnot [System.DBNull])
                        { $Col.DataType = $property.value.gettype() }
                    }
                    $DT.Columns.Add($Col)
                }  
                if ($property.IsArray)
                { $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 }  
                else { $DR.Item($property.Name) = $property.value }  
            }  
            $DT.Rows.Add($DR)  
            $First = $false
        }
    } 


    End
    {
        Write-Output @(,($dt))
    }


}
