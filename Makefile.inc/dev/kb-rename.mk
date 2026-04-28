KB_DIR        = docs/src/kb
KB_KEYS       = $(shell for dir in $(KB_DIR)/*/; do basename "$$dir"; done)
KB_TITLE_LEN	= 32
KB_HASH_LEN	  = 6

# Hash is in url-safe base64 encoding:
#   - '/' and '+' are replaced with '_' and '-' respectively.
#   - '=' is removed.
#* Hash is invariant unless title (first line of text) changed.
$(addprefix kb-rename.,$(KB_KEYS)):
kb-rename.%: $(KB_DIR)/%
	$(eval LVAR_KB_KEY := $*)
	$(eval LVAR_KB_DIR := $(KB_DIR)/$(LVAR_KB_KEY))
	$(eval LVAR_RENAME_LIST := $(shell find "$(LVAR_KB_DIR)" -name '*.rst' ! -name 'index.rst' -exec basename {} \;))
	for file in $(LVAR_RENAME_LIST); do \
		filepath="$(LVAR_KB_DIR)/$$file"; \
		title_text="$$(grep '==========' "$$filepath" -m 1 -B 1 | head -n 1 | tr -d '\n')"; \
		title="$$(printf '%s' "$$title_text" | tr '[:upper:]' '[:lower:]' | tr -d '\n' | tr -c '[:alnum:]' '-' | cut -c1-$(KB_TITLE_LEN))"; \
		hash="$$(printf '%s' "$$title_text" | openssl dgst -binary -sha256 | base64 | tr '/+' '_-' | tr -d '=' | cut -c1-$(KB_HASH_LEN))"; \
		name="$(LVAR_KB_KEY)-$$title-$${hash}.rst"; \
		if [ "$$filepath" = "$(LVAR_KB_DIR)/$$name" ]; then \
			continue; \
		fi; \
		echo mv $$filepath $(LVAR_KB_DIR)/$$name; \
		mv $$filepath $(LVAR_KB_DIR)/$$name; \
	done
	$(eval LVAR_RENAME_LIST :=)
	$(eval LVAR_KB_DIR :=)
	$(eval LVAR_KB_KEY :=)

.PHONY_TARGETS += $(addprefix kb-rename.,$(KB_KEYS))
