require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess::CoreExtensions::String" do
  include HotDogPrincess

  describe "name_to_key_camecase" do
    it "own the method" do
      expect(''.method(:name_to_key_camecase).owner).to eq HotDogPrincess::CoreExtensions::String
      expect(String.ancestors).to include(HotDogPrincess::CoreExtensions::String)
    end
    it "can convert the string name to a hash key style string" do
      expect('A_Complex_3_Name::==='.name_to_key_camecase).to eq 'a_complex_name'
      expect('Application'.name_to_key_camecase).to eq 'application'
      expect('Content Name'.name_to_key_camecase).to eq 'content_name'
      expect('User Message:'.name_to_key_camecase).to eq 'user_message'
      expect('Device'.name_to_key_camecase).to eq 'device'
      expect('IOS Version'.name_to_key_camecase).to eq 'ios_version'
      expect('Brand'.name_to_key_camecase).to eq 'brand'
      expect('Ticket Origin'.name_to_key_camecase).to eq 'ticket_origin'
      expect('Priority'.name_to_key_camecase).to eq 'priority'
      expect('Issue Category'.name_to_key_camecase).to eq 'issue_category'
      expect('iTunes Account'.name_to_key_camecase).to eq 'i_tunes_account'
      expect('Meets Age Requirement'.name_to_key_camecase).to eq 'meets_age_requirement'
      expect('Product'.name_to_key_camecase).to eq 'product'
      expect('Diagnosis'.name_to_key_camecase).to eq 'diagnosis'
      expect('Summary'.name_to_key_camecase).to eq 'summary'
      expect('User-Agent'.name_to_key_camecase).to eq 'user_agent'
      expect('User Email'.name_to_key_camecase).to eq 'user_email'
      expect('Email Subject'.name_to_key_camecase).to eq 'email_subject'
      expect('Source'.name_to_key_camecase).to eq 'source'
      expect('TV Provider'.name_to_key_camecase).to eq 'tv_provider'
      expect('System Info'.name_to_key_camecase).to eq 'system_info'
      expect('Retention Program Candidate'.name_to_key_camecase).to eq 'retention_program_candidate'
      expect('STATUS - Suggested Solution'.name_to_key_camecase).to eq 'status_suggested_solution'
      expect('Your Message:'.name_to_key_camecase).to eq 'your_message'
    end
  end

  describe "name_to_key" do
    it "own the method" do
      expect(''.method(:name_to_key).owner).to eq HotDogPrincess::CoreExtensions::String
      expect(String.ancestors).to include(HotDogPrincess::CoreExtensions::String)
    end
    it "can convert the string name to a hash key style string" do
      expect('A_Complex_3_Name::==='.name_to_key).to eq 'a_complex_name'
      expect('Application'.name_to_key).to eq 'application'
      expect('Content Name'.name_to_key).to eq 'content_name'
      expect('User Message:'.name_to_key).to eq 'user_message'
      expect('Device'.name_to_key).to eq 'device'
      expect('IOS Version'.name_to_key).to eq 'ios_version'
      expect('Brand'.name_to_key).to eq 'brand'
      expect('Ticket Origin'.name_to_key).to eq 'ticket_origin'
      expect('Priority'.name_to_key).to eq 'priority'
      expect('Issue Category'.name_to_key).to eq 'issue_category'
      expect('iTunes Account'.name_to_key).to eq 'itunes_account'
      expect('Meets Age Requirement'.name_to_key).to eq 'meets_age_requirement'
      expect('Product'.name_to_key).to eq 'product'
      expect('Diagnosis'.name_to_key).to eq 'diagnosis'
      expect('Summary'.name_to_key).to eq 'summary'
      expect('User-Agent'.name_to_key).to eq 'user_agent'
      expect('User Email'.name_to_key).to eq 'user_email'
      expect('Email Subject'.name_to_key).to eq 'email_subject'
      expect('Source'.name_to_key).to eq 'source'
      expect('TV Provider'.name_to_key).to eq 'tv_provider'
      expect('System Info'.name_to_key).to eq 'system_info'
      expect('Retention Program Candidate'.name_to_key).to eq 'retention_program_candidate'
      expect('STATUS - Suggested Solution'.name_to_key).to eq 'status_suggested_solution'
      expect('Your Message:'.name_to_key).to eq 'your_message'
    end
  end

end
