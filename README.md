# Automate Deployment of Azure Web App Using Bicep Template and Azure CLI
In a [Medium post](https://medium.com/@nejimon.raveendran/automate-deployment-of-azure-web-apps-using-azure-cli-and-powershell-adbcaa06e236), I discussed how the deployment of an Azure App Service Web App can be automated using Azure CLI and PowerShell. In this article, I am going to show how the same deployment can be done using [Bicep templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep).

In Azure, resource manager templates (ARM templates) used to be the classic method for automation of operations against the Azure resources (eg. virtual machines, app service, etc.) using declarative syntax. Anyone who has written ARM templates would know how difficult it is to work with the verbose JSON format, especially when templates are large, resources are many in number, and/or resources have dependency on other resources. Bicep templates take away much of the complexities of the ARM templates and provide a much more concise, developer-friendly syntax. Whereas ARM templates required you to explicitly define dependencies among the templates, Bicep templates can resolve the dependencies automatically. Also tools like Visual Studio Code offer syntax highlighting and autocomplete through Bicep extensions. To learn more about how Bicep templates compare against ARM templates, [refer to this](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/compare-template-syntax).

### Prerequisites/assumptions:
- A valid Azure subscription.
- PowerShell installed on the local machine with az module (command: Install-Module Az).
- Azure CLI bicep module. Use the command from PowerShell: az bicep install.
- The application to be deployed is a web application written in .NET Core/.NET 6
- For Bicep development in Visual Studio Code, install Microsoft Bicep extension [available here](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep).

A summary of what we are trying to achieve is given below:

- Prepare Bicep templates containing the definition of the Azure resource group to be created, [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans), and [Azure Web App](https://docs.microsoft.com/en-us/azure/app-service/overview).
- Login in to Azure.
- Run Bicep template using PowerShell/Azure CLI.
- Publish the .NET 6 project to a folder on the local machine.
- Zip the published folder.
- Deploy the ZIP package to the Azure web app.
- Verify the deployment by navigating to the URL of the web app.

Before starting to write the templates, for the purpose of this example, we assume that we will be deploying a .NET 6 web application named MyApp and the project exists in the local folder *C:\Temp\AzDemo\AzureWebAppBicep*. All the Bicep templates will be stored in the *IaC* folder.

![image](https://user-images.githubusercontent.com/68135957/224522229-6a98c6b3-088c-4c19-b8d8-7d471293d55c.png)

You can download the source code from this repo.

### Prepare the Bicep Deployment Template
There are 3 templates in the IaC folder:
1. **aspModule.bicep:** This file holds the definition of the Azure App Service Plan (ASP).
2. **webAppModule.bicep:** This file has the definition of the Azure Web App.
3. **main.bicep:** This file first defines the parameters, variables, and resource group. Once the resource group is defined, the instances of above 2 modules are created. For the ASP, we provision an SKU named P2V3, which is a production-grade pool of virtual machines. For the web app module, we use .NET 6 as the target framework.

To learn more about how to use Bicep templates, refer to [the official Microsoft documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/).

### Log In to Azure
Open PowerShell and switch the path to *C:\Temp\AzDemo\AzureWebAppBicep*. Then, issue the command:

```bash
az login --username <your_azure_username> --password <your_password>
```

### Run Bicep template using PowerShell/Azure CLI

```bash
az deployment sub create --location canadacentral --template-file .\IaC main.bicep --parameters loc=canadacentral
```

### Publish the .NET 6 Project to A Folder on the Local Machine

Now that the template is run and the web app is created in Azure, it is time to deploy the code into the web app. First, publish the .NET core project into a folder on the local machine. The following command will create a new folder called ‘published’ and publish the project into that folder.

```bash
dotnet publish --output published
```

### Zip the ‘Published’ Folder

The following PowerShell command zips contents of the published folder into a zip archive named *site_v1.zip*.

```bash
Compress-Archive published\* site_v1.zip
```

### Deploy the ZIP Package to the Azure web App

Finally, we push the zip archive to the Azure web app with the following command:

```bash
az webapp deploy --async false --clean true --subscription ‘Visual Studio Enterprise’ --resource-group ‘rg-myrealmbookapp’ --name myrealmbookapp --restart true --src-path site_v1.zip
```

Note that the *rg-myrealmbookapp* is the resource group name and the *myrealmbookapp* is the web app name defined in the *main.bicep* template file.

In the above command, we tell Azure CLI to execute the command synchronously. Also instruct it to clean the web app contents before deployment and restart the site after deployment.

If everything goes well, you should be able to see the output like the following:

![image](https://user-images.githubusercontent.com/68135957/224522385-d91a06ab-2e37-4b10-a9bb-24aed5634104.png)

### Verify the deployment
Now, try navigating to the site *https://mybookwebapp.azurewebsites.net* in your browser. Voilà, your site loads there!

### Conclusion
Though there are other options (eg. Azure CLI, ARM templates) to automate the operations against Azure resources, Bicep template may be one you want to consider because of its declarative syntax as well as the simplicity. Azure Web Apps combined with Bicep templates can accelerate your cloud DevOps journey significantly faster.


