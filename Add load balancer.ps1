
#Add Load Balancer for Public subnet with Public IP associated

$frontendIP = New-AzureRmLoadBalancerFrontendIpConfig -Name "PratFrontPool" -PublicIpAddress $publicIP
$backendPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "PratbackedPool"

$inboundNATPool = New-AzureRmLoadBalancerInboundNatPoolConfig -Name "PratRDPRule" -FrontendIpConfigurationId $frontendIP.Id -Protocol TCP -FrontendPortRangeStart 50001 -FrontendPortRangeEnd 50010 -BackendPort 3389

$lb = New-AzureRmLoadBalancer -ResourceGroupName $rgname -Name $lbname -Location $location -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendPool -InboundNatPool $inboundNATPool

Add-AzureRmLoadBalancerProbeConfig -Name "PratHealthProbe" -LoadBalancer $lb -Protocol TCP -Port 80 -IntervalInSeconds 15 -ProbeCount 2

Add-AzureRmLoadBalancerRuleConfig -Name "PratLBRule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol TCP -FrontendPort 80 -BackendPort 80

Set-AzureRmLoadBalancer -LoadBalancer $lb

$ipConfig = New-AzureRmVmssIpConfig -Name "PratIPConfig" -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools[0].Id -LoadBalancerInboundNatPoolsId $inboundNATPool.Id -SubnetId $vnet.frontendSubnets[0].id

#Add Load Balancer for private Subnet

$frontendIP1 = New-AzureRmLoadBalancerFrontendIpConfig -Name LB-Frontend -PrivateIpAddress 10.0.2.5 -SubnetId $vnet.subnets[0].Id
$beaddresspool= New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "LB-backend"

$inboundNATRule1= New-AzureRmLoadBalancerInboundNatRuleConfig -Name "RDP1" -FrontendIpConfiguration $frontendIP1 -Protocol TCP -FrontendPort 3441 -BackendPort 3389

$inboundNATRule2= New-AzureRmLoadBalancerInboundNatRuleConfig -Name "RDP2" -FrontendIpConfiguration $frontendIP1 -Protocol TCP -FrontendPort 3442 -BackendPort 3389

$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name "HealthProbe" -RequestPath "HealthProbe.aspx" -Protocol http -Port 80 -IntervalInSeconds 15 -ProbeCount 2

$lbrule = New-AzureRmLoadBalancerRuleConfig -Name "HTTP" -FrontendIpConfiguration $frontendIP1 -BackendAddressPool $beAddressPool -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80

$NRPLB = New-AzureRmLoadBalancer -ResourceGroupName $rgname -Name "NRP-LB" -Location $location -FrontendIpConfiguration $frontendIP1 -InboundNatRule $inboundNATRule1,$inboundNatRule2 -LoadBalancingRule $lbrule -BackendAddressPool $beAddressPool -Probe $healthProbe