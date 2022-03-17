prefix      := $(or $(prefix),$(PREFIX),/usr)
sysconfdir  := /etc

ZSH_ETCDIR  := $(sysconfdir)/zsh

INSTALL     := install
GIT         := git
ZSH         := zsh

MAKEFILE_PATH  = $(lastword $(MAKEFILE_LIST))


#: Print list of targets.
help:
	@printf '%s\n\n' 'List of targets:'
	@$(SED) -En '/^#:.*/{ N; s/^#: (.*)\n([A-Za-z0-9_-]+).*/\2 \1/p }' $(MAKEFILE_PATH) \
		| while read label desc; do printf '%-15s %s\n' "$$label" "$$desc"; done

#: Check zsh scripts for errors.
check:
	@$(ZSH) -c '\
		rc=0;                              \
		for f in zshrc.d/*.zsh; do         \
		    if source $$f; then            \
		        printf "%-33s PASS\n" $$f; \
		    else                           \
		        printf "%-35s FAIL\n" $$f; \
		        rc=1;                      \
		    fi;                            \
		done;                              \
		exit $$rc'

#: Install files into $DESTDIR.
install:
	$(INSTALL) -D -m644 zshrc.d/* -t "$(DESTDIR)$(ZSH_ETCDIR)"/zshrc.d/

#: Create release commit and tag for $VERSION.
release: .check-git-clean
	test -n "$(VERSION)"  # $$VERSION
	$(GIT) add .
	$(GIT) commit --allow-empty -m "Release version $(VERSION)"
	$(GIT) tag -s v$(VERSION) -m v$(VERSION)


.check-git-clean:
	@test -z "$(shell $(GIT) status --porcelain)" \
		|| { echo 'You have uncommitted changes!' >&2; exit 1; }

.PHONY: help check install release .check-git-clean
