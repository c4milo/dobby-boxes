# Makefile borrowed from https://github.com/misheska/basebox-packer

#TOKEN=a60e8a9983114dbe21f7c88855c1e787ea8c47f8

# curl -H "Authorization: token $TOKEN" \
#      -H "Accept: application/vnd.github.manifold-preview" \
#      -H "Content-Type: application/x-apple-diskimage" \
#      --data-binary @$FULLNAME.pkg.zip \
#      "https://uploads.github.com/repos/c4milo/dobby-boxes/releases/$VERSION/assets?name=$FULLNAME.pkg.zip"

#BUILDER_TYPES = vmware virtualbox
BUILDER_TYPES = vmware 
TEMPLATE_PATHS := $(wildcard template/*/*.json)
TEMPLATE_FILENAMES := $(notdir ${TEMPLATE_PATHS})
TEMPLATE_DIRS := $(dir ${TEMPLATE_PATHS})
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=.box)
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), $(builder)/$(box_filename)))
RM = rm -f

vpath %.json template/coreos:template/docker

.PHONY: all
all: $(BOX_FILES)

vmware/%.box: %.json
	cd $(dir $<); \
	rm -rf output-vmware; \
	mkdir -p ../../vmware; \
	packer build -only=vmware-iso $(notdir $<)

virtualbox/%.box: %.json
	cd $(dir $<); \
	rm -rf output-virtualbox; \
	mkdir -p ../../virtualbox; \
	packer build -only=virtualbox-iso $(notdir $<)

.PHONY: list
list:
	@for builder in $(BUILDER_TYPES) ; do \
		for box_filename in $(BOX_FILENAMES) ; do \
			echo $$builder/$$box_filename ; \
		done ; \
	done

.PHONY: clean really-clean clean-builders clean-output clean-packer-cache
clean: clean-builders clean-output

really-clean: clean clean-packer-cache

clean-builders:
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d $$builder ; then \
			echo Deleting $$builder ; \
			$(RM) -rf $$builder ; \
		fi ; \
	done

clean-output:
	@for template in $(TEMPLATE_DIRS) ; do \
		for builder in $(BUILDER_TYPES) ; do \
			if test -d $$template/output-$$builder ; then \
				echo Deleting $$template/output-$$builder ; \
				$(RM) -rf $$template/output-$$builder ; \
			fi ; \
		done ; \
	done

clean-packer-cache:
	@for template in $(TEMPLATE_DIRS) ; do \
		if test -d $$template/packer_cache ; then \
			echo Deleting $$template/packer_cache ; \
			$(RM) -rf $$template/packer_cache ; \
		fi ; \
	done