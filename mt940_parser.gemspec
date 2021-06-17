# -*- encoding: utf-8 -*-
# stub: mt940_parser 1.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "mt940_parser".freeze
  s.version = "1.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thies C. Arntzen".freeze, "Phillip Oertel".freeze]
  s.date = "2021-06-17"
  s.description = "Ruby library that parses account statements in the SWIFT MT940 format.".freeze
  s.email = "developers@betterplace.org".freeze
  s.extra_rdoc_files = ["README.md".freeze, "lib/mt940.rb".freeze, "lib/mt940/customer_statement_message.rb".freeze, "lib/mt940/errors.rb".freeze, "lib/mt940/version.rb".freeze]
  s.files = [".document".freeze, ".gitignore".freeze, ".specification".freeze, ".travis.yml".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "docs/0E0Y00DNY.pdf".freeze, "docs/FinTS_4.0_Formals.pdf".freeze, "docs/FinTS_4.0_Messages_Finanzdatenformate.pdf".freeze, "docs/MT940_Deutschland_Structure2002.pdf".freeze, "docs/SEPA_20MT940__Schnittstellenbeschreibung.pdf".freeze, "docs/mt940.pdf".freeze, "docs/swift_mt940_942.pdf".freeze, "docs/uebersicht_der_geschaeftsvorfallcodes_und_buchungs_textschluessel.pdf".freeze, "lib/mt940.rb".freeze, "lib/mt940/customer_statement_message.rb".freeze, "lib/mt940/errors.rb".freeze, "lib/mt940/version.rb".freeze, "mt940_parser.gemspec".freeze, "test/fixtures/amount_formats.txt".freeze, "test/fixtures/amount_formats.yml".freeze, "test/fixtures/colon_in_descriptor.txt".freeze, "test/fixtures/colon_in_descriptor.yml".freeze, "test/fixtures/currency_in_25.txt".freeze, "test/fixtures/currency_in_25.yml".freeze, "test/fixtures/empty_86.txt".freeze, "test/fixtures/empty_86.yml".freeze, "test/fixtures/empty_entry_date.txt".freeze, "test/fixtures/empty_entry_date.yml".freeze, "test/fixtures/empty_line.txt".freeze, "test/fixtures/empty_line.yml".freeze, "test/fixtures/missing_crlf_at_end.txt".freeze, "test/fixtures/missing_crlf_at_end.yml".freeze, "test/fixtures/sepa_mt9401.txt".freeze, "test/fixtures/sepa_mt9401.yml".freeze, "test/fixtures/sepa_snippet.txt".freeze, "test/fixtures/sepa_snippet_broken.txt".freeze, "test/fixtures/with_binary_character.txt".freeze, "test/fixtures/with_binary_character.yml".freeze, "test/test_account_identifier.rb".freeze, "test/test_customer_statement_message.rb".freeze, "test/test_helper.rb".freeze, "test/test_mt940.rb".freeze]
  s.homepage = "http://github.com/betterplace/mt940_parser".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "Mt940Parser - MT940 parses account statements in the SWIFT MT940 format.".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.2.3".freeze
  s.summary = "MT940 parses account statements in the SWIFT MT940 format.".freeze
  s.test_files = ["test/test_account_identifier.rb".freeze, "test/test_customer_statement_message.rb".freeze, "test/test_helper.rb".freeze, "test/test_mt940.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.11.0"])
    s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.11.0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
  end
end
