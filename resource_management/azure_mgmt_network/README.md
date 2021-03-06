# Intro

This project provides a Ruby gem for easy access to the Azure ARM Network API. With this gem you can create/update/list/delete virtual networks, subnets, load balancers and network interfaces. Application gateways, virtual network gateways and virtual network gateway connections aren't properly supported yet - it's a known issue that will be resolved soon.

# Supported Ruby Versions

* Ruby 2+

Note: x64 Ruby for Windows is known to have some compatibility issues.

# Getting started

## Setting up the service principal

First of all to start interacting with the ARM network you will need to setup a service principal. Service principal is an Azure application which allows you to authenticate to Azure and access Azure services. The detailed steps of how to setup a service principal can be found in this article: http://aka.ms/cli-service-principal. In the result of setting up service principal you will get tenant id, client id and client secret data.

## Installation

install the appropriate gem:

```
gem install azure_mgmt_network
```

and reference it in your code:

```Ruby
require 'azure_mgmt_network'
```

After that you should be ready to start using SDK!

## Authentication

```Ruby
# Create authentication objects
token_provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, secret)
credentials = MsRest::TokenCredentials.new(token_provider)
```

To get tenant_id, client_id and secret for your Azure application visit Azure portal or copy them from the powershell script from the article mentioned above.

## Creating new virtual network

```Ruby
# Include SDK modules to ease access to network classes.
include Azure::ARM::Network
include Azure::ARM::Network::Models

# Create a client - a point of access to the API and set the subscription id
client = NetworkResourceProviderClient.new(credentials)
client.subscription_id = subscription_id

# Create a model for new virtual network
props = VirtualNetworkPropertiesFormat.new

address_space = AddressSpace.new
address_space.address_prefixes = ['10.0.0.0/16']
props.address_space = address_space

dhcp_options = DhcpOptions.new
dhcp_options.dns_servers = %w(10.1.1.1 10.1.2.4)
props.dhcp_options = dhcp_options

sub_prop = SubnetPropertiesFormat.new
sub_prop.address_prefix = '10.0.2.0/24'

sub = Subnet.new
sub.name = 'new_subnet'
sub.properties = sub_prop

props.subnets = [sub]

params = VirtualNetwork.new
params.location = 'westus'
params.properties = props

promise = client.virtual_networks.create_or_update('existing_resource_group', 'new_vn', params)
```

The SDK method returns a promise which you can utilize depending on your needs. E.g. if you need to get result immediately via sync blocking call - do the following:

```Ruby
result = promise.value!
```

If you need to follow async flow - provide a block which will be executed in off main thread:

```Ruby
promise = promise.then do |result|
  # Handle the result
end
```

In both cases you're returned an instance of MsRestAzure::AzureOperationResponse which contains HTTP requests/response objects and response body. Response body is a deserialized object representing the received information. In case of code above - newly created virtual network. To get data from it:

```Ruby
virtual_network = result.body

p virtual_network.name # name of the new vn
p virtual_network.id # id of the new vn
```

Congrats, you've create new virtual network. We encourage you to try more stuff and let us know your feedback!
For advanced SDK usage please reference to the spec files.

# Running tests

## Adding env variables

To run the tests you would need to set the following environment variables with your real Azure data:

* AZURE_TENANT_ID="your tenant id or domain"
* AZURE_CLIENT_ID="your client id / application id"
* AZURE_CLIENT_SECRET="your service principal secret"
* AZURE_SUBSCRIPTION_ID="your subscription id"

* run_long_tasks - set this to '1' only if you would like to run time consuming tests like VM creation.

## Starting tests

Just run 'rspec' command from the current gem folder.

# Contribution

All the SDK code was generated by tool 'AutoRest' - https://github.com/Azure/autorest
So if you have found a bug or have an idea for a new feature - suggest, discuss and contribute it into the AutoRest repository. After that SDK maintainers will update the sources and the gem.

# Provide feedback

Send email to the azsdkteam@microsoft.com or file new issue in this repository.
