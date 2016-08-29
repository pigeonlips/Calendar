Function Get-Calendar {
<#
  .SYNOPSIS
  Returns a calender for the month.

  .DESCRIPTION
  Returns a calender for the month of a date passed in as a System Date Time Object.

  .PARAMETER Date
  Date object to use. Defaults to current date if not supplied.

  .PARAMETER Highlight
  A day or an array of days to highlight.

  .INPUTS
  [System.DateTime]

  .EXAMPLE
  PS> Get-Calendar -Date (Get-Date -month 1)
  # shows a calender for Janurary this year

  .EXAMPLE
  PS> Get-Calendar -Date (Get-Date -month 1) -Highlight (1..7)
  # shows a calender for Janurary this year, Highlighting the first 7 day

  .EXAMPLE
  PS> ls  | select -ExpandProperty LastWriteTime | % { Get-Calendar -Date $_  }
  # shows the LastwriteTime of all files in the current folder on a calender. One calender per file

  .NOTES
  Credit to the original author http://scriptolog.blogspot.co.nz/2008/02/2008-scripting-games-advanced-event-4.html
#>

  [CmdletBinding(
    ConfirmImpact='None',
    SupportsShouldProcess=$false
  )]

  Param(

    [Parameter(ValueFromPipeline = $True)]
    [System.DateTime]$Date = (Get-Date) ,

    [Parameter(ParameterSetName = "__AllParameterSets")]
    [System.Int32[]]$Highlight

  )

  $Year       = $Date.Year
  $Month      = $Date.Month

  # if no Highlight passed in as parameter then set it to be the day of the date object passed in
  If (-not $Highlight ) {

    $Highlight = $Date.Day

  }

  # only get the date of today if its showing the right month and year ...
  If ( ( $Year -eq (Get-Date).Year ) -and ( $Month -eq (Get-Date).Month ) ) {

    $today        = ( Get-Date ).Day

  } Else {

    $today        = -1

  } # end if we are showing a calender for this month

  $dtfi                = New-Object System.Globalization.DateTimeFormatInfo
  $AbbreviatedDayNames = $dtfi.AbbreviatedDayNames | ForEach-Object {" {0}" -f $_.Substring(0,2)}

  $header         = "$($dtfi.MonthNames[$Month-1]) $Year"
  $header         = ( " " * ( [math]::abs( 21-$header.length ) / 2) ) + $Header
  $header        += ( " " * ( 21 - $header.length ) )

  Write-Host
  Write-Host
  Write-Host $Header -BackgroundColor Magenta -ForegroundColor Black
  Write-Host ( -join $AbbreviatedDayNames ) -BackgroundColor Cyan -ForegroundColor Black

  $daysInMonth    = [DateTime]::DaysInMonth( $Year , $Month)
  $dayOfWeek      = ( New-Object DateTime $Year , $Month , 1 ).dayOfWeek.value__

  For ($i = 0; $i -lt $dayOfWeek; $i++) {

    Write-Host ( " " * 3 ) -NoNewline

  } # end blank spaces for days that are not the at the begining of the month

  For ( $i = 1 ; $i -le $daysInMonth ; $i++ ) {

    # highlight the day if its not today ...
    If ( ( $Highlight -eq $i ) -and ( $Highlight -ne $today ) ) {

      Write-Host ( "{0,3}" -f $i ) -NoNewline -BackgroundColor Yellow -ForegroundColor Black

    } Else {

      Write-Host ( "{0,3}" -f $i ) -NoNewline

    } # end if we want to highlight a day

    If ( $today -eq $i ) {

      Write-Host ("{0,3}" -f $i) -NoNewline -BackgroundColor Cyan -ForegroundColor Black

    } # end if its today

    If ( $dayOfWeek -eq 6 ) {

      Write-Host

    } # end if its the end of the week - for the newline

    $dayOfWeek = ( $dayOfWeek + 1 ) % 7

  } # end for each month

  If ( $dayOfWeek -ne 0 ) {

    Write-Host

  }

  # a few blank lines before the prompt.
  Write-Host
  Write-Host

}

# add an alias for cal but only if its not already used by somthing ...
If ( -not (Get-Alias cal) ) { Set-Alias Cal Get-Calendar }
