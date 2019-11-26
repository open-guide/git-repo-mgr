PWD = $(shell pwd)
DATE_SUF = $(shell date +%Y.%m.%d.%H.%M.%S)

# GIT_OPT := --depth=1

REPO_LIST_DIR	:= ../../conf/git.repos.d
REPO_SRC_DIR	:= ../../src/repo
TOPIC_SRC_DIR	:= ../../src/topics


# ###########################
# MAIN AREA
# ###########################
.PHONY: init fini clean install uninstall sync export
init:
	$(call fetchRepoListR,gitee,$(REPO_SRC_DIR),git@gitee.com:)
	@echo ALL DONE;
fini:
	echo "$@ - PASS"
clean:
	-rm -rvf *.log *.bak

install:
uninstall:
sync:
	-find $(REPO_SRC_DIR) -type d -name ".git" | xargs -t -n1 -I _ git -C _/.. pull
	echo sync done.
export:
	@echo TODO-RESERVED


# ###########################
# SUB AREA
# ###########################



# ######################
# 自定义 utils
# ######################
# usage: $(call verifyLink, src-file-or-dir, dst-link[, sudo])
define verifyLink
	[ -h $(2) ] && $(3) unlink $(2) || >/dev/null
	[ -e $(2) ] && $(3) mv $(2) $(2)-$(DATE_SUF) || >/dev/null
	[ ! -h $(2) ] && $(3) ln -s $(1) $(2) || >/dev/null
endef


define fetchRepoListR
	# 拉取列表
	# echo "cat $(REPO_LIST_DIR)/$(1).d/*.lst"
	for x in $(shell cat $(REPO_LIST_DIR)/$(1).d/*.lst | grep -v '#' | sort); do \
		echo $$x; \
		fname=$$(echo $$x | tr '/.' '-' | tr A-Z a-z); \
		dest_dir=$(2)/$$fname; \
		[ ! -d "$$dest_dir" ] && git clone --depth=1 $(GIT_OPT) "$(3)$${x}.git" "$$dest_dir"; \
		echo "$$x done"; \
	done;
	# 符号链接化 
	for flst_path in `ls $(REPO_LIST_DIR)/$(1).d/*.lst`; do \
		topic_name=`basename $$flst_path | cut -d. -f1`; \
		topic_dir=$(TOPIC_SRC_DIR)/$$topic_name; \
		[ -d "$$topic_dir" ] || mkdir -p "$$topic_dir"; \
		lst=`cat $$flst_path | grep -v "#"`; \
		for x in $$lst; do \
			dname=$$(echo $$x | tr '/.' '-' | tr A-Z a-z); \
			[ -h "$$topic_dir/$$dname" ] || ln -fs "../../repo/$$dname" "$$topic_dir/$$dname"; \
		done; \
		echo "$$topic_dir $$flst_path done"; \
	done;
endef
