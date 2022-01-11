.PHONY: tf-test
tf-test: e2etests

.PHONY: tf-format
tf-format:
	terraform fmt -recursive -check

.PHONY: e2etests
e2etests:
	$(MAKE) -C e2etests test