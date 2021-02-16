# frozen_string_literal: true

control "check java and git are installed" do
  # test the service and the port
  installed_packages = ["java-1.8.0-openjdk", "git"]
  installed_packages.each do |installed_package|
  describe package(installed_package) do
    it { should be_installed }
  end
end
