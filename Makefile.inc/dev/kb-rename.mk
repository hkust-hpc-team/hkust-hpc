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
	@kb_key="$*"; \
	kb_dir="$(KB_DIR)/$$kb_key"; \
	for file in $$(find "$$kb_dir" -name '*.rst' ! -name 'index.rst' -exec basename {} \;); do \
		filepath="$$kb_dir/$$file"; \
		title_text="$$(grep '==========' "$$filepath" -m 1 -B 1 | head -n 1 | tr -d '\n')"; \
		title="$$(printf '%s' "$$title_text" | tr '[:upper:]' '[:lower:]' | tr -d '\n' | tr -c '[:alnum:]' '-' | tr -s '-' | sed 's/^-//;s/-$$//' | cut -c1-$(KB_TITLE_LEN))"; \
		hash="$$(printf '%s' "$$title_text" | openssl dgst -binary -sha256 | base64 | tr '/+' '_-' | tr -d '=' | cut -c1-$(KB_HASH_LEN))"; \
		name="$$kb_key-$$title-$${hash}.rst"; \
		if [ "$$filepath" = "$$kb_dir/$$name" ]; then \
			continue; \
		fi; \
		echo mv "$$filepath" "$$kb_dir/$$name"; \
		mv "$$filepath" "$$kb_dir/$$name"; \
	done

.PHONY_TARGETS += $(addprefix kb-rename.,$(KB_KEYS))
