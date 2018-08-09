#requires -version 2

function Get-NetStat
{
<#
.SYNOPSIS
    Enumerate network connections with win32 APIs.
.DESCRIPTION
    This function obtains information about the hosts's current network using pure win32 API calls.
    Credit for the connection enumeration snippet: http://techibee.com/powershell/query-list-of-active-tcp-connections-in-windows-using-powershell/2341
.PARAMETER ResolveForeign
    Switch. Specifies whether to resolve the foreign addresses (Default: Disabled)
.PARAMETER ShowLocalhost
    Switch. Specifies whether to show connections to or from the localhost address
.OUTPUTS

NetworkEnum.NetworkConnection

#>
    [OutputType('NetworkEnum.NetworkConnection')]
    [CmdletBinding()]
    Param (
        [Switch]
        $ResolveForeign,

        [Switch]
        $ShowLocalhost
        )
    BEGIN
    {
        $TCPProperties = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
        $Connections = $TCPProperties.GetActiveTcpConnections()
 
    }
    PROCESS
    {
        ForEach ($Connection in $Connections){
            if (($Connection.LocalEndPoint.Address -eq '127.0.0.1') -and ( -not $ShowLocalhost))
                {
                    break
                }
            $NetworkConnection = New-Object -TypeName PSObject
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalAddress" -Value $Connection.LocalEndPoint.Address
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalPort" -Value $Connection.LocalEndPoint.Port

            if ($ResolveForeign){
                Try
                {
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value ([Net.DNS]::GetHostEntry($Connection.RemoteEndPoint.Address)).HostName
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $True
                }
                Catch [System.Net.Sockets.SocketException]
                {
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value $Connection.RemoteEndPoint.Address
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $False
                }
                } else {
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value $Connection.RemoteEndPoint.Address
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $False
                }
            
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemotePort" -Value $Connection.RemoteEndPoint.Port
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "State" -Value $Connection.State
            $NetworkConnection
            }
    }
}

