FROM microsoft/windowsservercore
MAINTAINER chemso@gmx.de 
# Original author alexellis2@gmail.com, see http://blog.alexellis.io/3-steps-to-msbuild-with-docker/

# docker push chemsorly/msbuild-builder:4.5
SHELL ["powershell"]

# Note: Get MSBuild 14.
RUN Invoke-WebRequest "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe" -OutFile "$env:TEMP\BuildTools_Full.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\BuildTools_Full.exe" '/Silent /Full' -wait
# Todo: delete the BuildTools_Full.exe file in this layer

# Note: Add .NET + ASP.NET
RUN Install-WindowsFeature NET-Framework-45-ASPNET
RUN Install-WindowsFeature Web-Asp-Net45

# Note: Add .NET 4.5 SDK (Windows 8)
RUN Invoke-WebRequest "http://download.microsoft.com/download/F/1/3/F1300C9C-A120-4341-90DF-8A52509B23AC/standalonesdk/sdksetup.exe" -OutFile "$env:TEMP\sdksetup.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup.exe" '/features + /q' -wait

# Node: Add Windows 10 SDK
RUN Invoke-WebRequest "http://download.microsoft.com/download/6/3/B/63BADCE0-F2E6-44BD-B2F9-60F5F073038E/standalonesdk/SDKSETUP.EXE" -OutFile "$env:TEMP\sdksetup2.exe" -UseBasicParsing  
RUN Start-Process "$env:TEMP\sdksetup2.exe" '/features + /q' -wait

# Note: Add NuGet
RUN Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "C:\windows\nuget.exe" -UseBasicParsing  
WORKDIR "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0"

# Note: Install Web Targets
RUN &  "C:\windows\nuget.exe" Install MSBuild.Microsoft.VisualStudio.Web.targets -Version 12.0.4  
RUN mv 'C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\MSBuild.Microsoft.VisualStudio.Web.targets.12.0.4\tools\VSToolsPath\*' 'C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\'  

# Note: Add ClickOnce Bootstrapper files and location to registry owershell(VS 2015)
COPY Files/Bootstrapper/ C:/Bootstrapper/
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 14.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\14.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 11.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\11.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String
RUN New-Item -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper -Name 4.0 -Force
RUN New-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\GenericBootstrapper\4.0 -Name Path -Value C:\Bootstrapper\ -PropertyType String

# Note: Add Office VSTO DLLs and register to GAC
RUN Invoke-WebRequest "https://download.microsoft.com/download/F/B/A/FBAB6866-71F8-4A3F-89A4-5BC6AB035C62/vstor_redist.exe" -OutFile "$env:TEMP\vstor_redist.exe" -UseBasicParsing  
RUN &  "$env:TEMP\vstor_redist.exe" /q
COPY Files/vsto/ C:/vsto/
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.VisualStudio.Tools.Applications.BuildTasks.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.VisualStudio.Tools.Office.BuildTasks.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.InfoPath.Permission.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.interop.access.dao.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Access.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Excel.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Graph.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.InfoPath.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.InfoPath.SemiTrust.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.InfoPath.Xml.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.MSProject.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.OneNote.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Outlook.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.OutlookViewCtl.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.PowerPoint.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Publisher.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.SharePointDesigner.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.SharePointDesignerPage.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.SmartTag.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Visio.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Visio.SaveAsWeb.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.VisOcx.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Office.Interop.Word.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Vbe.Interop.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Microsoft.Vbe.Interop.Forms.dll
RUN & 'C:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v10.0A\\bin\\NETFX 4.6.2 Tools\\gacutil.exe' /i C:/vsto/Office.dll
RUN New-Item -ItemType dir 'C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/OfficeTools'
RUN Copy-Item -Path 'C:/vsto/Microsoft.VisualStudio.Tools.Office.targets' -Destination 'C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/OfficeTools/Microsoft.VisualStudio.Tools.Office.targets'
RUN Copy-Item -Path 'C:/vsto/Microsoft.VisualStudio.OfficeTools.targets' -Destination 'C:/Program Files (x86)/MSBuild/Microsoft.VisualStudio.OfficeTools.targets'
RUN Copy-Item -Path 'C:/vsto/en' -Destination 'C:/Program Files (x86)/Microsoft Visual Studio 14.0/SDK/Bootstrapper/Packages/VSTOR40/'
RUN Copy-Item -Path 'C:/vsto/product.xml' -Destination 'C:/Program Files (x86)/Microsoft Visual Studio 14.0/SDK/Bootstrapper/Packages/VSTOR40/'

# Note: Add Msbuild to path
RUN setx PATH '%PATH%;C:\\Program Files (x86)\\MSBuild\\14.0\\Bin\\msbuild.exe'  