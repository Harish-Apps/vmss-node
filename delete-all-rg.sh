
# List all resource groups and delete them
az group list --query "[].name" -o tsv | while read -r line
do
   echo "Deleting resource group $line"
   az group delete --name "$line" --yes --no-wait
done
