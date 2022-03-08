function Random-Capitalization
{
	Param( 
	[Parameter(Mandatory=$True)] [String]$Text
	)
	Switch(1..4 | Get-Random)
	{
		1 { Return (Get-Culture).TextInfo.ToLower($text) }
		2 { Return (Get-Culture).TextInfo.ToUpper($text) }
		3 { Return (Get-Culture).TextInfo.ToTitleCase($text) }
		4 { Return $text }
		default { Return $text }
	}
}

function Generate-Passphrase
{
	Param( 
	[Parameter(Mandatory=$True)] [String]$DictionaryFile, 
	[ValidateRange(10,999)][Int]$MinLength = 18, 
	#[ValidateScript({if($_ -ge $MinLength) { $true } else {	Throw [System.Management.Automation.ItemNotFoundException] "Parameter MaxLength ($($_)) cannot be less than MinLength ($($MinLength))"}})][Int]$MaxLength = 40,
	[ValidateRange(2,999)][Int]$MinWords = 4,
	[ValidateRange(1,100)][Int]$Count = 1
	) 
	Begin {
		$Dictionary = Get-Content -Path $DictionaryFile
	}
	Process {
		1..$Count | % {
			#Randomize the actual length break
			[Int]$RandomMaxLength = Get-Random -Minimum $MinLength -Maximum ($MinLength+8)
			
			#Random Number Block as first or second word - first two word blocks
			if(Get-Random -C 1 -I $true,$false) {
				[string]$Result = "$((-join(48..57|%{[char]$_}|Get-Random -C (get-random -Minimum 2 -Maximum 5)))) $((Get-Culture).TextInfo.ToTitleCase($Dictionary[(Get-Random -Minimum 0 -Maximum $Dictionary.Length)]))" } else { [string]$Result = "$((Get-Culture).TextInfo.ToTitleCase($Dictionary[(Get-Random -Minimum 0 -Maximum $Dictionary.Length)])) $((-join(48..57|%{[char]$_}|Get-Random -C (get-random -Minimum 3 -Maximum 5))))" }
			
			[Int]$WordCount = 2
			
			#Keep grabbing random words until min/max are satisfied
			while($Result.length -lt $RandomMaxLength -or $WordCount -lt $MinWords) {
				$Result = "$($result) $((Random-Capitalization $Dictionary[(Get-Random -Minimum 0 -Maximum $Dictionary.Length)]))"
				$WordCount++
			}
			Return [string]$Result
		}
	}
	End {
		Remove-Variable Result,Dictionary,RandomMaxLength,WordCount
	}
<#
.SYNOPSIS

	Generates random passphrase(s) with a random block of numbers in the first or second block of words. Word blocks are capitalized.

.DESCRIPTION

	This function will generate random passphrase(s) with the help of a dictionary file parsed by carriage returns.
	Tested with a modified version of https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt by removing the first column in the tab delaminated file.
	
.INPUTS

	None. You cannot pipe objects to Generate-Passphrase.

.OUTPUTS

	System.String. Generate-Passphrase returns a single or multiple passphrases.

.PARAMETER DictionaryFile

	The filename of the word list
	
.PARAMETER MinLength

	The minimum characters the passphrase length needs to be returned.
	
# .PARAMETER MaxLength

	# The maximum characters the passphrase length needs to be returned. Must be larger or equal to the MinLength.
	# *Note: It may return a longer in order to meet the MinWords parameter requirement.
	
.PARAMETER MinWords

	The minimum word blocks the passphrase needs to have returned.
	
.PARAMETER Count

	The number of passphrases to be returned.
	
.EXAMPLE

	PS C:\>Generate-Passphrase -DictionaryFile file.txt -MinWords 3 -MinLength 16 -MaxLength 30 -Count 1
	Politely 391 Ether
	
	This example will generate a passphrase.
	
.EXAMPLE

	PS C:\>Generate-Passphrase -DictionaryFile file.txt -MinWords 3 -MinLength 16 -MaxLength 30 -Count 1
	Scheming 0289 Huddle
	8546 Citation Huff
	
	This example will generate two passphrases.
	
.NOTES

	Author:Justin Bennett
	Last Modified: 9/19/2019
	
#>
}
