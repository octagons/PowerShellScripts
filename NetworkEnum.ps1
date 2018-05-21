#requires -version 2

function Get-NetStat
{
<#
.SYNOPSIS
    This function will get the output of netstat and parse the output
.DESCRIPTION
    This function will get the output of netstat and parse the output.
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
        $Network = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
        $TCPConnections = $Network.GetActiveTcpConnections()
        $TCPListeners = $Network.GetActiveTcpListeners()
        $UDPListeners = $Network.GetActiveUdpListeners()
    }
    PROCESS
    {
        ForEach ($Connection in $TCPListeners) {
            $NetworkConnection = New-Object -TypeName PSObject
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalAddress" -Value $Connection.Address
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalPort" -Value $Connection.Port
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value "0.0.0.0"
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemotePort" -Value 0
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $False
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "State" -Value "Listening"
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Protocol" -Value "TCP"
            $NetworkConnection
            }

        ForEach ($Connection in $TCPConnections) {
            if (($Connection.LocalEndPoint.Address -eq '127.0.0.1') -and (!$ShowLocalhost)) {
                break
            }            
            $NetworkConnection = New-Object -TypeName PSObject
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalAddress" -Value $Connection.LocalEndPoint.Address
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalPort" -Value $Connection.LocalEndPoint.Port
            if ($ResolveForeign) {
                Try
                {
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value ([Net.DNS]::GetHostEntry($Connection.RemoteEndPoint.Address)).HostName
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemotePort" -Value $Connection.RemoteEndPoint.Port
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $True
                }
                Catch 
                {
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value $Connection.RemoteEndPoint.Address
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemotePort" -Value $Connection.RemoteEndPoint.Port
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $False
                }
                } 
            else 
                {
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value $Connection.RemoteEndPoint.Address
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemotePort" -Value $Connection.RemoteEndPoint.Port
                    $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $False
                }
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "State" -Value $Connection.State
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Protocol" -Value "TCP"
            $NetworkConnection
            }

        ForEach ($Connection in $UDPListeners) {
            $NetworkConnection = New-Object -TypeName PSObject
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalAddress" -Value $Connection.Address
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "LocalPort" -Value $Connection.Port
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value "0.0.0.0"
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "RemotePort" -Value "0"
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Resolved" -Value $False
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "State" -Value "Listening"
            $NetworkConnection | Add-Member -MemberType NoteProperty -Name "Protocol" -Value "UDP"
            $NetworkConnection
            }
    }
}
