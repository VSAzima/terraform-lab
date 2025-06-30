check:
	@echo "Checking your code with tfsec..."
	tfsec .

	@echo "Checking your code with checkov..."
	checkov -d .

	@echo "Checking your code with terrascan..."
	terrascan scan -t aws -d . ;true
	$(MAKE) format
format:
	@echo  "Running terraform-docs to generate documentation..."
	terraform-docs pretty ./modules/create_ec2 --color
