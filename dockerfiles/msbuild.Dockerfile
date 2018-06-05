FROM microsoft/windowsservercore
MAINTAINER chemso@gmx.de 

# docker push chemsorly/msbuilder
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Note: Get MSBuild 15 (VS 2017)
RUN Install-WindowsFeature NET-Framework-45-Core
RUN Invoke-WebRequest "https://aka.ms/vs/15/release/vs_BuildTools.exe" -OutFile vs_BuildTools.exe -UseBasicParsing ; \
	Start-Process -FilePath 'vs_BuildTools.exe' -ArgumentList '--quiet', '--norestart', '--locale en-US', '--all' -Wait ; \
	Remove-Item .\vs_BuildTools.exe ; \
	Remove-Item -Force -Recurse 'C:\Program Files (x86)\Microsoft Visual Studio\Installer'
RUN setx /M PATH $($Env:PATH + ';' + ${Env:ProgramFiles(x86)} + '\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin')

# Note: Add .NET + ASP.NET runtime
RUN Install-WindowsFeature NET-Framework-45-ASPNET
RUN Install-WindowsFeature Web-Asp-Net45

# Note: Add .NET 4.5 SDK (Windows 8)
RUN Invoke-WebRequest "http://download.microsoft.com/download/F/1/3/F1300C9C-A120-4341-90DF-8A52509B23AC/standalonesdk/sdksetup.exe" -OutFile "$env:TEMP\sdksetup.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup.exe" '/features + /q' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\sdksetup.exe"

# Note: Add .NET 4.6.2 SDK (Windows 10)
RUN Invoke-WebRequest "http://download.microsoft.com/download/6/3/B/63BADCE0-F2E6-44BD-B2F9-60F5F073038E/standalonesdk/SDKSETUP.EXE" -OutFile "$env:TEMP\sdksetup2.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup2.exe" '/features + /q' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\sdksetup2.exe"

# Note: Add .NET 4.7.1 SDK (Fixes some stuff for .net standard 2.0)
RUN Invoke-WebRequest "https://download.microsoft.com/download/9/0/1/901B684B-659E-4CBD-BEC8-B3F06967C2E7/NDP471-DevPack-ENU.exe" -OutFile "$env:TEMP\sdksetup3.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup3.exe" '/quiet' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\sdksetup3.exe"

# Note: Add .NET Core 1.1 SDK
RUN Invoke-WebRequest "https://download.microsoft.com/download/4/0/2/4022CFC7-5061-4762-B9BA-48B35632572D/dotnet-dev-win-x64.1.1.9.exe" -OutFile "$env:TEMP\sdksetup4.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup4.exe" '/quiet' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\sdksetup4.exe"

# Note: Add .NET Core 2.0 SDK
RUN Invoke-WebRequest "https://download.microsoft.com/download/3/7/1/37189942-C91D-46E9-907B-CF2B2DE584C7/dotnet-sdk-2.1.200-win-x64.exe" -OutFile "$env:TEMP\sdksetup5.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup5.exe" '/quiet' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\sdksetup5.exe"

# Note: Add .NET Core 2.1 SDK
RUN Invoke-WebRequest "https://download.microsoft.com/download/8/8/5/88544F33-836A-49A5-8B67-451C24709A8F/dotnet-sdk-2.1.300-win-x64.exe" -OutFile "$env:TEMP\sdksetup6.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup6.exe" '/quiet' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\sdksetup6.exe"

# Note: Add NuGet
RUN Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "C:\windows\nuget.exe" -UseBasicParsing  
WORKDIR "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0"

# Note: Install Web Targets
RUN Start-Process "C:\windows\nuget.exe" 'Install MSBuild.Microsoft.VisualStudio.Web.targets -Version 12.0.4' -NoNewWindow -Wait
RUN mv 'C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\MSBuild.Microsoft.VisualStudio.Web.targets.12.0.4\tools\VSToolsPath\*' 'C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\'  
# TODO: new webtargets

# Note: Add ClickOnce Bootstrapper files and location to registry for (VS 2017)
COPY Files/Bootstrapper/ C:/Bootstrapper/
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 15.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\15.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 14.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\14.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 11.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\11.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 4.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\4.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String

# Note: Add Office VSTO redist, add dependencies to GAC and add office targets
RUN Invoke-WebRequest "https://download.microsoft.com/download/F/B/A/FBAB6866-71F8-4A3F-89A4-5BC6AB035C62/vstor_redist.exe" -OutFile "$env:TEMP\vstor_redist.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\vstor_redist.exe" '/q' -NoNewWindow -Wait
RUN Remove-Item "$env:TEMP\vstor_redist.exe"
COPY Files/vsto/ C:/vsto/

# Note: Adding stuff to GAC can break it during runtime. Running the image on hyperv seems to be the cause
ENV gacutilloc="C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0a\bin\NETFX 4.6.2 Tools\gacutil.exe"
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.VisualStudio.Tools.Applications.BuildTasks.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.VisualStudio.Tools.Office.BuildTasks.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.VisualStudio.Tools.Applications.Hosting.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.VisualStudio.Tools.Applications.Hosting.resources.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.InfoPath.Permission.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.interop.access.dao.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Access.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Excel.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Graph.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.InfoPath.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.InfoPath.SemiTrust.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.InfoPath.Xml.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.MSProject.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.OneNote.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Outlook.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.OutlookViewCtl.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.PowerPoint.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Publisher.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.SharePointDesigner.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.SharePointDesignerPage.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.SmartTag.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Visio.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Visio.SaveAsWeb.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.VisOcx.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Interop.Word.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Vbe.Interop.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Vbe.Interop.Forms.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Office.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/stdole.dll' -NoNewWindow -Wait
RUN Start-Process $env:gacutilloc '/i C:/vsto/Microsoft.Office.Tools.Common.v4.0.Utilities.dll' -NoNewWindow -Wait
RUN New-Item -ItemType dir 'C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/OfficeTools'
RUN Copy-Item -Path 'C:/vsto/Microsoft.VisualStudio.Tools.Office.targets' -Destination 'C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/OfficeTools/Microsoft.VisualStudio.Tools.Office.targets'
RUN Copy-Item -Path 'C:/vsto/Microsoft.VisualStudio.OfficeTools.targets' -Destination 'C:/Program Files (x86)/MSBuild/Microsoft.VisualStudio.OfficeTools.targets'
RUN Copy-Item -Path 'C:/vsto/en' -Destination 'C:/Program Files (x86)/Microsoft Visual Studio 14.0/SDK/Bootstrapper/Packages/VSTOR40/'
RUN Copy-Item -Path 'C:/vsto/product.xml' -Destination 'C:/Program Files (x86)/Microsoft Visual Studio 14.0/SDK/Bootstrapper/Packages/VSTOR40/'