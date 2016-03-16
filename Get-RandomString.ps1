<#
.SYNOPSIS
    Example of getting random string
.DESCRIPTION
    Already said IT! :P
.NOTES
    Author         : Justin Bennett (cajeeper@gmail.com)
	Contact  : http://www.allthingstechie.net
	Date           : 2016-03-16
	Revision : v1.0
	Changes  : 	v1.0 Original
#>
#random complex string, length of 10
( 1..10 | % { "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`~!@#$%^&*()-=_+[{}]\
|,<>./?".ToCharArray() | Get-Random } ) -join ''

#random basic string, length of 10
( 1..10 | % { "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray() | Get-Random } ) -join ''
