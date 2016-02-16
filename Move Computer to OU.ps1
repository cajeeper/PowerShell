<#
.SYNOPSIS
    Move Computer to new organizationalUnit
.DESCRIPTION
    Already said IT! :P
.NOTES
    Author         : Justin Bennett (cajeeper@gmail.com)
	Contact  : http://www.allthingstechie.net
	Date           : 2016-02-16
	Revision : v1.1
	Changes  : 	v1.0 Original
				v1.1 Added Tree View
.LINK
.PARAMETER ComputerName
  The computer's name to move to a new organizationalUnit - Default is current computer's name
.EXAMPLE
  C:\PS> #Move Current Computer to new OU
  C:\PS> Move-Ou 
.EXAMPLE
  C:\PS> #Move Computer "ServerA" to new OU
  C:\PS> Move-Ou -ComputerName "ServerA"
#>
function Move-Ou {

     [CmdletBinding()]  
      param (  
		   [parameter(Mandatory=$False)] [string] $ComputerName = "$($env:computername)"
		   )
	$wshell = New-Object -ComObject Wscript.Shell

	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

	$root = new-object System.DirectoryServices.DirectoryEntry
	$DirSearcher = new-object System.DirectoryServices.DirectorySearcher($root)
	$DirSearcher.PageSize = 100000
	$DirSearcher.SizeLimit = 100000

	#Get Current Computer's Location
	$DirSearcher = new-object System.DirectoryServices.DirectorySearcher($root)
	$DirSearcher.filter = "(&(name=$($ComputerName)))"
	$results = $DirSearcher.findall()
	if($results.count -eq 1) {
		$CurrentLocation = $results[0].Path

		#Get Current Computer's OU
		$CurrentOU = (new-object System.DirectoryServices.DirectoryEntry($results[0].Path)).Parent

		#Get OUs
		$DirSearcher.filter = "(|(objectCategory=organizationalUnit)(objectCategory=Container))"
		$results = $DirSearcher.findall()
		$compOUs =  $results | ? { $_.Path -match "Campus|Servers,|Computers|ComputerFolder" }

		$objForm = New-Object System.Windows.Forms.Form 
		$objForm.Text = "Move Computer ($($ComputerName)) to AD Organizational Unit"
		$objForm.Size = New-Object System.Drawing.Size(800,600) 
		$objForm.StartPosition = "CenterScreen"

		$objForm.KeyPreview = $True

		$objLabel = New-Object System.Windows.Forms.Label
		$objLabel.Location = New-Object System.Drawing.Size(10,20) 
		$objLabel.Size = New-Object System.Drawing.Size(770,20) 
		$objLabel.Text = "Current ou: $($CurrentOU -replace "LDAP://")"
		$objForm.Controls.Add($objLabel) 

		$imagelist1 = New-Object System.Windows.Forms.ImageList
		$imagelist1.Images.Add([System.Drawing.Image]::FromFile(".\folder.bmp"))
		
		
		# Make TreeView to hold the Domain Tree

		$TV = new-object windows.forms.TreeView
		$TV.Location = new-object System.Drawing.Size(10,40)  
		$TV.size = new-object System.Drawing.Size(770,420)  
		$TV.Anchor = "top, left, right"   
		$TV.ImageList = $imagelist1
  
		$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
			 {
				 $global:x = $objCombobox.SelectedItem
				 $objForm.Close()
			 }
			})

		$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
			 {$objForm.Close()}})

		$OKButton = New-Object System.Windows.Forms.Button
		$OKButton.Location = New-Object System.Drawing.Size(610,510)
		$OKButton.Size = New-Object System.Drawing.Size(75,30)
		$OKButton.Text = "Select"

		$OKButton.Add_Click(
			{
				 $global:x = new-object system.directoryservices.directoryEntry("LDAP://$($TV.SelectedNode.name)") 
				 $objForm.Close()
			})

		$objForm.Controls.Add($OKButton)

		$CancelButton = New-Object System.Windows.Forms.Button
		$CancelButton.Location = New-Object System.Drawing.Size(700,510)
		$CancelButton.Size = New-Object System.Drawing.Size(75,30)
		$CancelButton.Text = "Cancel"
		$CancelButton.Add_Click({$objForm.Close()})
		$objForm.Controls.Add($CancelButton)

		# Create a TreeNode for the domain root found

		$TNRoot = new-object System.Windows.Forms.TreeNode("Root")
		$TNRoot.Name = $root.distinguishedName
		$TNRoot.Text = $root.distinguishedName
		$TNRoot.tag = "NotEnumerated"
		$TNRoot.ImageIndex = 0
		
		
		# First time a Node is Selected, enumerate the Children of the selected DirectoryEntry

		$TV.add_AfterSelect({
			if ($this.SelectedNode.tag -eq "NotEnumerated") {

				$de = new-object system.directoryservices.directoryEntry("LDAP://$($this.SelectedNode.name)")

				# Add all Children found as Sub Nodes to the selected TreeNode

				$de.get_Children() | ? { $_.Path -match "Campus|Servers,|Computers|ComputerFolder" -and $_.objectCategory -match "Organizational-Unit|Container" } | % {
					$TN = new-object System.Windows.Forms.TreeNode
					$TN.Name = $_.distinguishedName
					$TN.Text = $_.name
					$TN.tag = "NotEnumerated"
					$TN.ImageIndex = 0
					$this.SelectedNode.Nodes.Add($TN)
				}

				# Set tag to show this node is already enumerated

				$this.SelectedNode.tag = "Enumerated"
				$this.SelectedNode.Expand()
			}
		})

		# Add the RootNode to the Treeview

		[void]$TV.Nodes.Add($TNRoot)
		
		# Add the Controls to the Form

		$objForm.Controls.Add($TV) 
	
		$objForm.Topmost = $True

		$objForm.Add_Shown({$objForm.Activate()})
		[void] $objForm.ShowDialog()

		if ($x -ne $null) {
			try {
				$DirSearcher = new-object System.DirectoryServices.DirectorySearcher($root)
				$DirSearcher.filter = "(&(name=$($ComputerName)))"
				$results = $DirSearcher.findall()
				$ADComputer = [adsi]($results.path)
				
				$ADComputer.psbase.moveto([adsi]($x.path))
				
				$DirSearcher = new-object System.DirectoryServices.DirectorySearcher($root)
				$DirSearcher.filter = "(&(name=$($ComputerName)))"
				$results = $DirSearcher.findall()
				$wshell.Popup("Operation Completed - Computer path now $($results.path)",0,"Done",0x1)
				} catch { $wshell.Popup("Operation Failed - $($_)",0,"Error",0x1)}
			}
	} else { $wshell.Popup("Operation Failed - ComputerName $($ComputerName): Not Found or More Than One Found",0,"Error",0x1) }
}

Move-Ou