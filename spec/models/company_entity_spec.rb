require 'rails_helper'

describe CompanyEntity do

  let(:client) do
    FactoryBot.create(:client)
  end

  let(:account) do
    FactoryBot.create(:account)
  end

  let(:company_entity) { FactoryBot.create(:company_entity, parent: account) }
  let(:company_entity) { FactoryBot.create(:company_entity, entity: client) }

  subject{ company_entity }

  it { should be_valid }
  it { should respond_to(:parent) }
  it { should respond_to(:entity) }

end

