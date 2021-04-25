# Get resouce group name
RESOURCE_GROUP_NAME="[resource group name]"

# 1. Create a new SignalR account
SIGNALR_SERVICE_NAME=msl-sigr-signalr$(openssl rand -hex 5)
az signalr create --name $SIGNALR_SERVICE_NAME --resource-group $RESOURCE_GROUP_NAME --sku Free_DS2 --unit-count 1

az resource update --resource-type Microsoft.SignalRService/SignalR --name $SIGNALR_SERVICE_NAME --resource-group $RESOURCE_GROUP_NAME --set properties.features[flag=ServiceMode].value=Serverless

# 2. Update local settings
SIGNALR_CONNECTION_STRING=$(az signalr key list --resource-group $RESOURCE_GROUP_NAME --query [0].name -o tsv) --resource-group $RESOURCE_GROUP_NAME --query primaryConnectionString -o tsv)

printf "\n\nReplace <SIGNALR_CONNECTION_STRING> with:\n$SIGNALR_CONNECTION_STRING\n\n"

# Update AzureSignalRConnectionString value in local.settings.json

# 3. Manage client connections

# Create new Azure Function in start/
# Template: HTTP Trigger
# Name: negotiate
# Authorization level: Anonymous

# Update negotiate/function.json
# "type": "signalRConnectionInfo"
# "name": "connectionInfo"
# "hubName": "stocks"
# "direction": "in"
# "connectionStringSetting": "AzureSignalRConnectionString"

# Update negotiate/index.js
# module.exports = async function (context, req, connectionInfo) {
#    context.res.body = connectionInfo;
# };

# 4. Detect and broadcast database changes

# Create new Azure Function in start/
# Template: Azure Cosmos DB Trigger
# Name:  stocksChanged
# App setting: AzureCosmosDBConnectionString
# Database name: stocksdb
# Collection name: stocks
# Collection name for leases: leases
# Create lease collection if not exists: true

# Add property "feedPollDelay": 500 to end of stocksChanged/function.json

# Append binding definition to bindings array
# "type": "signalR"
# "name": "signalRMessages"
# "connectionString": "AzureSignalRConnectionString"
# "hubName": "stocks"
# "direction": "out"

# Update stocksChanged/index.js
# module.exports = async function (context, req, documents) {
#   const updates = documents.map(stock => ({
#       target: 'updated',
#       arguments: [stock]
#   }));
#
#   context.bindings.signalRMessages = updates;
#   context.done();
# }
#
# 5. Update the web aplication
#
# Add the following code to public/index.html
#
# <div id="app" class="container">
#     <h1 class="title">Stocks</h1>
#     <div id="stocks">
#         <div v-for="stock in stocks" class="stock">
#             <transition name="fade" mode="out-in">
#                 <div class="list-item" :key="stock.price">
#                     <div class="lead">{{ stock.symbol }}: ${{ stock.price }}</div>
#                     <div class="change">Change:
#                         <span
#                             :class="{ 'is-up': stock.changeDirection === '+', 'is-down': stock.changeDirection === '-' }">
#                             {{ stock.changeDirection }}{{ stock.change }}
#                         </span>
#                     </div>
#                 </div>
#             </transition>
#         </div>
#     </div>
# </div>
#
# Add above reference to index.html.js
# <script src="https://cdn.jsdelivr.net/npm/@aspnet/signalr@1.1.0/dist/browser/signalr.js"></script>
#
# Replace content in public/index.html.js
# const LOCAL_BASE_URL = 'http://localhost:7071';
# const REMOTE_BASE_URL = '<FUNCTION_APP_ENDPOINT>';
#
# const getAPIBaseUrl = () => {
#     const isLocal = /localhost/.test(window.location.href);
#     return isLocal ? LOCAL_BASE_URL : REMOTE_BASE_URL;
# }
#
# const app = new Vue({
#     el: '#app',
#     data() {
#         return {
#             stocks: []
#         }
#     },
#     methods: {
#         async getStocks() {
#             try {
#                 const apiUrl = `${getAPIBaseUrl()}/api/getStocks`;
#                 const response = await axios.get(apiUrl);
#                 app.stocks = response.data;
#             } catch (ex) {
#                 console.error(ex);
#             }
#         }
#     },
#     created() {
#         this.getStocks();
#     }
# });
#
# const connect = () => {
#     const connection = new signalR.HubConnectionBuilder()
#                             .withUrl(`${getAPIBaseUrl()}/api`)
#                             .build();
#
#     connection.onclose(()  => {
#         console.log('SignalR connection disconnected');
#         setTimeout(() => connect(), 2000);
#     });
#
#     connection.on('updated', updatedStock => {
#         const index = app.stocks.findIndex(s => s.id === updatedStock.id);
#         app.stocks.splice(index, 1, updatedStock);
#     });
#
#     connection.start().then(() => {
#         console.log("SignalR connection established");
#     });
# };
#
# connect();
