########################################################
#
# Script para coleta de dados de logs para estudo. 
# Author: @mtheus
# PowerShell.exe -executionpolicy bypass -command "& { . C:\projetos\collect.ps1 -mode silent }"
# PowerShell.exe "iex (New-Object System.Net.WebClient).DownloadString('C:\projetos\collect.ps1')"
# file:///C:/projetos/collect.ps1
# PowerShell.exe "iex ((New-Object System.Net.WebClient).DownloadString('https://software-reliability.web.app/collect.ps1'))"
########################################################

param([string]$mode="")

cls

$MachineGuid=([string]( Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Cryptography -Name "MachineGuid" ).MachineGuid)

function Collect-Silent {

	Write-Host "Silent Mode"
	Write-Host "Iniciando a coleta..."
	Write-Host "id:$MachineGuid"
	Main
	Write-Host "Coleta finalizada."
}

function Collect {	

	Write-Host ''
	Write-Host 'Obrigado pela sua contribuição. Vamos iniciar o processo de coleta e ao final você será direcionado para o nosso site para visualizção dos resultados. ' -ForegroundColor Magenta
	Write-Host ''
	
	#TODO: Elaborar um texto melhor

	$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
	$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Sim', 'Significa que você concorda e iremos proesseguir.'))
	$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Não', 'Significa que você discorda e desistiu de executar o programa. '))

	$decision = $Host.UI.PromptForChoice('', 'Você está de acordo?', $choices, 1)
	if ($decision -eq 0) {
		Write-Host ""
		Write-Host "Confirmado. Iniciando a coleta..."
		Write-Host "id:$MachineGuid"
		Main		
		Write-Host "Coleta finalizada. "
		Write-Host ""
		Write-Host "Agora você será direcionado para a página de resultados..."
		Write-Host "https://www.google.com/?q=$MachineGuid/"
		pause
		explorer """https://www.google.com/?q=$MachineGuid"""
		#Start-Process -FilePath explorer -ArgumentList """https://www.google.com/?q=$MachineGuid"""
	} else {
		Write-Host ""
		Write-Host "Desculpe, mas sem seu consentimento não podemos prosseguir." -ForegroundColor Magenta
		Write-Host ""
		#TODO: Site explicativo
		#explorer "https://www.google.com/?q=sdfsdfs"
		pause
	}

}

function Main {

	param([string] $tag="")
	
	Write-Host $env:temp
	
	if (Test-Path "$env:temp\$MachineGuid-application.csv") { Remove-Item "$env:temp\$MachineGuid-application.csv" }
	if (Test-Path "$env:temp\$MachineGuid-system.csv") { Remove-Item "$env:temp\$MachineGuid-system.csv" }
	
	Get-EventLog -LogName "Application" | Export-Csv -LiteralPath "$env:temp\$MachineGuid-application.csv" -NoTypeInformation
	Get-EventLog -LogName "System" | Export-Csv -LiteralPath "$env:temp\$MachineGuid-system.csv" -NoTypeInformation
	
	if (Test-Path "$env:temp\$MachineGuid.zip") { Remove-Item "$env:temp\$MachineGuid.zip" }
	
	$compress = @{
	  Path = "$env:temp\$MachineGuid-*"#, "C:\Reference\Images\*.vsd"
	  CompressionLevel = "Fastest"
	  DestinationPath = "$env:temp\$MachineGuid.zip"
	}
	Compress-Archive @compress
	
	Invoke-RestMethod -Uri "https://us-central1-software-reliability.cloudfunctions.net/teste?id=$MachineGuid" -Method Put -ContentType "application/zip" -InFile "$env:temp\$MachineGuid.zip"
	
	#(Get-Content 'inputfile.txt.') -replace '\|', "`r`n"
	
}

if ($mode -eq "silent") {
	Collect-Silent
} else {
	Collect 
}

