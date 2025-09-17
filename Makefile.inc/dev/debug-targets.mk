list-file-targets:
	@echo $(.FILE_TARGETS)

list-phony-targets:
	@echo $(.PHONY_TARGETS)

list-configs:
	@echo Makefiles:
	@echo $(.SOURCE_FILES_MK)
	@echo PyProject:
	@echo $(.SOURCE_FILES_PYPROJECT)
	@echo Sphinx Configs:
	@echo $(.SOURCE_FILES_SPHINX_CONFIG)

list-sources:
	@echo Sphinx Sources:
	@echo $(SOURCE_FILES_SPHINX)


.PHONY_TARGETS += list-file-targets list-phony-targets list-configs list-sources
