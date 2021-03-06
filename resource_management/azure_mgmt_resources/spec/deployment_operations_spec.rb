# encoding: utf-8
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative 'spec_helper'
require_relative 'deployment_shared'

include MsRestAzure
include Azure::ARM::Resources

describe DeploymentOperations do

  before(:all) do
    @client = RESOURCES_CLIENT.deployment_operations
    @resource_group = create_resource_group
  end

  before do
    @deployment = create_deployment(@resource_group.name)
    wait_for_deployment(@resource_group.name, @deployment.name, build_deployment_params)
  end

  after(:all) do
    delete_resource_group(@resource_group.name)
  end

  it 'should get a list of deployment operations' do
    result = @client.list(@resource_group.name, @deployment.name).value!
    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.value).to be_a(Array)

    while !result.body.next_link.nil? && !result.body.next_link.empty?  do
      result = @client.list_next(result.body.next_link).value!
      expect(result.body.value).not_to be_nil
      expect(result.body.value).to be_a(Array)
    end
  end

  it 'should get a list of deployment operation restricted with top parameter' do
    result = @client.list(@resource_group.name, @deployment.name, 1).value!
    expect(result.response.status).to eq(200)
    expect(result.body).not_to be_nil
    expect(result.body.value).to be_a(Array)

    while !result.body.next_link.nil? && !result.body.next_link.empty?  do
      result = @client.list_next(result.body.next_link).value!
      expect(result.body.value).not_to be_nil
      expect(result.body.value).to be_a(Array)
    end
  end

  it 'should get a deployment operation' do
    operations = @client.list(@resource_group.name, @deployment.name).value!.body.value

    result = @client.get(@resource_group.name, @deployment.name, operations[0].operation_id).value!
    expect(result.response.status).to eq(200)
    expect(result.body.operation_id).to eq(operations[0].operation_id)
    expect(result.body.id).not_to be_nil
    expect(result.body.properties).to be_an_instance_of(Models::DeploymentOperationProperties)
  end

end
