# Create a storage account
export STORAGE_ACCOUNT_NAME=mslsigrstorage$(openssl rand -hex 5)
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"

export RESOURCE_GROUP_NAME=[sandbox resource group name]

az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --kind StorageV2 --sku Standard_LRS

# Create an Azure Cosmos DB account
az cosmosdb create --name msl-sigr-cosmos-$(openssl rand -hex 5) --resource-group $RESOURCE_GROUP_NAME

# Update local settings
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $(az storage account list --resource-group $RESOURCE_GROUP_NAME --query [0].name -o tsv) --resource-group $RESOURCE_GROUP_NAME --query "connectionString" -o tsv)

COSMOSDB_ACCOUNT_NAME=$(az cosmosdb list --resource-group $RESOURCE_GROUP_NAME --query [0].name -o tsv)

COSMOSDB_CONNECTION_STRING=$(az cosmosdb list-connection-strings --name $COSMOSDB_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)

COSMOSDB_MASTER_KEY=$(az cosmosdb list-keys --name $COSMOSDB_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query primaryMasterKey -o tsv)

printf "\n\nReplace <STORAGE_CONNECTION_STRING> with:\n$STORAGE_CONNECTION_STRING\n\nReplace <COSMOSDB_CONNECTION_STRING> with:\n$COSMOSDB_CONNECTION_STRING\n\nReplace <COSMOSDB_MASTER_KEY> with:\n$COSMOSDB_MASTER_KEY\n\n"
