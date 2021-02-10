# frozen_string_literal: true

control "check java is installed" do
  # test the service and the port
  describe package("java-1.8.0-openjdk") do
    it { should be_installed }
  end
end
